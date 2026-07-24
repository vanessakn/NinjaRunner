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

  test('running alternates foot lift and leg stride for a natural step', () {
    final leftStep = RunnerMotion.calculate(
      size: const Size(390, 720),
      progress: 0.04,
      isRunning: true,
      hasPositiveFeedback: false,
      streak: 0,
    );
    final rightStep = RunnerMotion.calculate(
      size: const Size(390, 720),
      progress: 0.12,
      isRunning: true,
      hasPositiveFeedback: false,
      streak: 0,
    );

    expect(leftStep.leftFootLift, greaterThan(leftStep.rightFootLift));
    expect(rightStep.rightFootLift, greaterThan(rightStep.leftFootLift));
    expect(leftStep.legStride, greaterThan(0));
    expect(rightStep.legStride, lessThan(0));
  });

  test('dodge pose plants one foot and leans harder into the lane change', () {
    final centered = RunnerMotion.calculate(
      size: const Size(390, 720),
      progress: 0.72,
      isRunning: false,
      hasPositiveFeedback: false,
      streak: 0,
      dodgeDirection: 0,
    );
    final leftDodge = RunnerMotion.calculate(
      size: const Size(390, 720),
      progress: 0.72,
      isRunning: false,
      hasPositiveFeedback: false,
      streak: 0,
      dodgeDirection: -1,
    );
    final rightDodge = RunnerMotion.calculate(
      size: const Size(390, 720),
      progress: 0.72,
      isRunning: false,
      hasPositiveFeedback: false,
      streak: 0,
      dodgeDirection: 1,
    );

    expect(
        leftDodge.leanRadians.abs(), greaterThan(centered.leanRadians.abs()));
    expect(
        rightDodge.leanRadians.abs(), greaterThan(centered.leanRadians.abs()));
    expect(leftDodge.leftFootLift, greaterThan(leftDodge.rightFootLift));
    expect(rightDodge.rightFootLift, greaterThan(rightDodge.leftFootLift));
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

  test('selected left gate dodges the runner toward the left lane', () {
    final centered = RunnerMotion.calculate(
      size: const Size(390, 720),
      progress: 0.72,
      isRunning: false,
      hasPositiveFeedback: false,
      streak: 0,
      dodgeDirection: 0,
    );
    final leftDodge = RunnerMotion.calculate(
      size: const Size(390, 720),
      progress: 0.72,
      isRunning: false,
      hasPositiveFeedback: false,
      streak: 0,
      dodgeDirection: -1,
    );

    expect(leftDodge.runnerCenter.dx, lessThan(centered.runnerCenter.dx));
    expect(leftDodge.leanRadians, lessThan(centered.leanRadians));
    expect(leftDodge.dodgeTrailRect.right, lessThan(centered.runnerCenter.dx));
  });

  test('selected right gate dodges the runner toward the right lane', () {
    final centered = RunnerMotion.calculate(
      size: const Size(390, 720),
      progress: 0.72,
      isRunning: false,
      hasPositiveFeedback: false,
      streak: 0,
      dodgeDirection: 0,
    );
    final rightDodge = RunnerMotion.calculate(
      size: const Size(390, 720),
      progress: 0.72,
      isRunning: false,
      hasPositiveFeedback: false,
      streak: 0,
      dodgeDirection: 1,
    );

    expect(rightDodge.runnerCenter.dx, greaterThan(centered.runnerCenter.dx));
    expect(rightDodge.leanRadians, greaterThan(centered.leanRadians));
    expect(
        rightDodge.dodgeTrailRect.left, greaterThan(centered.runnerCenter.dx));
  });
}
