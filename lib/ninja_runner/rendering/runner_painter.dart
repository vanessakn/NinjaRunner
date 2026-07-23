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
    _drawBackdrop(canvas, size);
    _drawLane(canvas, size);
    _drawHud(canvas, size);
    _drawGates(canvas, size);
    _drawRunner(canvas, size);
    if (state.phase == RunnerPhase.feedback && state.lastResult != null) {
      _drawFeedback(canvas, size, state.lastResult!);
    }
  }

  void _drawBackdrop(Canvas canvas, Size size) {
    final skyPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF80D8FF),
          Color(0xFFE9F8FF),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height * 0.58));
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height * 0.58),
      skyPaint,
    );

    final sunPaint = Paint()..color = contentPack.theme.secondaryColor;
    canvas.drawCircle(
      Offset(size.width * 0.82, size.height * 0.16),
      math.min(42, size.shortestSide * 0.1),
      sunPaint,
    );

    final farHillPaint = Paint()
      ..color = contentPack.theme.primaryColor.withValues(alpha: 0.22);
    final nearHillPaint = Paint()
      ..color = contentPack.theme.primaryColor.withValues(alpha: 0.38);
    final hillTop = size.height * 0.42;
    canvas.drawOval(
      Rect.fromLTWH(-size.width * 0.16, hillTop, size.width * 0.74, 92),
      farHillPaint,
    );
    canvas.drawOval(
      Rect.fromLTWH(size.width * 0.42, hillTop - 18, size.width * 0.78, 118),
      nearHillPaint,
    );
    _drawThemePlaceholder(canvas, size);
  }

  void _drawThemePlaceholder(Canvas canvas, Size size) {
    final assetId = contentPack.theme.backgroundAssetId;
    switch (assetId) {
      case 'theme-brazil-arena-placeholder':
        _drawBrazilTheme(canvas, size);
      case 'theme-france-arena-placeholder':
        _drawFranceTheme(canvas, size);
      case 'theme-portugal-arena-placeholder':
        _drawPortugalTheme(canvas, size);
      default:
        _drawNeutralTheme(canvas, size);
    }
  }

  void _drawBrazilTheme(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = contentPack.theme.secondaryColor.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5;
    for (var i = 0; i < 3; i++) {
      canvas.drawArc(
        Rect.fromCenter(
          center: Offset(size.width * (0.16 + i * 0.14), size.height * 0.3),
          width: 86,
          height: 36,
        ),
        0,
        math.pi,
        false,
        paint,
      );
    }
  }

  void _drawFranceTheme(Canvas canvas, Size size) {
    final stripeWidth = size.width * 0.055;
    final top = size.height * 0.16;
    final height = size.height * 0.22;
    final colors = [
      const Color(0xFF2867D4).withValues(alpha: 0.42),
      Colors.white.withValues(alpha: 0.62),
      const Color(0xFFE34B5F).withValues(alpha: 0.42),
    ];
    for (var i = 0; i < colors.length; i++) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(32 + i * stripeWidth, top, stripeWidth, height),
          const Radius.circular(10),
        ),
        Paint()..color = colors[i],
      );
    }
  }

  void _drawPortugalTheme(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = contentPack.theme.secondaryColor.withValues(alpha: 0.45);
    for (var i = 0; i < 4; i++) {
      final center = Offset(size.width * (0.18 + i * 0.16), size.height * 0.25);
      _drawStar(canvas, center, 14 + i % 2 * 3, paint);
    }
  }

  void _drawNeutralTheme(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.36)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(Offset(size.width * 0.18, size.height * 0.24), 28, paint);
  }

  void _drawLane(Canvas canvas, Size size) {
    final horizonY = size.height * 0.5;
    final groundPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          contentPack.theme.primaryColor.withValues(alpha: 0.88),
          const Color(0xFF11513A),
        ],
      ).createShader(Rect.fromLTWH(0, horizonY, size.width, size.height));
    canvas.drawRect(
      Rect.fromLTWH(0, horizonY, size.width, size.height - horizonY),
      groundPaint,
    );

    final lanePath = Path()
      ..moveTo(size.width * 0.14, size.height)
      ..lineTo(size.width * 0.4, horizonY)
      ..lineTo(size.width * 0.95, horizonY)
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(
      lanePath,
      Paint()..color = const Color(0xFF263238).withValues(alpha: 0.34),
    );

    final laneBorderPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.78)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    canvas.drawLine(
      Offset(size.width * 0.14, size.height),
      Offset(size.width * 0.4, horizonY),
      laneBorderPaint,
    );
    canvas.drawLine(
      Offset(size.width, size.height),
      Offset(size.width * 0.95, horizonY),
      laneBorderPaint,
    );

    final dashPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.5)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 6; i++) {
      final t = i / 6;
      final y = horizonY + (size.height - horizonY) * math.pow(t, 1.55);
      final leftX = _lerp(size.width * 0.4, size.width * 0.14, t);
      final rightX = _lerp(size.width * 0.95, size.width, t);
      final centerX = (leftX + rightX) / 2;
      final halfWidth = (rightX - leftX) * 0.12;
      canvas.drawLine(
        Offset(centerX - halfWidth, y),
        Offset(centerX + halfWidth, y),
        dashPaint,
      );
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
      Rect.fromLTWH(18, 56, size.width - 36, 68),
      const Radius.circular(14),
    );
    _drawSoftShadow(canvas, rect.outerRect, blur: 12);
    canvas.drawRRect(
      rect,
      Paint()..color = Colors.white.withValues(alpha: 0.96),
    );
    canvas.drawRRect(
      rect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = const Color(0xFF151515).withValues(alpha: 0.08),
    );
    _drawText(
      canvas,
      currentPrompt.prompt,
      Offset(size.width / 2, 90),
      maxWidth: size.width - 70,
      fontSize: 21,
      fontWeight: FontWeight.w800,
      textAlign: TextAlign.center,
    );
  }

  void _drawPill(Canvas canvas, Offset offset, String text) {
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(offset.dx, offset.dy, 102, 34),
      const Radius.circular(20),
    );
    _drawSoftShadow(canvas, rect.outerRect, blur: 8);
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
    final gateY = size.height * 0.52;
    final gateWidth = math.min(138.0, size.width * 0.28);
    final gateHeight = math.min(164.0, size.height * 0.34);
    final centers = [size.width * 0.6, size.width * 0.84];

    for (var i = 0; i < answers.length; i++) {
      final isCorrect = answers[i].id == currentPrompt.correctAnswerId;
      final isSelected = state.lastResult?.selectedAnswerId == answers[i].id;
      final isFeedback = state.phase == RunnerPhase.feedback;
      final rect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(centers[i], gateY + gateHeight / 2),
          width: gateWidth,
          height: gateHeight,
        ),
        const Radius.circular(14),
      );
      final color = isFeedback && isCorrect
          ? const Color(0xFFFFD23F)
          : isFeedback && isSelected
              ? const Color(0xFFFF8A80)
              : Colors.white.withValues(alpha: 0.9);
      _drawSoftShadow(canvas, rect.outerRect, blur: 14);
      canvas.drawRRect(rect, Paint()..color = color);
      canvas.drawRRect(
        rect,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = isSelected ? 7 : 4
          ..color = isSelected
              ? const Color(0xFF151515)
              : Colors.white.withValues(alpha: 0.96),
      );
      canvas.drawLine(
        Offset(rect.left + 10, rect.top + 46),
        Offset(rect.right - 10, rect.top + 46),
        Paint()
          ..color = const Color(0xFF151515).withValues(alpha: 0.12)
          ..strokeWidth = 2,
      );
      _drawText(
        canvas,
        i == 0 ? 'LEFT' : 'RIGHT',
        Offset(centers[i], rect.top + 24),
        maxWidth: gateWidth - 20,
        fontSize: 13,
        fontWeight: FontWeight.w900,
        color: const Color(0xFF151515).withValues(alpha: 0.62),
        textAlign: TextAlign.center,
      );
      _drawText(
        canvas,
        answers[i].label,
        Offset(centers[i], gateY + gateHeight / 2 + 18),
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
    final bounce = state.phase == RunnerPhase.running
        ? math.sin(state.runnerProgress * math.pi * 12) * 4
        : 0.0;
    final runnerCenter = Offset(baseX, baseY + bounce);
    final palette = _characterPalette(contentPack.runner.portraitAssetId);
    final bodyPaint = Paint()..color = palette.shirtColor;
    final outlinePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..color = const Color(0xFF151515);

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(baseX, baseY + 54),
        width: 76,
        height: 18,
      ),
      Paint()..color = const Color(0xFF151515).withValues(alpha: 0.18),
    );

    final body = RRect.fromRectAndRadius(
      Rect.fromCenter(center: runnerCenter, width: 68, height: 82),
      const Radius.circular(18),
    );
    canvas.drawRRect(body, bodyPaint);
    canvas.drawRRect(body, outlinePaint);

    final headCenter = Offset(baseX, runnerCenter.dy - 52);
    canvas.drawCircle(headCenter, 25, Paint()..color = palette.skinColor);
    canvas.drawCircle(headCenter, 25, outlinePaint);
    canvas.drawArc(
      Rect.fromCenter(
          center: headCenter.translate(0, -8), width: 52, height: 34),
      math.pi,
      math.pi,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round
        ..color = palette.hairColor,
    );
    canvas.drawCircle(
      headCenter.translate(-8, 0),
      3,
      Paint()..color = const Color(0xFF151515),
    );
    canvas.drawCircle(
      headCenter.translate(8, 0),
      3,
      Paint()..color = const Color(0xFF151515),
    );
    canvas.drawArc(
      Rect.fromCenter(
          center: headCenter.translate(0, 7), width: 18, height: 10),
      0,
      math.pi,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = const Color(0xFF151515),
    );

    final limbPaint = Paint()
      ..color = const Color(0xFF151515)
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      runnerCenter.translate(-34, -8),
      runnerCenter.translate(-52, 12),
      limbPaint,
    );
    canvas.drawLine(
      runnerCenter.translate(34, -8),
      runnerCenter.translate(52, -24),
      limbPaint,
    );
    canvas.drawLine(
      runnerCenter.translate(-18, 40),
      runnerCenter.translate(-34, 62),
      limbPaint,
    );
    canvas.drawLine(
      runnerCenter.translate(18, 40),
      runnerCenter.translate(40, 58),
      limbPaint,
    );

    _drawText(
      canvas,
      contentPack.runner.name,
      runnerCenter.translate(0, 5),
      maxWidth: 58,
      fontSize: 13,
      fontWeight: FontWeight.w900,
      textAlign: TextAlign.center,
    );
  }

  void _drawFeedback(Canvas canvas, Size size, RunnerSelectionResult result) {
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(24, size.height * 0.2, size.width - 48, 98),
      const Radius.circular(18),
    );
    _drawSoftShadow(canvas, rect.outerRect, blur: 18);
    canvas.drawRRect(
      rect,
      Paint()
        ..color = (result.isCorrect
                ? const Color(0xFF151515)
                : const Color(0xFF3B2B20))
            .withValues(alpha: 0.9),
    );
    _drawText(
      canvas,
      result.isCorrect ? 'Great choice!' : 'Good try!',
      Offset(size.width / 2, size.height * 0.2 + 30),
      maxWidth: size.width - 80,
      fontSize: 24,
      fontWeight: FontWeight.w900,
      color: Colors.white,
      textAlign: TextAlign.center,
    );
    _drawText(
      canvas,
      result.feedback,
      Offset(size.width / 2, size.height * 0.2 + 68),
      maxWidth: size.width - 86,
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: Colors.white,
      textAlign: TextAlign.center,
    );
  }

  void _drawSoftShadow(
    Canvas canvas,
    Rect rect, {
    required double blur,
  }) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        rect.shift(const Offset(0, 5)),
        const Radius.circular(18),
      ),
      Paint()
        ..color = const Color(0xFF151515).withValues(alpha: 0.18)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, blur),
    );
  }

  double _lerp(double start, double end, double t) {
    return start + (end - start) * t;
  }

  void _drawStar(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    for (var i = 0; i < 10; i++) {
      final angle = -math.pi / 2 + i * math.pi / 5;
      final pointRadius = i.isEven ? radius : radius * 0.45;
      final point = Offset(
        center.dx + math.cos(angle) * pointRadius,
        center.dy + math.sin(angle) * pointRadius,
      );
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  _CharacterPalette _characterPalette(String? portraitAssetId) {
    return switch (portraitAssetId) {
      'character-nari-placeholder' => const _CharacterPalette(
          shirtColor: Color(0xFF80D8FF),
          skinColor: Color(0xFFFFD0A6),
          hairColor: Color(0xFF171717),
        ),
      'character-arjun-placeholder' => const _CharacterPalette(
          shirtColor: Color(0xFFE53B44),
          skinColor: Color(0xFFD99A6C),
          hairColor: Color(0xFF2E1B12),
        ),
      _ => const _CharacterPalette(
          shirtColor: Color(0xFFFFD166),
          skinColor: Color(0xFFFFC49B),
          hairColor: Color(0xFF402218),
        ),
    };
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
        oldDelegate.currentPrompt != currentPrompt ||
        oldDelegate.contentPack != contentPack;
  }
}

class _CharacterPalette {
  const _CharacterPalette({
    required this.shirtColor,
    required this.skinColor,
    required this.hairColor,
  });

  final Color shirtColor;
  final Color skinColor;
  final Color hairColor;
}
