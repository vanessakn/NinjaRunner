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

  test('dodge pose uses a smaller walking step while moving sideways', () {
    final centered = RunnerMotion.calculate(
      size: const Size(390, 720),
      progress: 0.12,
      isRunning: false,
      hasPositiveFeedback: false,
      streak: 0,
      dodgeDirection: 0,
    );
    final leftDodge = RunnerMotion.calculate(
      size: const Size(390, 720),
      progress: 0.12,
      strideProgress: 0.04,
      isRunning: false,
      hasPositiveFeedback: false,
      streak: 0,
      dodgeDirection: -1,
      dodgeProgress: 0.5,
    );
    final rightDodge = RunnerMotion.calculate(
      size: const Size(390, 720),
      progress: 0.12,
      strideProgress: 0.04,
      isRunning: false,
      hasPositiveFeedback: false,
      streak: 0,
      dodgeDirection: 1,
      dodgeProgress: 0.5,
    );
    final running = RunnerMotion.calculate(
      size: const Size(390, 720),
      progress: 0.04,
      isRunning: true,
      hasPositiveFeedback: false,
      streak: 0,
    );

    expect(
        leftDodge.leanRadians.abs(), greaterThan(centered.leanRadians.abs()));
    expect(
        rightDodge.leanRadians.abs(), greaterThan(centered.leanRadians.abs()));
    expect(leftDodge.leftFootLift, greaterThan(leftDodge.rightFootLift));
    expect(rightDodge.leftFootLift, greaterThan(rightDodge.rightFootLift));
    expect(leftDodge.legStride.abs(), lessThan(running.legStride.abs()));
    expect(rightDodge.legStride.abs(), lessThan(running.legStride.abs()));
  });

  test('dodge side step moves sideways before settling at the target lane', () {
    final centered = RunnerMotion.calculate(
      size: const Size(390, 720),
      progress: 0.7,
      isRunning: false,
      hasPositiveFeedback: false,
      streak: 0,
    );
    final earlyStride = RunnerMotion.calculate(
      size: const Size(390, 720),
      progress: 0.7,
      strideProgress: 0.04,
      isRunning: false,
      hasPositiveFeedback: false,
      streak: 0,
      dodgeDirection: 1,
      dodgeProgress: 0.25,
    );
    final laterStride = RunnerMotion.calculate(
      size: const Size(390, 720),
      progress: 0.7,
      strideProgress: 0.12,
      isRunning: false,
      hasPositiveFeedback: false,
      streak: 0,
      dodgeDirection: 1,
      dodgeProgress: 0.75,
    );
    final settled = RunnerMotion.calculate(
      size: const Size(390, 720),
      progress: 0.7,
      strideProgress: 0.3,
      isRunning: false,
      hasPositiveFeedback: false,
      streak: 0,
      dodgeDirection: 1,
      dodgeProgress: 1,
    );

    expect(earlyStride.groundAnchor.dx, greaterThan(centered.groundAnchor.dx));
    expect(
        laterStride.groundAnchor.dx, greaterThan(earlyStride.groundAnchor.dx));
    expect(settled.groundAnchor.dx, greaterThan(laterStride.groundAnchor.dx));
    expect(laterStride.groundAnchor.dy, lessThan(earlyStride.groundAnchor.dy));
    expect(settled.groundAnchor.dy, lessThan(laterStride.groundAnchor.dy));
    expect(earlyStride.leftFootLift, greaterThan(earlyStride.rightFootLift));
    expect(laterStride.rightFootLift, greaterThan(laterStride.leftFootLift));
    expect(settled.leftFootLift, 0);
    expect(settled.rightFootLift, 0);
    expect(settled.legStride, 0);
  });

  test('settled dodge lands near the selected gate instead of beside center',
      () {
    const size = Size(390, 720);
    final playWidth = size.width <= 560 ? 336.0 : size.width;
    final leftGateCenterX = playWidth * 0.3;
    final rightGateCenterX = playWidth * 0.62;
    final centered = RunnerMotion.calculate(
      size: size,
      progress: 0.7,
      isRunning: false,
      hasPositiveFeedback: false,
      streak: 0,
    );
    final leftDodge = RunnerMotion.calculate(
      size: size,
      progress: 0.7,
      isRunning: false,
      hasPositiveFeedback: false,
      streak: 0,
      dodgeDirection: -1,
      dodgeProgress: 1,
    );
    final rightDodge = RunnerMotion.calculate(
      size: size,
      progress: 0.7,
      isRunning: false,
      hasPositiveFeedback: false,
      streak: 0,
      dodgeDirection: 1,
      dodgeProgress: 1,
    );

    expect(leftDodge.groundAnchor.dx, closeTo(leftGateCenterX, 0.1));
    expect(rightDodge.groundAnchor.dx, closeTo(rightGateCenterX, 0.1));
    expect(leftDodge.groundAnchor.dy, lessThan(centered.groundAnchor.dy));
    expect(rightDodge.groundAnchor.dy, lessThan(centered.groundAnchor.dy));
  });

  test('correct feedback exposes celebration accents around runner', () {
    final motion = RunnerMotion.calculate(
      size: const Size(390, 720),
      progress: 0.5,
      isRunning: false,
      hasPositiveFeedback: true,
      streak: 2,
      feedbackPose: RunnerFeedbackPose.correct,
    );

    expect(motion.celebrationBursts, hasLength(4));
    expect(motion.boostTrailRect.width, greaterThan(motion.spriteRect.width));
    expect(motion.feedbackScale, greaterThan(1));
  });

  test('correct feedback gives Jordan a small celebration hop', () {
    final base = RunnerMotion.calculate(
      size: const Size(390, 720),
      progress: 0.7,
      isRunning: false,
      hasPositiveFeedback: false,
      streak: 0,
      dodgeDirection: -1,
    );
    final correct = RunnerMotion.calculate(
      size: const Size(390, 720),
      progress: 0.7,
      isRunning: false,
      hasPositiveFeedback: true,
      streak: 1,
      dodgeDirection: -1,
      feedbackPose: RunnerFeedbackPose.correct,
    );

    expect(correct.runnerCenter.dy, lessThan(base.runnerCenter.dy));
    expect(correct.feedbackScale, greaterThan(base.feedbackScale));
    expect(correct.celebrationBursts, isNotEmpty);
  });

  test('wrong feedback adds a small recoil without celebration bursts', () {
    final base = RunnerMotion.calculate(
      size: const Size(390, 720),
      progress: 0.7,
      isRunning: false,
      hasPositiveFeedback: false,
      streak: 0,
      dodgeDirection: 1,
    );
    final wrong = RunnerMotion.calculate(
      size: const Size(390, 720),
      progress: 0.7,
      isRunning: false,
      hasPositiveFeedback: false,
      streak: 0,
      dodgeDirection: 1,
      feedbackPose: RunnerFeedbackPose.wrong,
    );

    expect(wrong.runnerCenter.dx, lessThan(base.runnerCenter.dx));
    expect(wrong.feedbackScale, lessThan(base.feedbackScale));
    expect(wrong.celebrationBursts, isEmpty);
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
