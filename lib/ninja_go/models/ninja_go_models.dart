enum NinjaGoPhase {
  ready,
  running,
  gameOver,
}

enum NinjaGoLane {
  left,
  center,
  right,
}

enum NinjaGoRunnerAction {
  running,
  jumping,
  sliding,
}

enum NinjaGoEntityKind {
  groundBarrier,
  overheadObstacle,
  laneBlocker,
  star,
}

class NinjaGoEntity {
  const NinjaGoEntity({
    required this.id,
    required this.kind,
    required this.lane,
    required this.position,
    this.collected = false,
  });

  final int id;
  final NinjaGoEntityKind kind;
  final NinjaGoLane lane;
  final double position;
  final bool collected;

  bool get isObstacle => kind != NinjaGoEntityKind.star;
  bool get isCollectible => kind == NinjaGoEntityKind.star;

  NinjaGoEntity copyWith({
    int? id,
    NinjaGoEntityKind? kind,
    NinjaGoLane? lane,
    double? position,
    bool? collected,
  }) {
    return NinjaGoEntity(
      id: id ?? this.id,
      kind: kind ?? this.kind,
      lane: lane ?? this.lane,
      position: position ?? this.position,
      collected: collected ?? this.collected,
    );
  }
}

class NinjaGoState {
  const NinjaGoState({
    required this.phase,
    required this.currentLane,
    required this.runnerAction,
    required this.actionTimeRemaining,
    required this.distance,
    required this.score,
    required this.stars,
    required this.speed,
    required this.bestDistance,
    required this.bestScore,
    required this.entities,
  });

  factory NinjaGoState.initial({
    double bestDistance = 0,
    int bestScore = 0,
  }) {
    return NinjaGoState(
      phase: NinjaGoPhase.ready,
      currentLane: NinjaGoLane.center,
      runnerAction: NinjaGoRunnerAction.running,
      actionTimeRemaining: 0,
      distance: 0,
      score: 0,
      stars: 0,
      speed: 1,
      bestDistance: bestDistance,
      bestScore: bestScore,
      entities: const [],
    );
  }

  final NinjaGoPhase phase;
  final NinjaGoLane currentLane;
  final NinjaGoRunnerAction runnerAction;
  final double actionTimeRemaining;
  final double distance;
  final int score;
  final int stars;
  final double speed;
  final double bestDistance;
  final int bestScore;
  final List<NinjaGoEntity> entities;

  NinjaGoState copyWith({
    NinjaGoPhase? phase,
    NinjaGoLane? currentLane,
    NinjaGoRunnerAction? runnerAction,
    double? actionTimeRemaining,
    double? distance,
    int? score,
    int? stars,
    double? speed,
    double? bestDistance,
    int? bestScore,
    List<NinjaGoEntity>? entities,
  }) {
    return NinjaGoState(
      phase: phase ?? this.phase,
      currentLane: currentLane ?? this.currentLane,
      runnerAction: runnerAction ?? this.runnerAction,
      actionTimeRemaining: actionTimeRemaining ?? this.actionTimeRemaining,
      distance: distance ?? this.distance,
      score: score ?? this.score,
      stars: stars ?? this.stars,
      speed: speed ?? this.speed,
      bestDistance: bestDistance ?? this.bestDistance,
      bestScore: bestScore ?? this.bestScore,
      entities: entities ?? this.entities,
    );
  }
}
