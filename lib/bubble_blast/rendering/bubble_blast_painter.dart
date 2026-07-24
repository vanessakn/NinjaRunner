import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../game/bubble_blast_controller.dart';
import '../models/bubble_content_pack.dart';

class BubbleBlastPainter extends CustomPainter {
  BubbleBlastPainter({
    required this.contentPack,
    required this.state,
    required this.currentPrompt,
  });

  final BubbleContentPack contentPack;
  final BubbleBlastState state;
  final BubblePrompt currentPrompt;

  @override
  void paint(Canvas canvas, Size size) {
    _drawBackground(canvas, size);
    _drawHud(canvas, size);
    _drawBubbles(canvas, size);
    if (state.phase == BubbleBlastPhase.levelComplete) {
      _drawLevelComplete(canvas, size);
    }
    if (state.phase == BubbleBlastPhase.feedback && state.lastResult != null) {
      _drawFeedback(canvas, size, state.lastResult!);
    }
  }

  void _drawBackground(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFFB8F3FF),
    );
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * 0.78, size.width, size.height * 0.22),
      Paint()..color = const Color(0xFF6FCF97),
    );
    canvas.drawCircle(
      Offset(size.width * 0.84, size.height * 0.12),
      math.min(size.width, size.height) * 0.08,
      Paint()..color = contentPack.theme.secondaryColor,
    );
  }

  void _drawHud(Canvas canvas, Size size) {
    _drawPill(
      canvas,
      const Offset(16, 14),
      '${state.currentPromptIndex + 1}/${contentPack.prompts.length}',
    );
    _drawPill(canvas, Offset(size.width - 118, 14), 'Stars ${state.score}');

    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(18, 58, size.width - 36, 64),
      const Radius.circular(18),
    );
    canvas.drawRRect(
        rect, Paint()..color = Colors.white.withValues(alpha: 0.9));
    _drawText(
      canvas,
      currentPrompt.prompt,
      Offset(size.width / 2, 90),
      maxWidth: size.width - 68,
      fontSize: 21,
      fontWeight: FontWeight.w900,
      textAlign: TextAlign.center,
    );
  }

  void _drawPill(Canvas canvas, Offset offset, String text) {
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(offset.dx, offset.dy, 102, 34),
      const Radius.circular(17),
    );
    canvas.drawRRect(
        rect, Paint()..color = Colors.white.withValues(alpha: 0.92));
    _drawText(
      canvas,
      text,
      Offset(offset.dx + 51, offset.dy + 17),
      maxWidth: 90,
      fontSize: 14,
      fontWeight: FontWeight.w900,
      textAlign: TextAlign.center,
    );
  }

  void _drawBubbles(Canvas canvas, Size size) {
    for (final bubble in state.bubbles) {
      final center = Offset(bubble.x * size.width, bubble.y * size.height);
      final radius = bubble.radius * math.min(size.width, size.height);
      final isSelected = state.lastResult?.selectedAnswerId == bubble.answer.id;
      final isCorrect = bubble.answer.id == currentPrompt.correctAnswerId;
      final popScale = isSelected && state.phase == BubbleBlastPhase.feedback
          ? 1 + state.popProgress * 0.22
          : 1.0;
      final wobble = isSelected &&
              state.phase == BubbleBlastPhase.feedback &&
              !state.lastResult!.isCorrect
          ? math.sin(state.popProgress * math.pi * 4) * 8
          : 0.0;
      final drawnCenter = center.translate(wobble, 0);
      final drawnRadius = radius * popScale;
      final fillColor = state.phase == BubbleBlastPhase.feedback && isCorrect
          ? const Color(0xFFFFD23F).withValues(alpha: 0.84)
          : Colors.white.withValues(alpha: 0.66);

      if (isSelected && state.phase == BubbleBlastPhase.feedback) {
        _drawPopBurst(canvas, drawnCenter, drawnRadius, isCorrect);
      }

      canvas.drawCircle(drawnCenter, drawnRadius, Paint()..color = fillColor);
      canvas.drawCircle(
        drawnCenter.translate(-drawnRadius * 0.25, -drawnRadius * 0.25),
        drawnRadius * 0.28,
        Paint()..color = Colors.white.withValues(alpha: 0.55),
      );
      canvas.drawCircle(
        drawnCenter,
        drawnRadius,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = isSelected ? 6 : 4
          ..color = isSelected && !isCorrect
              ? const Color(0xFFFF7A59)
              : contentPack.theme.primaryColor,
      );
      _drawText(
        canvas,
        bubble.answer.label,
        drawnCenter,
        maxWidth: drawnRadius * 1.5,
        fontSize: math.max(15, drawnRadius * 0.34),
        fontWeight: FontWeight.w900,
        textAlign: TextAlign.center,
      );
    }
  }

  void _drawPopBurst(
    Canvas canvas,
    Offset center,
    double radius,
    bool isCorrect,
  ) {
    final progress = state.popProgress.clamp(0, 1).toDouble();
    final color = isCorrect ? const Color(0xFFFFD23F) : const Color(0xFFFF7A59);
    canvas.drawCircle(
      center,
      radius * (1.05 + progress * 0.42),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5 * (1 - progress)
        ..color = color.withValues(alpha: 0.72 * (1 - progress)),
    );
    if (!isCorrect) {
      return;
    }
    for (var index = 0; index < 8; index++) {
      final angle = math.pi * 2 * index / 8;
      final sparkCenter = center.translate(
        math.cos(angle) * radius * (0.88 + progress * 0.72),
        math.sin(angle) * radius * (0.88 + progress * 0.72),
      );
      canvas.drawCircle(
        sparkCenter,
        math.max(2, radius * 0.08 * (1 - progress * 0.4)),
        Paint()..color = color.withValues(alpha: 0.85 * (1 - progress * 0.3)),
      );
    }
  }

  void _drawLevelComplete(Canvas canvas, Size size) {
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(24, size.height * 0.33, size.width - 48, 110),
      const Radius.circular(18),
    );
    canvas.drawRRect(
      rect,
      Paint()..color = const Color(0xFF151515).withValues(alpha: 0.88),
    );
    _drawText(
      canvas,
      'Level ${state.completedLevel} complete!',
      Offset(size.width / 2, size.height * 0.33 + 36),
      maxWidth: size.width - 80,
      fontSize: 25,
      fontWeight: FontWeight.w900,
      color: Colors.white,
      textAlign: TextAlign.center,
    );
    _drawText(
      canvas,
      'Ready for faster bubbles?',
      Offset(size.width / 2, size.height * 0.33 + 76),
      maxWidth: size.width - 86,
      fontSize: 16,
      fontWeight: FontWeight.w700,
      color: Colors.white,
      textAlign: TextAlign.center,
    );
  }

  void _drawFeedback(Canvas canvas, Size size, BubbleSelectionResult result) {
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(22, size.height * 0.36, size.width - 44, 92),
      const Radius.circular(18),
    );
    canvas.drawRRect(
      rect,
      Paint()..color = const Color(0xFF151515).withValues(alpha: 0.86),
    );
    _drawText(
      canvas,
      result.isCorrect ? 'Pop! Great job!' : 'Good try!',
      Offset(size.width / 2, size.height * 0.36 + 30),
      maxWidth: size.width - 70,
      fontSize: 24,
      fontWeight: FontWeight.w900,
      color: Colors.white,
      textAlign: TextAlign.center,
    );
    _drawText(
      canvas,
      result.feedback,
      Offset(size.width / 2, size.height * 0.36 + 64),
      maxWidth: size.width - 78,
      fontSize: 14,
      fontWeight: FontWeight.w700,
      color: Colors.white,
      textAlign: TextAlign.center,
    );
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset center, {
    required double maxWidth,
    required double fontSize,
    required FontWeight fontWeight,
    Color color = const Color(0xFF151515),
    TextAlign textAlign = TextAlign.left,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: fontWeight,
        ),
      ),
      textAlign: textAlign,
      textDirection: TextDirection.ltr,
      maxLines: 2,
      ellipsis: '...',
    )..layout(maxWidth: maxWidth);

    painter.paint(
      canvas,
      Offset(center.dx - painter.width / 2, center.dy - painter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant BubbleBlastPainter oldDelegate) {
    return oldDelegate.state != state ||
        oldDelegate.currentPrompt.id != currentPrompt.id ||
        oldDelegate.contentPack.id != contentPack.id;
  }
}
