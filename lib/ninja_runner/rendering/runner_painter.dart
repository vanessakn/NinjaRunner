import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../game/runner_controller.dart';
import '../models/content_pack.dart';

class RunnerPainter extends CustomPainter {
  RunnerPainter({
    required this.contentPack,
    required this.state,
    required this.currentPrompt,
  });

  final ContentPack contentPack;
  final RunnerGameState state;
  final RunnerPrompt currentPrompt;

  @override
  void paint(Canvas canvas, Size size) {
    _drawSky(canvas, size);
    _drawTrack(canvas, size);
    _drawHud(canvas, size);
    _drawGates(canvas, size);
    _drawRunner(canvas, size);
    if (state.phase == RunnerPhase.feedback && state.lastResult != null) {
      _drawFeedback(canvas, size, state.lastResult!);
    }
  }

  void _drawSky(Canvas canvas, Size size) {
    final skyPaint = Paint()..color = const Color(0xFF70D6FF);
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height * 0.55),
      skyPaint,
    );

    final sunPaint = Paint()..color = contentPack.theme.secondaryColor;
    canvas.drawCircle(
      Offset(size.width * 0.82, size.height * 0.16),
      34,
      sunPaint,
    );
  }

  void _drawTrack(Canvas canvas, Size size) {
    final groundTop = size.height * 0.52;
    final groundPaint = Paint()..color = contentPack.theme.primaryColor;
    canvas.drawRect(
      Rect.fromLTWH(0, groundTop, size.width, size.height - groundTop),
      groundPaint,
    );

    final stripePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.55)
      ..strokeWidth = 3;
    for (var i = 0; i < 6; i++) {
      final y = groundTop + 28 + i * 24;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), stripePaint);
    }
  }

  void _drawHud(Canvas canvas, Size size) {
    _drawPill(
      canvas,
      const Offset(16, 14),
      '${state.currentPromptIndex + 1}/${contentPack.prompts.length}',
    );
    _drawPill(canvas, Offset(size.width - 118, 14), 'Stars ${state.score}');
    _drawPrompt(canvas, size);
  }

  void _drawPrompt(Canvas canvas, Size size) {
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(20, 58, size.width - 40, 58),
      const Radius.circular(16),
    );
    canvas.drawRRect(
      rect,
      Paint()..color = Colors.white.withValues(alpha: 0.92),
    );
    _drawText(
      canvas,
      currentPrompt.prompt,
      Offset(size.width / 2, 87),
      maxWidth: size.width - 70,
      fontSize: 20,
      fontWeight: FontWeight.w800,
      textAlign: TextAlign.center,
    );
  }

  void _drawPill(Canvas canvas, Offset offset, String text) {
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(offset.dx, offset.dy, 102, 34),
      const Radius.circular(20),
    );
    canvas.drawRRect(
      rect,
      Paint()..color = Colors.white.withValues(alpha: 0.92),
    );
    _drawText(
      canvas,
      text,
      Offset(offset.dx + 51, offset.dy + 17),
      maxWidth: 92,
      fontSize: 14,
      fontWeight: FontWeight.w800,
      textAlign: TextAlign.center,
    );
  }

  void _drawGates(Canvas canvas, Size size) {
    final answers = currentPrompt.answers.take(2).toList();
    final gateY = size.height * 0.54;
    final gateWidth = math.min(132.0, size.width * 0.27);
    final gateHeight = math.min(150.0, size.height * 0.32);
    final centers = [size.width * 0.62, size.width * 0.84];

    for (var i = 0; i < answers.length; i++) {
      final rect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(centers[i], gateY + gateHeight / 2),
          width: gateWidth,
          height: gateHeight,
        ),
        const Radius.circular(16),
      );
      final isCorrect = answers[i].id == currentPrompt.correctAnswerId;
      final color = state.phase == RunnerPhase.feedback && isCorrect
          ? const Color(0xFFFFD23F)
          : Colors.white.withValues(alpha: 0.82);
      canvas.drawRRect(rect, Paint()..color = color);
      canvas.drawRRect(
        rect,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5
          ..color = Colors.white,
      );
      _drawText(
        canvas,
        answers[i].label,
        Offset(centers[i], gateY + gateHeight / 2),
        maxWidth: gateWidth - 18,
        fontSize: 22,
        fontWeight: FontWeight.w900,
        textAlign: TextAlign.center,
      );
    }
  }

  void _drawRunner(Canvas canvas, Size size) {
    final baseX = size.width * (0.15 + state.runnerProgress * 0.34);
    final baseY = size.height * 0.74;
    final bodyPaint = Paint()..color = const Color(0xFFFFD166);
    final outlinePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..color = const Color(0xFF151515);

    final body = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(baseX, baseY), width: 66, height: 88),
      const Radius.circular(18),
    );
    canvas.drawRRect(body, bodyPaint);
    canvas.drawRRect(body, outlinePaint);
    _drawText(
      canvas,
      contentPack.runner.name,
      Offset(baseX, baseY),
      maxWidth: 58,
      fontSize: 13,
      fontWeight: FontWeight.w900,
      textAlign: TextAlign.center,
    );
  }

  void _drawFeedback(Canvas canvas, Size size, RunnerSelectionResult result) {
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(24, size.height * 0.22, size.width - 48, 82),
      const Radius.circular(18),
    );
    canvas.drawRRect(
      rect,
      Paint()..color = const Color(0xFF151515).withValues(alpha: 0.88),
    );
    _drawText(
      canvas,
      result.isCorrect ? 'Great choice!' : 'Good try!',
      Offset(size.width / 2, size.height * 0.22 + 28),
      maxWidth: size.width - 80,
      fontSize: 24,
      fontWeight: FontWeight.w900,
      color: Colors.white,
      textAlign: TextAlign.center,
    );
    _drawText(
      canvas,
      result.feedback,
      Offset(size.width / 2, size.height * 0.22 + 58),
      maxWidth: size.width - 86,
      fontSize: 14,
      fontWeight: FontWeight.w600,
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
  bool shouldRepaint(covariant RunnerPainter oldDelegate) {
    return oldDelegate.state != state ||
        oldDelegate.currentPrompt.id != currentPrompt.id ||
        oldDelegate.contentPack.id != contentPack.id;
  }
}
