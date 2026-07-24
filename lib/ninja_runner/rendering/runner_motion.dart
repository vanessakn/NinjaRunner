import 'dart:math' as math;

import 'package:flutter/material.dart';

class RunnerMotion {
  const RunnerMotion({
    required this.runnerCenter,
    required this.groundAnchor,
    required this.spriteRect,
    required this.shadowRect,
    required this.boostTrailRect,
    required this.leanRadians,
    required this.shoeLift,
    required this.celebrationBursts,
  });

  final Offset runnerCenter;
  final Offset groundAnchor;
  final Rect spriteRect;
  final Rect shadowRect;
  final Rect boostTrailRect;
  final double leanRadians;
  final double shoeLift;
  final List<Offset> celebrationBursts;

  static RunnerMotion calculate({
    required Size size,
    required double progress,
    required bool isRunning,
    required bool hasPositiveFeedback,
    required int streak,
  }) {
    final clampedProgress = progress.clamp(0, 1).toDouble();
    final playWidth =
        size.width <= 560 ? math.min(size.width, 336) : size.width;
    final scale = (size.height / 420).clamp(0.68, 1).toDouble();
    final phase = math.sin(clampedProgress * math.pi * 12);
    final bounce = isRunning ? phase * 5.5 * scale : 0.0;
    final shoeLift = isRunning ? phase.abs() * 7 * scale : 0.0;
    final leanRadians = isRunning ? phase * 0.04 : 0.0;

    final groundY =
        _lerp(size.height * 0.86, size.height * 0.61, clampedProgress);
    final spriteWidth = 128 * scale;
    final spriteHeight = 168 * scale;
    final groundAnchor = Offset(playWidth * 0.5, groundY);
    final runnerCenter =
        groundAnchor.translate(0, -spriteHeight * 0.5 + bounce);
    final spriteRect = Rect.fromCenter(
      center: runnerCenter,
      width: spriteWidth,
      height: spriteHeight,
    );
    final shadowRect = Rect.fromCenter(
      center: groundAnchor.translate(0, 4 * scale),
      width: 86 * scale,
      height: 18 * scale,
    );
    final boostTrailRect = Rect.fromCenter(
      center: runnerCenter.translate(-30 * scale, spriteHeight * 0.18),
      width: hasPositiveFeedback ? spriteWidth + (28 + streak * 8) * scale : 0,
      height: hasPositiveFeedback ? 48 * scale : 0,
    );

    final celebrationBursts = hasPositiveFeedback
        ? [
            spriteRect.topLeft.translate(10 * scale, 18 * scale),
            spriteRect.topRight.translate(-8 * scale, 30 * scale),
            spriteRect.centerLeft.translate(-8 * scale, -4 * scale),
            spriteRect.centerRight.translate(10 * scale, 8 * scale),
          ]
        : const <Offset>[];

    return RunnerMotion(
      runnerCenter: runnerCenter,
      groundAnchor: groundAnchor,
      spriteRect: spriteRect,
      shadowRect: shadowRect,
      boostTrailRect: boostTrailRect,
      leanRadians: leanRadians,
      shoeLift: shoeLift,
      celebrationBursts: celebrationBursts,
    );
  }

  static double _lerp(double start, double end, double t) {
    return start + (end - start) * t;
  }
}
