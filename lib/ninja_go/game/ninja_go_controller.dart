import 'dart:math' as math;

import '../models/ninja_go_models.dart';

class NinjaGoController {
  NinjaGoController({int? seed})
      : _random = math.Random(seed),
        state = NinjaGoState.initial();

  static const double jumpDuration = 0.62;
  static const double slideDuration = 0.58;
  static const double hitPosition = 0.12;
  static const double hitWindow = 0.075;
  static const int starBonus = 50;
  static const double _openingSpawnDelay = 1.1;
  static const double _openingNoBlockerDistance = 90;

  final math.Random _random;
  double _spawnTimer = _openingSpawnDelay;
  int _nextEntityId = 1;
  NinjaGoState state;

  void startRun() {
    _spawnTimer = _openingSpawnDelay;
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

    final speed = 1 + state.distance / 460;
    final distance = state.distance + deltaSeconds * speed * 13.5;
    final scoreBonus = math.max(0, state.score - state.distance.floor());
    final actionAtTickStart = state.runnerAction;
    final actionTimeAtTickStart = state.actionTimeRemaining;
    final nextActionTime = math.max(
      0.0,
      state.actionTimeRemaining - deltaSeconds,
    );
    final nextAction =
        nextActionTime == 0 ? NinjaGoRunnerAction.running : state.runnerAction;

    _spawnTimer -= deltaSeconds;
    final movedEntities = state.entities
        .map(
          (entity) => _NinjaGoEntityMovement(
            previousPosition: entity.position,
            entity: entity.copyWith(
              position: entity.position - deltaSeconds * speed * 0.32,
            ),
          ),
        )
        .toList();

    if (_spawnTimer <= 0) {
      final entity = _createEntity();
      movedEntities.add(
        _NinjaGoEntityMovement(
          previousPosition: entity.position,
          entity: entity,
        ),
      );
      _spawnTimer = math.max(0.72, 1.25 - speed * 0.06);
    }

    state = state.copyWith(
      runnerAction: nextAction,
      actionTimeRemaining: nextActionTime,
      distance: distance,
      score: distance.floor() + scoreBonus,
      speed: speed,
    );

    _resolveHitWindow(
      movedEntities,
      actionAtTickStart: actionAtTickStart,
      actionTimeAtTickStart: actionTimeAtTickStart,
      deltaSeconds: deltaSeconds,
    );
  }

  void debugSetEntities(List<NinjaGoEntity> entities) {
    state = state.copyWith(entities: List<NinjaGoEntity>.of(entities));
  }

  NinjaGoLane _shiftLane(int direction) {
    final nextIndex = (state.currentLane.index + direction)
        .clamp(
          0,
          NinjaGoLane.values.length - 1,
        )
        .toInt();

    return NinjaGoLane.values[nextIndex];
  }

  NinjaGoEntity _createEntity() {
    final roll = _random.nextInt(10);
    final generatedKind = roll < 4
        ? NinjaGoEntityKind.star
        : NinjaGoEntityKind.values[_random.nextInt(3)];
    final kind = generatedKind == NinjaGoEntityKind.laneBlocker &&
            state.distance < _openingNoBlockerDistance
        ? NinjaGoEntityKind.values[_random.nextInt(2)]
        : generatedKind;
    final lane = NinjaGoLane.values[_random.nextInt(NinjaGoLane.values.length)];

    return NinjaGoEntity(
      id: _nextEntityId++,
      kind: kind,
      lane: lane,
      position: 1,
    );
  }

  void _resolveHitWindow(
    List<_NinjaGoEntityMovement> movedEntities, {
    required NinjaGoRunnerAction actionAtTickStart,
    required double actionTimeAtTickStart,
    required double deltaSeconds,
  }) {
    var stars = state.stars;
    var score = state.score;
    var shouldEndRun = false;
    final entities = <NinjaGoEntity>[];

    for (final movement in movedEntities) {
      final entity = movement.entity;
      final inCurrentLane = entity.lane == state.currentLane;
      final inHitWindow = _movementIntersectsHitWindow(movement);

      if (!inCurrentLane || !inHitWindow) {
        if (!entity.collected && !entity.isPastRunner) {
          entities.add(entity);
        }
        continue;
      }

      if (entity.isCollectible) {
        stars += 1;
        score += starBonus;
        continue;
      }

      final actionAtHit = _actionAtHitTime(
        movement,
        actionAtTickStart: actionAtTickStart,
        actionTimeAtTickStart: actionTimeAtTickStart,
        deltaSeconds: deltaSeconds,
      );

      if (_collidesWith(entity, actionAtHit)) {
        shouldEndRun = true;
      }

      if (!entity.collected && !entity.isPastRunner) {
        entities.add(entity);
      }
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

  bool _movementIntersectsHitWindow(_NinjaGoEntityMovement movement) {
    const lowerBound = hitPosition - hitWindow;
    const upperBound = hitPosition + hitWindow;
    final segmentStart = math.min(
      movement.previousPosition,
      movement.entity.position,
    );
    final segmentEnd = math.max(
      movement.previousPosition,
      movement.entity.position,
    );

    return segmentStart <= upperBound && segmentEnd >= lowerBound;
  }

  NinjaGoRunnerAction _actionAtHitTime(
    _NinjaGoEntityMovement movement, {
    required NinjaGoRunnerAction actionAtTickStart,
    required double actionTimeAtTickStart,
    required double deltaSeconds,
  }) {
    if (actionAtTickStart == NinjaGoRunnerAction.running) {
      return NinjaGoRunnerAction.running;
    }

    final hitElapsedSeconds = _hitFraction(movement) * deltaSeconds;

    if (hitElapsedSeconds <= actionTimeAtTickStart) {
      return actionAtTickStart;
    }

    return NinjaGoRunnerAction.running;
  }

  double _hitFraction(_NinjaGoEntityMovement movement) {
    final previousPosition = movement.previousPosition;
    final nextPosition = movement.entity.position;

    if (previousPosition == nextPosition) {
      return 0;
    }

    const lowerBound = hitPosition - hitWindow;
    const upperBound = hitPosition + hitWindow;
    final hitBoundary =
        previousPosition > nextPosition ? upperBound : lowerBound;
    final fraction =
        (previousPosition - hitBoundary) / (previousPosition - nextPosition);

    return fraction.clamp(0.0, 1.0);
  }

  bool _collidesWith(NinjaGoEntity entity, NinjaGoRunnerAction actionAtHit) {
    return switch (entity.kind) {
      NinjaGoEntityKind.star => false,
      NinjaGoEntityKind.laneBlocker => true,
      NinjaGoEntityKind.groundBarrier =>
        actionAtHit != NinjaGoRunnerAction.jumping,
      NinjaGoEntityKind.overheadObstacle =>
        actionAtHit != NinjaGoRunnerAction.sliding,
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

class _NinjaGoEntityMovement {
  const _NinjaGoEntityMovement({
    required this.previousPosition,
    required this.entity,
  });

  final double previousPosition;
  final NinjaGoEntity entity;
}
