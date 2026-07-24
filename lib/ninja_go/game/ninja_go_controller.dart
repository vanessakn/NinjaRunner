import 'dart:math' as math;

import '../models/ninja_go_models.dart';

class NinjaGoController {
  NinjaGoController({int? seed})
      : _random = math.Random(seed),
        state = NinjaGoState.initial();

  static const double jumpDuration = 0.62;
  static const double slideDuration = 0.58;
  static const double hitPosition = 0.12;
  static const double hitWindow = 0.09;
  static const int starBonus = 50;

  final math.Random _random;
  double _spawnTimer = 0.85;
  int _nextEntityId = 1;
  NinjaGoState state;

  void startRun() {
    _spawnTimer = 0.85;
    _nextEntityId = 1;
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

    final speed = 1 + state.distance / 280;
    final distance = state.distance + deltaSeconds * speed * 16;
    final scoreBonus = math.max(0, state.score - state.distance.floor());
    final nextActionTime = math.max(
      0.0,
      state.actionTimeRemaining - deltaSeconds,
    );
    final nextAction =
        nextActionTime == 0 ? NinjaGoRunnerAction.running : state.runnerAction;

    _spawnTimer -= deltaSeconds;
    final movedEntities = state.entities
        .map(
          (entity) => entity.copyWith(
            position: entity.position - deltaSeconds * speed * 0.38,
          ),
        )
        .where((entity) => !entity.collected && !entity.isPastRunner)
        .toList();

    if (_spawnTimer <= 0) {
      movedEntities.add(_createEntity());
      _spawnTimer = math.max(0.52, 1.15 - speed * 0.08);
    }

    state = state.copyWith(
      runnerAction: nextAction,
      actionTimeRemaining: nextActionTime,
      distance: distance,
      score: distance.floor() + scoreBonus,
      speed: speed,
      entities: movedEntities,
    );

    _resolveHitWindow();
  }

  void debugSetEntities(List<NinjaGoEntity> entities) {
    state = state.copyWith(entities: List<NinjaGoEntity>.of(entities));
  }

  NinjaGoLane _shiftLane(int direction) {
    final nextIndex = (state.currentLane.index + direction).clamp(
      0,
      NinjaGoLane.values.length - 1,
    );

    return NinjaGoLane.values[nextIndex];
  }

  NinjaGoEntity _createEntity() {
    final roll = _random.nextInt(10);
    final kind = roll < 3
        ? NinjaGoEntityKind.star
        : NinjaGoEntityKind.values[_random.nextInt(3)];
    final lane = NinjaGoLane.values[_random.nextInt(NinjaGoLane.values.length)];

    return NinjaGoEntity(
      id: _nextEntityId++,
      kind: kind,
      lane: lane,
      position: 1,
    );
  }

  void _resolveHitWindow() {
    var stars = state.stars;
    var score = state.score;
    var shouldEndRun = false;
    final entities = <NinjaGoEntity>[];

    for (final entity in state.entities) {
      final inCurrentLane = entity.lane == state.currentLane;
      final inHitWindow = (entity.position - hitPosition).abs() <= hitWindow;

      if (!inCurrentLane || !inHitWindow) {
        entities.add(entity);
        continue;
      }

      if (entity.isCollectible) {
        stars += 1;
        score += starBonus;
        continue;
      }

      if (_collidesWith(entity)) {
        shouldEndRun = true;
      }

      entities.add(entity);
    }

    state = state.copyWith(
      stars: stars,
      score: score,
      entities: entities,
    );

    if (shouldEndRun) {
      _endRun();
    }
  }

  bool _collidesWith(NinjaGoEntity entity) {
    return switch (entity.kind) {
      NinjaGoEntityKind.star => false,
      NinjaGoEntityKind.laneBlocker => true,
      NinjaGoEntityKind.groundBarrier =>
        state.runnerAction != NinjaGoRunnerAction.jumping,
      NinjaGoEntityKind.overheadObstacle =>
        state.runnerAction != NinjaGoRunnerAction.sliding,
    };
  }

  void _endRun() {
    state = state.copyWith(
      phase: NinjaGoPhase.gameOver,
      bestDistance: math.max(state.bestDistance, state.distance),
      bestScore: math.max(state.bestScore, state.score),
    );
  }
}
