import 'dart:math' as math;

import 'package:flutter/material.dart';

enum RunnerFeedbackPose { none, correct, wrong }

class RunnerMotion {
  const RunnerMotion({
    required this.runnerCenter,
    required this.groundAnchor,
    required this.spriteRect,
    required this.shadowRect,
    required this.boostTrailRect,
    required this.dodgeTrailRect,
    required this.leanRadians,
    required this.shoeLift,
    required this.legStride,
    required this.leftFootLift,
    required this.rightFootLift,
    required this.celebrationBursts,
    required this.feedbackScale,
  });

  final Offset runnerCenter;
  final Offset groundAnchor;
  final Rect spriteRect;
  final Rect shadowRect;
  final Rect boostTrailRect;
  final Rect dodgeTrailRect;
  final double leanRadians;
  final double shoeLift;
  final double legStride;
  final double leftFootLift;
  final double rightFootLift;
  final List<Offset> celebrationBursts;
  final double feedbackScale;

  static RunnerMotion calculate({
    required Size size,
    required double progress,
    required bool isRunning,
    required bool hasPositiveFeedback,
    required int streak,
    double dodgeDirection = 0,
    double? strideProgress,
    double dodgeProgress = 1,
    RunnerFeedbackPose feedbackPose = RunnerFeedbackPose.none,
  }) {
    final clampedProgress = progress.clamp(0, 1).toDouble();
    final playWidth =
        size.width <= 560 ? math.min(size.width, 336) : size.width;
    final scale = (size.height / 420).clamp(0.68, 1).toDouble();
    final strideCycleProgress = strideProgress ?? clampedProgress;
    final clampedDodge = dodgeDirection.clamp(-1, 1).toDouble();
    final clampedDodgeProgress = dodgeProgress.clamp(0, 1).toDouble();
    final isSideStepping =
        !isRunning && clampedDodge != 0 && clampedDodgeProgress < 1;
    final phase = math.sin(strideCycleProgress * math.pi * 12);
    final bounce = isRunning
        ? phase * 5.5 * scale
        : isSideStepping
            ? phase.abs() * 2.5 * scale
            : 0.0;
    final legStride = isRunning
        ? phase * 14 * scale
        : isSideStepping
            ? phase * 6 * scale
            : 0.0;
    final leftFootLift = isRunning || isSideStepping
        ? math.max(phase, 0) * (isSideStepping ? 4 : 9) * scale
        : 0.0;
    final rightFootLift = isRunning || isSideStepping
        ? math.max(-phase, 0) * (isSideStepping ? 4 : 9) * scale
        : 0.0;
    final shoeLift = math.max(leftFootLift, rightFootLift);
    final easedDodgeProgress = _easeOutCubic(clampedDodgeProgress);
    final effectiveDodge = clampedDodge * easedDodgeProgress;
    final baseX = playWidth * 0.5;
    final targetGateX = clampedDodge < 0
        ? playWidth * 0.3
        : clampedDodge > 0
            ? playWidth * 0.62
            : baseX;
    final dodgeDistance = (targetGateX - baseX) * easedDodgeProgress;
    final dodgeVerticalLift =
        clampedDodge == 0 ? 0.0 : size.height * 0.11 * easedDodgeProgress;
    final wrongRecoil = feedbackPose == RunnerFeedbackPose.wrong
        ? -clampedDodge.sign * 9 * scale
        : 0.0;
    final feedbackHop =
        feedbackPose == RunnerFeedbackPose.correct ? 13 * scale : 0.0;
    final feedbackScale = switch (feedbackPose) {
      RunnerFeedbackPose.correct => 1.045,
      RunnerFeedbackPose.wrong => 0.965,
      RunnerFeedbackPose.none => 1.0,
    };
    final leanRadians = (isRunning ? phase * 0.04 : 0.0) +
        effectiveDodge * 0.16 +
        switch (feedbackPose) {
          RunnerFeedbackPose.correct => -clampedDodge.sign * 0.035,
          RunnerFeedbackPose.wrong => clampedDodge.sign * 0.055,
          RunnerFeedbackPose.none => 0.0,
        };

    final groundY =
        _lerp(size.height * 0.86, size.height * 0.61, clampedProgress);
    final spriteWidth = 128 * scale;
    final spriteHeight = 168 * scale;
    final groundAnchor = Offset(baseX + dodgeDistance + wrongRecoil,
        groundY - dodgeVerticalLift - feedbackHop);
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
    final dodgeTrailRect = Rect.fromCenter(
      center: runnerCenter.translate(
          effectiveDodge * 42 * scale, spriteHeight * 0.2),
      width: effectiveDodge == 0 ? 0 : 70 * scale,
      height: effectiveDodge == 0 ? 0 : 26 * scale,
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
      dodgeTrailRect: dodgeTrailRect,
      leanRadians: leanRadians,
      shoeLift: shoeLift,
      legStride: legStride,
      leftFootLift: leftFootLift,
      rightFootLift: rightFootLift,
      celebrationBursts: celebrationBursts,
      feedbackScale: feedbackScale,
    );
  }

  static double _lerp(double start, double end, double t) {
    return start + (end - start) * t;
  }

  static double _easeOutCubic(double t) {
    final inverse = 1 - t;
    return 1 - inverse * inverse * inverse;
  }
}
