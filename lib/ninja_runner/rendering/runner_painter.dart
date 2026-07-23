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
    _drawPickups(canvas, size);
    _drawHud(canvas, size);
    _drawGates(canvas, size);
    _drawProgressCue(canvas, size);
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
      case 'theme-argentina-arena-placeholder':
        _drawArgentinaTheme(canvas, size);
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

  void _drawArgentinaTheme(Canvas canvas, Size size) {
    final stripePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.72)
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 3; i++) {
      final y = size.height * (0.19 + i * 0.05);
      canvas.drawLine(
        Offset(size.width * 0.12, y),
        Offset(size.width * 0.55, y),
        stripePaint,
      );
    }
    _drawStar(
      canvas,
      Offset(size.width * 0.36, size.height * 0.32),
      18,
      Paint()..color = const Color(0xFFFFD23F).withValues(alpha: 0.65),
    );
  }

  void _drawNeutralTheme(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.36)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(Offset(size.width * 0.18, size.height * 0.24), 28, paint);
  }

  void _drawLane(Canvas canvas, Size size) {
    final playWidth = _playWidth(size);
    final horizonY = size.height * 0.36;
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
      ..moveTo(playWidth * 0.12, size.height)
      ..lineTo(playWidth * 0.34, horizonY)
      ..lineTo(playWidth * 0.66, horizonY)
      ..lineTo(playWidth * 0.88, size.height)
      ..close();
    canvas.drawPath(
      lanePath,
      Paint()..color = const Color(0xFF263238).withValues(alpha: 0.34),
    );
    canvas.drawPath(
      lanePath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withValues(alpha: 0.08),
            contentPack.theme.secondaryColor.withValues(alpha: 0.1),
          ],
        ).createShader(Rect.fromLTWH(0, horizonY, size.width, size.height)),
    );

    final laneBorderPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.78)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    canvas.drawLine(
      Offset(playWidth * 0.12, size.height),
      Offset(playWidth * 0.34, horizonY),
      laneBorderPaint,
    );
    canvas.drawLine(
      Offset(playWidth * 0.88, size.height),
      Offset(playWidth * 0.66, horizonY),
      laneBorderPaint,
    );

    final dashPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.5)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 6; i++) {
      final t = ((i / 6) + state.runnerProgress * 0.8) % 1;
      final y = horizonY + (size.height - horizonY) * math.pow(t, 1.55);
      final leftX = _lerp(playWidth * 0.34, playWidth * 0.12, t);
      final rightX = _lerp(playWidth * 0.66, playWidth * 0.88, t);
      final centerX = (leftX + rightX) / 2;
      final halfWidth = (rightX - leftX) * 0.18;
      canvas.drawLine(
        Offset(centerX - halfWidth, y),
        Offset(centerX + halfWidth, y),
        dashPaint,
      );
    }
  }

  void _drawPickups(Canvas canvas, Size size) {
    final playWidth = _playWidth(size);
    final pickupPaint = Paint()..color = const Color(0xFFFFD23F);
    final sparklePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.82)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 4; i++) {
      final t = ((i + 1) / 5 + state.runnerProgress * 0.52) % 1;
      final y = _lerp(size.height * 0.4, size.height * 0.88, t);
      final laneCenter = playWidth * 0.5;
      final side = i.isEven ? -1.0 : 1.0;
      final x = laneCenter + side * _lerp(18, 58, t);
      _drawStar(canvas, Offset(x, y), _lerp(7, 14, t), pickupPaint);
      canvas.drawLine(Offset(x - 12, y), Offset(x - 18, y), sparklePaint);
      canvas.drawLine(Offset(x + 12, y), Offset(x + 18, y), sparklePaint);
    }
  }

  void _drawHud(Canvas canvas, Size size) {
    final playWidth = _playWidth(size);
    _drawPill(
      canvas,
      const Offset(16, 14),
      '${state.currentPromptIndex + 1}/${contentPack.prompts.length}',
    );
    _drawPill(canvas, Offset(playWidth - 118, 14), 'Stars ${state.score}');
    _drawPrompt(canvas, size);
  }

  void _drawPrompt(Canvas canvas, Size size) {
    final playWidth = _playWidth(size);
    final scale = _sceneScale(size);
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(16, 52, playWidth - 32, 72 * scale),
      const Radius.circular(16),
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
      Offset(playWidth / 2, 52 + 36 * scale),
      maxWidth: playWidth - 76,
      fontSize: 20 * scale,
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
    final playWidth = _playWidth(size);
    final scale = _sceneScale(size);
    final answers = currentPrompt.answers.take(2).toList();
    final gateY = size.height * 0.34;
    final gateWidth = math.min(132.0, playWidth * 0.3) * scale;
    final gateHeight = math.min(150.0, size.height * 0.27) * scale;
    final centers = [playWidth * 0.3, playWidth * 0.62];

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
      final portalRect = rect.inflate(8);
      canvas.drawRRect(
        portalRect,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 6
          ..color = contentPack.theme.secondaryColor.withValues(alpha: 0.34),
      );
      final color = isFeedback && isCorrect
          ? const Color(0xFFFFD23F)
          : isFeedback && isSelected
              ? const Color(0xFFFFB4A8)
              : i == 0
                  ? const Color(0xFFFFFFFF).withValues(alpha: 0.94)
                  : const Color(0xFFF4FAFF).withValues(alpha: 0.94);
      if (isFeedback && (isCorrect || isSelected)) {
        canvas.drawRRect(
          rect.inflate(isCorrect ? 9 : 5),
          Paint()
            ..color =
                (isCorrect ? const Color(0xFFFFD23F) : const Color(0xFFFF8A80))
                    .withValues(alpha: 0.36)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16),
        );
      }
      _drawSoftShadow(canvas, rect.outerRect, blur: 16);
      canvas.drawRRect(rect, Paint()..color = color);
      canvas.drawRRect(
        rect,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = isFeedback && isCorrect
              ? 7
              : isSelected
                  ? 6
                  : 4
          ..color = isFeedback && isCorrect
              ? const Color(0xFF13794A)
              : isSelected
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
      _drawGateWarningStripe(canvas, rect, i);
      _drawText(
        canvas,
        i == 0 ? 'LEFT' : 'RIGHT',
        Offset(centers[i], rect.top + 23 * scale),
        maxWidth: gateWidth - 20,
        fontSize: 13 * scale,
        fontWeight: FontWeight.w900,
        color: const Color(0xFF151515).withValues(alpha: 0.62),
        textAlign: TextAlign.center,
      );
      _drawText(
        canvas,
        answers[i].label,
        Offset(centers[i], gateY + gateHeight / 2 + 18 * scale),
        maxWidth: gateWidth - 18,
        fontSize: 24 * scale,
        fontWeight: FontWeight.w900,
        textAlign: TextAlign.center,
      );
    }
  }

  void _drawGateWarningStripe(Canvas canvas, RRect rect, int index) {
    final stripePaint = Paint()
      ..color = (index == 0 ? const Color(0xFF13794A) : const Color(0xFF1C6EA4))
          .withValues(alpha: 0.18)
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    for (var x = rect.left + 12; x < rect.right - 8; x += 18) {
      canvas.drawLine(
        Offset(x, rect.bottom - 24),
        Offset(x + 10, rect.bottom - 12),
        stripePaint,
      );
    }
  }

  void _drawProgressCue(Canvas canvas, Size size) {
    final playWidth = _playWidth(size);
    final track = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        playWidth * 0.91,
        size.height * 0.36,
        8,
        size.height * 0.5,
      ),
      const Radius.circular(8),
    );
    canvas.drawRRect(
      track,
      Paint()..color = Colors.white.withValues(alpha: 0.35),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          track.left,
          track.bottom - track.height * state.runnerProgress.clamp(0, 1),
          track.width,
          track.height * state.runnerProgress.clamp(0, 1),
        ),
        const Radius.circular(8),
      ),
      Paint()..color = contentPack.theme.secondaryColor,
    );
    if (state.streak > 0) {
      _drawText(
        canvas,
        'BOOST x${state.streak}',
        Offset(playWidth / 2, size.height * 0.33),
        maxWidth: playWidth * 0.5,
        fontSize: 13,
        fontWeight: FontWeight.w900,
        color: const Color(0xFF151515),
        textAlign: TextAlign.center,
      );
    }
  }

  void _drawRunner(Canvas canvas, Size size) {
    final playWidth = _playWidth(size);
    final scale = _sceneScale(size);
    final baseX = playWidth * 0.5;
    final baseY = _lerp(size.height * 0.84, size.height * 0.6,
        state.runnerProgress.clamp(0, 1));
    final bounce = state.phase == RunnerPhase.running
        ? math.sin(state.runnerProgress * math.pi * 12) * 4
        : 0.0;
    final armSwing = state.phase == RunnerPhase.running
        ? math.sin(state.runnerProgress * math.pi * 12) * 8
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
        width: 76 * scale,
        height: 18 * scale,
      ),
      Paint()..color = const Color(0xFF151515).withValues(alpha: 0.18),
    );
    if (state.streak > 0 || state.lastResult?.isCorrect == true) {
      final boostPaint = Paint()
        ..color = contentPack.theme.secondaryColor.withValues(alpha: 0.28)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(baseX - 26, baseY + 16),
          width: (70 + state.streak * 6) * scale,
          height: 36 * scale,
        ),
        boostPaint,
      );
    }

    final body = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: runnerCenter,
        width: 68 * scale,
        height: 82 * scale,
      ),
      const Radius.circular(18),
    );
    canvas.drawRRect(body, bodyPaint);
    canvas.drawRRect(body, outlinePaint);

    final headCenter = Offset(baseX, runnerCenter.dy - 52 * scale);
    canvas.drawCircle(
        headCenter, 25 * scale, Paint()..color = palette.skinColor);
    canvas.drawCircle(headCenter, 25 * scale, outlinePaint);
    canvas.drawArc(
      Rect.fromCenter(
        center: headCenter.translate(0, -8 * scale),
        width: 52 * scale,
        height: 34 * scale,
      ),
      math.pi,
      math.pi,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8 * scale
        ..strokeCap = StrokeCap.round
        ..color = palette.hairColor,
    );
    canvas.drawCircle(
      headCenter.translate(-8, 0),
      3 * scale,
      Paint()..color = const Color(0xFF151515),
    );
    canvas.drawCircle(
      headCenter.translate(8, 0),
      3 * scale,
      Paint()..color = const Color(0xFF151515),
    );
    canvas.drawArc(
      Rect.fromCenter(
        center: headCenter.translate(0, 7 * scale),
        width: 18 * scale,
        height: 10 * scale,
      ),
      0,
      math.pi,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2 * scale
        ..color = const Color(0xFF151515),
    );

    final limbPaint = Paint()
      ..color = const Color(0xFF151515)
      ..strokeWidth = 5 * scale
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      runnerCenter.translate(-34 * scale, -8 * scale),
      runnerCenter.translate(-52 * scale, (12 + armSwing) * scale),
      limbPaint,
    );
    canvas.drawLine(
      runnerCenter.translate(34 * scale, -8 * scale),
      runnerCenter.translate(52 * scale, (-24 - armSwing) * scale),
      limbPaint,
    );
    canvas.drawLine(
      runnerCenter.translate(-18 * scale, 40 * scale),
      runnerCenter.translate(-34 * scale, (62 - armSwing / 2) * scale),
      limbPaint,
    );
    canvas.drawLine(
      runnerCenter.translate(18 * scale, 40 * scale),
      runnerCenter.translate(40 * scale, (58 + armSwing / 2) * scale),
      limbPaint,
    );

    _drawText(
      canvas,
      contentPack.runner.name,
      runnerCenter.translate(0, 5 * scale),
      maxWidth: 58,
      fontSize: 13 * scale,
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
      result.isCorrect ? 'Streak Boost!' : 'Slow down!',
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

  double _sceneScale(Size size) {
    return (size.height / 420).clamp(0.68, 1).toDouble();
  }

  double _playWidth(Size size) {
    if (size.width <= 560) {
      return math.min(size.width, 336);
    }
    return size.width;
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
      'character-bjorn-placeholder' => const _CharacterPalette(
          shirtColor: Color(0xFF5CB8E4),
          skinColor: Color(0xFFFFD0A6),
          hairColor: Color(0xFFE9B66D),
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
