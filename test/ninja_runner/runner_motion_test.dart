import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kidnation_mobile_games/ninja_runner/rendering/runner_motion.dart';

void main() {
  test('sizes runner sprite for mobile lane without overpowering gates', () {
    final motion = RunnerMotion.calculate(
      size: const Size(320, 640),
      progress: 0,
      isRunning: false,
      hasPositiveFeedback: false,
      streak: 0,
    );

    expect(motion.spriteRect.width, greaterThan(98));
    expect(motion.spriteRect.height, lessThanOrEqualTo(172));
    expect(motion.shadowRect.center.dx, motion.groundAnchor.dx);
  });

  test('adds running bob lean and shoe lift while moving', () {
    final idle = RunnerMotion.calculate(
      size: const Size(390, 720),
      progress: 0.125,
      isRunning: false,
      hasPositiveFeedback: false,
      streak: 0,
    );
    final running = RunnerMotion.calculate(
      size: const Size(390, 720),
      progress: 0.125,
      isRunning: true,
      hasPositiveFeedback: false,
      streak: 0,
    );

    expect(running.runnerCenter.dy, isNot(idle.runnerCenter.dy));
    expect(running.leanRadians.abs(), greaterThan(0.01));
    expect(running.shoeLift, greaterThan(0));
  });

  test('correct feedback exposes celebration accents around runner', () {
    final motion = RunnerMotion.calculate(
      size: const Size(390, 720),
      progress: 0.5,
      isRunning: false,
      hasPositiveFeedback: true,
      streak: 2,
    );

    expect(motion.celebrationBursts, hasLength(4));
    expect(motion.boostTrailRect.width, greaterThan(motion.spriteRect.width));
  });
}
