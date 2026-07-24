import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../game/runner_controller.dart';
import '../models/content_pack.dart';
import 'gate_feedback_style.dart';
import 'kidnation_visual_theme.dart';
import 'runner_motion.dart';

class RunnerPainter extends CustomPainter {
  RunnerPainter({
    required this.contentPack,
    required this.state,
    required this.currentPrompt,
    this.runnerImage,
    this.backgroundImage,
    this.brandBackgroundImage,
    this.brandLogoImage,
    this.visualRunCycleProgress = 0,
  });

  final ContentPack contentPack;
  final RunnerGameState state;
  final RunnerPrompt currentPrompt;
  final ui.Image? runnerImage;
  final ui.Image? backgroundImage;
  final ui.Image? brandBackgroundImage;
  final ui.Image? brandLogoImage;
  final double visualRunCycleProgress;

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
    final fullRect = Offset.zero & size;
    if (brandBackgroundImage case final image?) {
      _drawCoverImage(canvas, image, fullRect, FilterQuality.medium);
    } else {
      canvas.drawRect(
        fullRect,
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              KidNationVisualTheme.backgroundTop,
              KidNationVisualTheme.backgroundBottom,
            ],
          ).createShader(fullRect),
      );
    }

    canvas.drawRect(
      fullRect,
      Paint()
        ..color = KidNationVisualTheme.backgroundBottom.withValues(alpha: 0.24),
    );
    canvas.drawCircle(
      Offset(size.width * 0.82, size.height * 0.18),
      math.min(72, size.shortestSide * 0.18),
      Paint()
        ..color = KidNationVisualTheme.yellow.withValues(alpha: 0.22)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18),
    );
    canvas.drawCircle(
      Offset(size.width * 0.18, size.height * 0.24),
      math.min(54, size.shortestSide * 0.14),
      Paint()
        ..color = KidNationVisualTheme.secondary.withValues(alpha: 0.2)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18),
    );

    final playWidth = _playWidth(size);
    final stageRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(10, 44, playWidth - 20, size.height - 58),
      const Radius.circular(26),
    );
    canvas.drawRRect(
      stageRect,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.08)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
    );
    canvas.drawRRect(
      stageRect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = Colors.white.withValues(alpha: 0.2),
    );

    if (backgroundImage case final image?) {
      final themeRect = Rect.fromLTWH(
        20,
        size.height * 0.17,
        playWidth - 40,
        size.height * 0.24,
      );
      canvas.saveLayer(themeRect, Paint());
      _drawCoverImage(canvas, image, themeRect, FilterQuality.medium);
      canvas.drawRect(
        themeRect,
        Paint()
          ..color = KidNationVisualTheme.backgroundTop.withValues(alpha: 0.56),
      );
      canvas.restore();
    } else {
      _drawThemePlaceholder(canvas, size);
    }

    _drawBrandLogo(canvas, size);
  }

  void _drawCoverImage(
    Canvas canvas,
    ui.Image image,
    Rect target,
    FilterQuality filterQuality,
  ) {
    final imageSize = Size(image.width.toDouble(), image.height.toDouble());
    final fitted = applyBoxFit(BoxFit.cover, imageSize, target.size);
    final source = Alignment.center.inscribe(
      fitted.source,
      Offset.zero & imageSize,
    );
    final destination = Alignment.center.inscribe(fitted.destination, target);
    canvas.drawImageRect(
      image,
      source,
      destination,
      Paint()..filterQuality = filterQuality,
    );
  }

  void _drawBrandLogo(Canvas canvas, Size size) {
    if (brandLogoImage case final logo?) {
      final logoWidth = math.min(54.0, size.width * 0.14);
      final imageSize = Size(logo.width.toDouble(), logo.height.toDouble());
      final target = Rect.fromLTWH(
        size.width - logoWidth - 16,
        10,
        logoWidth,
        logoWidth * imageSize.height / imageSize.width,
      );
      canvas.drawImageRect(
        logo,
        Offset.zero & imageSize,
        target,
        Paint()..filterQuality = FilterQuality.high,
      );
      return;
    }
    _drawText(
      canvas,
      'KN',
      Offset(size.width - 38, 28),
      maxWidth: 42,
      fontSize: 18,
      fontWeight: FontWeight.w900,
      color: Colors.white,
      textAlign: TextAlign.center,
    );
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
    final horizonY = size.height * 0.39;
    final groundRect = Rect.fromLTWH(0, horizonY, size.width, size.height);
    final groundPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          KidNationVisualTheme.stagePurple,
          KidNationVisualTheme.navPurple,
        ],
      ).createShader(groundRect);
    canvas.drawRect(
      Rect.fromLTWH(0, horizonY, size.width, size.height - horizonY),
      groundPaint,
    );

    final glowPath = Path()
      ..moveTo(playWidth * 0.02, size.height)
      ..lineTo(playWidth * 0.38, horizonY - 8)
      ..lineTo(playWidth * 0.62, horizonY - 8)
      ..lineTo(playWidth * 0.98, size.height)
      ..close();
    canvas.drawPath(
      glowPath,
      Paint()
        ..color = KidNationVisualTheme.secondary.withValues(alpha: 0.2)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18),
    );

    final lanePath = Path()
      ..moveTo(playWidth * 0.1, size.height)
      ..lineTo(playWidth * 0.36, horizonY)
      ..lineTo(playWidth * 0.64, horizonY)
      ..lineTo(playWidth * 0.9, size.height)
      ..close();
    canvas.drawPath(
      lanePath,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [KidNationVisualTheme.cream, KidNationVisualTheme.gold],
        ).createShader(groundRect),
    );
    canvas.drawPath(
      lanePath,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0x00FFFFFF), Color(0x44D13493)],
        ).createShader(groundRect),
    );

    final laneBorderPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5;
    canvas.drawLine(
      Offset(playWidth * 0.1, size.height),
      Offset(playWidth * 0.36, horizonY),
      laneBorderPaint,
    );
    canvas.drawLine(
      Offset(playWidth * 0.9, size.height),
      Offset(playWidth * 0.64, horizonY),
      laneBorderPaint,
    );

    final dashPaint = Paint()
      ..color = KidNationVisualTheme.primary.withValues(alpha: 0.34)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 6; i++) {
      final t = ((i / 6) + state.runnerProgress * 0.8) % 1;
      final y = horizonY + (size.height - horizonY) * math.pow(t, 1.55);
      final leftX = _lerp(playWidth * 0.36, playWidth * 0.1, t);
      final rightX = _lerp(playWidth * 0.64, playWidth * 0.9, t);
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
    final pickupPaint = Paint()..color = KidNationVisualTheme.gold;
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
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            KidNationVisualTheme.secondary,
            KidNationVisualTheme.primary,
          ],
        ).createShader(rect.outerRect),
    );
    canvas.drawRRect(
      rect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = Colors.white.withValues(alpha: 0.3),
    );
    _drawText(
      canvas,
      currentPrompt.prompt,
      Offset(playWidth / 2, 52 + 36 * scale),
      maxWidth: playWidth - 76,
      fontSize: 20 * scale,
      fontWeight: FontWeight.w800,
      color: Colors.white,
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
      Paint()..color = KidNationVisualTheme.yellow.withValues(alpha: 0.96),
    );
    canvas.drawRRect(
      rect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = Colors.white.withValues(alpha: 0.48),
    );
    _drawText(
      canvas,
      text,
      Offset(offset.dx + 51, offset.dy + 17),
      maxWidth: 92,
      fontSize: 14,
      fontWeight: FontWeight.w800,
      color: KidNationVisualTheme.deepPurple,
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
    final selectedAnswerWasCorrect = state.lastResult?.isCorrect == true;

    for (var i = 0; i < answers.length; i++) {
      final isCorrect = answers[i].id == currentPrompt.correctAnswerId;
      final isSelected = state.lastResult?.selectedAnswerId == answers[i].id;
      final isFeedback = state.phase == RunnerPhase.feedback;
      final style = GateFeedbackStyle.resolve(
        gateIndex: i,
        isFeedback: isFeedback,
        isCorrect: isCorrect,
        isSelected: isSelected,
        selectedAnswerWasCorrect: selectedAnswerWasCorrect,
        scale: scale,
      );
      final center =
          Offset(centers[i], gateY + gateHeight / 2) + style.shakeOffset;
      final rect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: center,
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
          ..color = style.portalColor,
      );
      if (style.tone != GateFeedbackTone.neutral) {
        canvas.drawRRect(
          rect.inflate(style.tone == GateFeedbackTone.correctSelected ? 11 : 7),
          Paint()
            ..color = style.glowColor
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16),
        );
      }
      _drawSoftShadow(canvas, rect.outerRect, blur: 16);
      canvas.drawRRect(rect, Paint()..color = style.fillColor);
      canvas.drawRRect(
        rect,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = style.strokeWidth
          ..color = style.strokeColor,
      );
      canvas.drawLine(
        Offset(rect.left + 10, rect.top + 46),
        Offset(rect.right - 10, rect.top + 46),
        Paint()
          ..color = const Color(0xFF151515).withValues(alpha: 0.12)
          ..strokeWidth = 2,
      );
      _drawGateWarningStripe(canvas, rect, i);
      canvas.drawCircle(
        Offset(center.dx, rect.top + 47 * scale),
        13 * scale,
        Paint()..color = KidNationVisualTheme.yellow.withValues(alpha: 0.9),
      );
      _drawText(
        canvas,
        i == 0 ? 'L' : 'R',
        Offset(center.dx, rect.top + 47 * scale),
        maxWidth: 22,
        fontSize: 14 * scale,
        fontWeight: FontWeight.w900,
        color: KidNationVisualTheme.deepPurple,
        textAlign: TextAlign.center,
      );
      _drawText(
        canvas,
        i == 0 ? 'LEFT' : 'RIGHT',
        Offset(center.dx, rect.top + 23 * scale),
        maxWidth: gateWidth - 20,
        fontSize: 13 * scale,
        fontWeight: FontWeight.w900,
        color: const Color(0xFF151515).withValues(alpha: 0.62),
        textAlign: TextAlign.center,
      );
      _drawText(
        canvas,
        answers[i].label,
        Offset(center.dx, gateY + gateHeight / 2 + 18 * scale),
        maxWidth: gateWidth - 18,
        fontSize: 24 * scale,
        fontWeight: FontWeight.w900,
        color: style.labelColor,
        textAlign: TextAlign.center,
      );
      if (style.badgeLabel case final badge?) {
        _drawGateBadge(canvas, rect, badge, style);
      }
    }
  }

  void _drawGateBadge(
    Canvas canvas,
    RRect gateRect,
    String label,
    GateFeedbackStyle style,
  ) {
    final badgeRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(gateRect.outerRect.center.dx, gateRect.top - 8),
        width: math.min(gateRect.width - 10, 88),
        height: 24,
      ),
      const Radius.circular(12),
    );
    canvas.drawRRect(
      badgeRect,
      Paint()
        ..color = style.tone == GateFeedbackTone.wrongSelected
            ? const Color(0xFFFFF0F2)
            : Colors.white.withValues(alpha: 0.95),
    );
    canvas.drawRRect(
      badgeRect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = style.strokeColor.withValues(alpha: 0.72),
    );
    _drawText(
      canvas,
      label,
      badgeRect.outerRect.center,
      maxWidth: badgeRect.width - 10,
      fontSize: 10,
      fontWeight: FontWeight.w900,
      color: style.labelColor,
      textAlign: TextAlign.center,
    );
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
      Rect.fromLTWH(playWidth * 0.91, size.height * 0.36, 8, size.height * 0.5),
      const Radius.circular(8),
    );
    canvas.drawRRect(
      track,
      Paint()..color = Colors.white.withValues(alpha: 0.24),
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
      Paint()..color = KidNationVisualTheme.yellow,
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
    final scale = _sceneScale(size);
    final dodgeDirection = _selectedDodgeDirection();
    final dodgeProgress = state.phase == RunnerPhase.feedback
        ? (visualRunCycleProgress / 0.55).clamp(0, 1).toDouble()
        : 1.0;
    final motion = RunnerMotion.calculate(
      size: size,
      progress: state.runnerProgress,
      strideProgress: state.runnerProgress + visualRunCycleProgress,
      isRunning: state.phase == RunnerPhase.running,
      hasPositiveFeedback:
          state.streak > 0 || state.lastResult?.isCorrect == true,
      streak: state.streak,
      dodgeDirection: dodgeDirection,
      dodgeProgress: dodgeProgress,
      feedbackPose: _runnerFeedbackPose(),
    );
    final isRunnerInMotion =
        state.phase == RunnerPhase.running || dodgeDirection != 0;
    final armSwing = isRunnerInMotion
        ? math.sin(
              (state.runnerProgress + visualRunCycleProgress) * math.pi * 12,
            ) *
            8
        : 0.0;
    final runnerCenter = motion.runnerCenter;
    final palette = _characterPalette(contentPack.runner.portraitAssetId);
    _drawRunnerDodgeTrail(canvas, motion, scale);
    _drawRunnerBoost(canvas, motion, scale);
    if (runnerImage case final image?) {
      _drawRunnerImage(canvas, motion, image);
      return;
    }
    final bodyPaint = Paint()..color = palette.shirtColor;
    final outlinePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..color = const Color(0xFF151515);

    canvas.drawOval(
      motion.shadowRect,
      Paint()..color = const Color(0xFF151515).withValues(alpha: 0.18),
    );

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

    final headCenter = Offset(runnerCenter.dx, runnerCenter.dy - 52 * scale);
    canvas.drawCircle(
      headCenter,
      25 * scale,
      Paint()..color = palette.skinColor,
    );
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
      runnerCenter.translate(
        -34 * scale - motion.legStride * 0.32,
        (62 - armSwing / 2) * scale - motion.leftFootLift,
      ),
      limbPaint,
    );
    canvas.drawLine(
      runnerCenter.translate(18 * scale, 40 * scale),
      runnerCenter.translate(
        40 * scale + motion.legStride * 0.32,
        (58 + armSwing / 2) * scale - motion.rightFootLift,
      ),
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

  void _drawRunnerImage(Canvas canvas, RunnerMotion motion, ui.Image image) {
    canvas.drawOval(
      motion.shadowRect,
      Paint()..color = const Color(0xFF151515).withValues(alpha: 0.18),
    );
    final imageSize = Size(image.width.toDouble(), image.height.toDouble());
    final fitted = applyBoxFit(
      BoxFit.contain,
      imageSize,
      motion.spriteRect.size,
    );
    final source = Alignment.center.inscribe(
      fitted.source,
      Offset.zero & imageSize,
    );
    final destination = Alignment.center.inscribe(
      fitted.destination,
      Rect.fromLTWH(0, 0, motion.spriteRect.width, motion.spriteRect.height),
    );
    canvas.save();
    canvas.translate(motion.spriteRect.center.dx, motion.spriteRect.center.dy);
    canvas.rotate(motion.leanRadians);
    canvas.scale(motion.feedbackScale);
    final paint = Paint()..filterQuality = FilterQuality.high;
    final centeredDestination = destination.shift(-destination.center);
    if (motion.legStride.abs() < 0.1 &&
        motion.leftFootLift < 0.1 &&
        motion.rightFootLift < 0.1) {
      canvas.drawImageRect(image, source, centeredDestination, paint);
    } else {
      _drawRunnerImageWithStride(
        canvas,
        image,
        source,
        centeredDestination,
        motion,
        paint,
      );
    }
    canvas.restore();
  }

  void _drawRunnerImageWithStride(
    Canvas canvas,
    ui.Image image,
    Rect source,
    Rect destination,
    RunnerMotion motion,
    Paint paint,
  ) {
    final upperBottom = destination.top + destination.height * 0.66;
    final legsTop = destination.top + destination.height * 0.54;
    final upperDestination = Rect.fromLTRB(
      destination.left,
      destination.top,
      destination.right,
      upperBottom,
    );
    final legsDestination = Rect.fromLTRB(
      destination.left,
      legsTop,
      destination.right,
      destination.bottom,
    );
    final overlap = destination.width * 0.045;
    final leftLegDestination = Rect.fromLTRB(
      legsDestination.left,
      legsDestination.top,
      legsDestination.center.dx + overlap,
      legsDestination.bottom,
    );
    final rightLegDestination = Rect.fromLTRB(
      legsDestination.center.dx - overlap,
      legsDestination.top,
      legsDestination.right,
      legsDestination.bottom,
    );

    _drawShiftedRunnerSlice(
      canvas,
      image,
      source,
      destination,
      leftLegDestination,
      Offset(-motion.legStride * 0.42, -motion.leftFootLift),
      motion.legStride * 0.0018,
      paint,
    );
    _drawShiftedRunnerSlice(
      canvas,
      image,
      source,
      destination,
      rightLegDestination,
      Offset(motion.legStride * 0.42, -motion.rightFootLift),
      -motion.legStride * 0.0018,
      paint,
    );
    _drawRunnerImageSlice(
      canvas,
      image,
      _mapDestinationSliceToSource(upperDestination, destination, source),
      upperDestination,
      paint,
    );
  }

  void _drawShiftedRunnerSlice(
    Canvas canvas,
    ui.Image image,
    Rect fullSource,
    Rect fullDestination,
    Rect sliceDestination,
    Offset offset,
    double rotation,
    Paint paint,
  ) {
    canvas.save();
    canvas.clipRect(sliceDestination.inflate(10));
    final pivot = Offset(sliceDestination.center.dx, sliceDestination.top);
    canvas.translate(pivot.dx, pivot.dy);
    canvas.rotate(rotation);
    canvas.translate(-pivot.dx + offset.dx, -pivot.dy + offset.dy);
    _drawRunnerImageSlice(
      canvas,
      image,
      _mapDestinationSliceToSource(
        sliceDestination,
        fullDestination,
        fullSource,
      ),
      sliceDestination,
      paint,
    );
    canvas.restore();
  }

  void _drawRunnerImageSlice(
    Canvas canvas,
    ui.Image image,
    Rect source,
    Rect destination,
    Paint paint,
  ) {
    canvas.drawImageRect(image, source, destination, paint);
  }

  Rect _mapDestinationSliceToSource(
    Rect slice,
    Rect fullDestination,
    Rect fullSource,
  ) {
    final leftT = (slice.left - fullDestination.left) / fullDestination.width;
    final topT = (slice.top - fullDestination.top) / fullDestination.height;
    final rightT = (slice.right - fullDestination.left) / fullDestination.width;
    final bottomT =
        (slice.bottom - fullDestination.top) / fullDestination.height;
    return Rect.fromLTRB(
      fullSource.left + fullSource.width * leftT,
      fullSource.top + fullSource.height * topT,
      fullSource.left + fullSource.width * rightT,
      fullSource.top + fullSource.height * bottomT,
    );
  }

  void _drawRunnerBoost(Canvas canvas, RunnerMotion motion, double scale) {
    if (motion.celebrationBursts.isEmpty) {
      return;
    }
    final boostPaint = Paint()
      ..color = contentPack.theme.secondaryColor.withValues(alpha: 0.28)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawOval(motion.boostTrailRect, boostPaint);

    final sparklePaint = Paint()..color = contentPack.theme.secondaryColor;
    for (final burst in motion.celebrationBursts) {
      _drawStar(canvas, burst, 7 * scale, sparklePaint);
    }
  }

  void _drawRunnerDodgeTrail(Canvas canvas, RunnerMotion motion, double scale) {
    if (motion.dodgeTrailRect.isEmpty) {
      return;
    }
    final trailPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          contentPack.theme.secondaryColor.withValues(alpha: 0.04),
          contentPack.theme.secondaryColor.withValues(alpha: 0.2),
          Colors.white.withValues(alpha: 0.26),
        ],
      ).createShader(motion.dodgeTrailRect)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawOval(motion.dodgeTrailRect, trailPaint);

    final tickPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.5)
      ..strokeWidth = 2 * scale
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      motion.dodgeTrailRect.centerLeft.translate(8 * scale, 0),
      motion.dodgeTrailRect.center.translate(-4 * scale, -5 * scale),
      tickPaint,
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

  void _drawSoftShadow(Canvas canvas, Rect rect, {required double blur}) {
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

  double _selectedDodgeDirection() {
    final selectedAnswerId = state.lastResult?.selectedAnswerId;
    if (state.phase != RunnerPhase.feedback || selectedAnswerId == null) {
      return 0;
    }
    final answers = currentPrompt.answers.take(2).toList();
    final selectedIndex = answers.indexWhere(
      (answer) => answer.id == selectedAnswerId,
    );
    return switch (selectedIndex) {
      0 => -1,
      1 => 1,
      _ => 0,
    };
  }

  RunnerFeedbackPose _runnerFeedbackPose() {
    if (state.phase != RunnerPhase.feedback) {
      return RunnerFeedbackPose.none;
    }
    return state.lastResult?.isCorrect == true
        ? RunnerFeedbackPose.correct
        : RunnerFeedbackPose.wrong;
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
        oldDelegate.contentPack != contentPack ||
        oldDelegate.runnerImage != runnerImage ||
        oldDelegate.backgroundImage != backgroundImage ||
        oldDelegate.brandBackgroundImage != brandBackgroundImage ||
        oldDelegate.brandLogoImage != brandLogoImage ||
        oldDelegate.visualRunCycleProgress != visualRunCycleProgress;
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
