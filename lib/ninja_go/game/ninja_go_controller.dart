import 'dart:math' as math;

import '../models/ninja_go_models.dart';

class NinjaGoController {
  NinjaGoController({int? seed})
      : _random = math.Random(seed),
        state = NinjaGoState.initial();

  static const double jumpDuration = 0.62;
  static const double slideDuration = 0.58;

  final math.Random _random;
  NinjaGoState state;

  void startRun() {
    state = NinjaGoState.initial(
      bestDistance: state.bestDistance,
      bestScore: state.bestScore,
    ).copyWith(phase: NinjaGoPhase.running);
  }

  void moveLeft() {
    if (state.phase != NinjaGoPhase.running) {
      return;
    }

    state = state.copyWith(currentLane: _shiftLane(-1));
  }

  void moveRight() {
    if (state.phase != NinjaGoPhase.running) {
      return;
    }

    state = state.copyWith(currentLane: _shiftLane(1));
  }

  void jump() {
    if (state.phase != NinjaGoPhase.running) {
      return;
    }

    state = state.copyWith(
      runnerAction: NinjaGoRunnerAction.jumping,
      actionTimeRemaining: jumpDuration,
    );
  }

  void slide() {
    if (state.phase != NinjaGoPhase.running) {
      return;
    }

    state = state.copyWith(
      runnerAction: NinjaGoRunnerAction.sliding,
      actionTimeRemaining: slideDuration,
    );
  }

  void tick(double deltaSeconds) {
    if (state.phase != NinjaGoPhase.running || deltaSeconds <= 0) {
      return;
    }

    final nextActionTime = math.max(
      0.0,
      state.actionTimeRemaining - deltaSeconds,
    );
    final nextAction =
        nextActionTime == 0 ? NinjaGoRunnerAction.running : state.runnerAction;

    state = state.copyWith(
      runnerAction: nextAction,
      actionTimeRemaining: nextActionTime,
    );
  }

  NinjaGoLane _shiftLane(int direction) {
    final nextIndex = (state.currentLane.index + direction).clamp(
      0,
      NinjaGoLane.values.length - 1,
    );

    return NinjaGoLane.values[nextIndex];
  }
}
