# Ninja Go Flutter Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a separate Flutter `Ninja Go` pure reflex runner with KidNation branding, three-lane movement, jump/slide actions, obstacles, stars, score, and replay.

**Architecture:** Add a new `lib/ninja_go/` module that mirrors the repo's existing controller/painter/screen pattern without sharing gameplay code with `ninja_runner`. Keep gameplay logic in a testable controller, render with `CustomPainter`, and wire the screen into `HomeScreen` as a third game.

**Tech Stack:** Flutter 3.44.7, Dart 3.12.2, Material 3, `CustomPainter`, `Ticker`, `flutter_test`.

---

## Current Tooling Notes

Use this Flutter binary on this machine:

```bash
/Users/vaneVanessa_KidNationssa_kidnation/development/flutter/bin/flutter
```

The plain `flutter` command is not currently on `PATH`.

## File Structure

- Create `lib/ninja_go/models/ninja_go_models.dart`
  - Immutable state, entity, lane, obstacle, collectible, phase, and action types.
- Create `lib/ninja_go/game/ninja_go_controller.dart`
  - Run lifecycle, movement, action timing, spawning, scoring, collection, collision, speed ramp, and deterministic random support.
- Create `lib/ninja_go/rendering/ninja_go_painter.dart`
  - KidNation-styled sky, perspective lanes, runner, obstacles, stars, HUD-safe playfield art, and game-over feedback.
- Create `lib/ninja_go/ui/ninja_go_screen.dart`
  - Start, active run, game-over summary, gestures, ticker lifecycle, and retry/back controls.
- Create `test/ninja_go/ninja_go_controller_test.dart`
  - Focused controller tests for mechanics and deterministic state.
- Modify `lib/home_screen.dart`
  - Add a separate `Ninja Go` game button without changing `Ninja Runner` or `Bubble Blast`.
- Modify `test/widget_test.dart`
  - Add `Ninja Go` to the game picker smoke test and verify it opens.

---

### Task 1: Ninja Go Models

**Files:**
- Create: `lib/ninja_go/models/ninja_go_models.dart`
- Test: `test/ninja_go/ninja_go_controller_test.dart`

- [ ] **Step 1: Write failing model and initial-state tests**

Create `test/ninja_go/ninja_go_controller_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:kidnation_mobile_games/ninja_go/game/ninja_go_controller.dart';
import 'package:kidnation_mobile_games/ninja_go/models/ninja_go_models.dart';

void main() {
  group('NinjaGoController', () {
    test('starts ready with the runner in the center lane', () {
      final controller = NinjaGoController(seed: 7);

      expect(controller.state.phase, NinjaGoPhase.ready);
      expect(controller.state.currentLane, NinjaGoLane.center);
      expect(controller.state.runnerAction, NinjaGoRunnerAction.running);
      expect(controller.state.distance, 0);
      expect(controller.state.score, 0);
      expect(controller.state.stars, 0);
      expect(controller.state.entities, isEmpty);
    });
  });
}
```

- [ ] **Step 2: Run the test and verify it fails**

Run:

```bash
/Users/vaneVanessa_KidNationssa_kidnation/development/flutter/bin/flutter test test/ninja_go/ninja_go_controller_test.dart
```

Expected: fails because `ninja_go_controller.dart` and `ninja_go_models.dart` do not exist.

- [ ] **Step 3: Create model types**

Create `lib/ninja_go/models/ninja_go_models.dart`:

```dart
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
```

- [ ] **Step 4: Create minimal controller**

Create `lib/ninja_go/game/ninja_go_controller.dart`:

```dart
import 'dart:math' as math;

import '../models/ninja_go_models.dart';

class NinjaGoController {
  NinjaGoController({int? seed})
      : _random = math.Random(seed),
        state = NinjaGoState.initial();

  final math.Random _random;
  NinjaGoState state;

  void startRun() {
    state = NinjaGoState.initial(
      bestDistance: state.bestDistance,
      bestScore: state.bestScore,
    ).copyWith(phase: NinjaGoPhase.running);
  }
}
```

- [ ] **Step 5: Run the test and verify it passes**

Run:

```bash
/Users/vaneVanessa_KidNationssa_kidnation/development/flutter/bin/flutter test test/ninja_go/ninja_go_controller_test.dart
```

Expected: `All tests passed!`

- [ ] **Step 6: Commit models**

Run:

```bash
git add lib/ninja_go/models/ninja_go_models.dart lib/ninja_go/game/ninja_go_controller.dart test/ninja_go/ninja_go_controller_test.dart
git commit -m "feat: add Ninja Go game state models"
```

---

### Task 2: Movement And Action Timing

**Files:**
- Modify: `lib/ninja_go/game/ninja_go_controller.dart`
- Modify: `test/ninja_go/ninja_go_controller_test.dart`

- [ ] **Step 1: Add failing movement and action tests**

Append these tests inside the existing `group('NinjaGoController', ...)`:

```dart
test('moves left and right while clamping to the outer lanes', () {
  final controller = NinjaGoController(seed: 7)..startRun();

  controller.moveLeft();
  controller.moveLeft();

  expect(controller.state.currentLane, NinjaGoLane.left);

  controller.moveRight();
  controller.moveRight();
  controller.moveRight();

  expect(controller.state.currentLane, NinjaGoLane.right);
});

test('jump and slide actions return to running after their timers expire', () {
  final controller = NinjaGoController(seed: 7)..startRun();

  controller.jump();

  expect(controller.state.runnerAction, NinjaGoRunnerAction.jumping);
  expect(controller.state.actionTimeRemaining, greaterThan(0));

  controller.tick(0.7);

  expect(controller.state.runnerAction, NinjaGoRunnerAction.running);
  expect(controller.state.actionTimeRemaining, 0);

  controller.slide();

  expect(controller.state.runnerAction, NinjaGoRunnerAction.sliding);

  controller.tick(0.7);

  expect(controller.state.runnerAction, NinjaGoRunnerAction.running);
});

test('ignores movement and actions before the run starts', () {
  final controller = NinjaGoController(seed: 7);

  controller.moveLeft();
  controller.jump();
  controller.slide();

  expect(controller.state.currentLane, NinjaGoLane.center);
  expect(controller.state.runnerAction, NinjaGoRunnerAction.running);
});
```

- [ ] **Step 2: Run the test and verify it fails**

Run:

```bash
/Users/vaneVanessa_KidNationssa_kidnation/development/flutter/bin/flutter test test/ninja_go/ninja_go_controller_test.dart
```

Expected: fails because `moveLeft`, `moveRight`, `jump`, `slide`, and `tick` are not implemented.

- [ ] **Step 3: Implement movement and action timing**

Replace `lib/ninja_go/game/ninja_go_controller.dart` with:

```dart
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

    final remaining = math.max(0.0, state.actionTimeRemaining - deltaSeconds);
    state = state.copyWith(
      actionTimeRemaining: remaining,
      runnerAction: remaining == 0
          ? NinjaGoRunnerAction.running
          : state.runnerAction,
    );
  }

  NinjaGoLane _shiftLane(int offset) {
    final nextIndex = (state.currentLane.index + offset).clamp(
      0,
      NinjaGoLane.values.length - 1,
    );
    return NinjaGoLane.values[nextIndex];
  }
}
```

- [ ] **Step 4: Run the test and verify it passes**

Run:

```bash
/Users/vaneVanessa_KidNationssa_kidnation/development/flutter/bin/flutter test test/ninja_go/ninja_go_controller_test.dart
```

Expected: `All tests passed!`

- [ ] **Step 5: Commit movement**

Run:

```bash
git add lib/ninja_go/game/ninja_go_controller.dart test/ninja_go/ninja_go_controller_test.dart
git commit -m "feat: add Ninja Go runner controls"
```

---

### Task 3: Run Progress, Spawning, Stars, And Collisions

**Files:**
- Modify: `lib/ninja_go/models/ninja_go_models.dart`
- Modify: `lib/ninja_go/game/ninja_go_controller.dart`
- Modify: `test/ninja_go/ninja_go_controller_test.dart`

- [ ] **Step 1: Add failing mechanics tests**

Append these tests inside the controller group:

```dart
test('increases distance score and speed while running', () {
  final controller = NinjaGoController(seed: 7)..startRun();

  controller.tick(1);
  controller.tick(1);

  expect(controller.state.distance, greaterThan(0));
  expect(controller.state.score, controller.state.distance.floor());
  expect(controller.state.speed, greaterThan(1));
});

test('collects a star in the current lane and awards bonus score', () {
  final controller = NinjaGoController(seed: 7)..startRun();

  controller.debugSetEntities([
    const NinjaGoEntity(
      id: 1,
      kind: NinjaGoEntityKind.star,
      lane: NinjaGoLane.center,
      position: NinjaGoController.hitPosition,
    ),
  ]);

  controller.tick(0.01);

  expect(controller.state.stars, 1);
  expect(controller.state.score, greaterThanOrEqualTo(50));
  expect(controller.state.entities, isEmpty);
});

test('lane blocker collision ends the run and stores best metrics', () {
  final controller = NinjaGoController(seed: 7)..startRun();

  controller.debugSetEntities([
    const NinjaGoEntity(
      id: 1,
      kind: NinjaGoEntityKind.laneBlocker,
      lane: NinjaGoLane.center,
      position: NinjaGoController.hitPosition,
    ),
  ]);

  controller.tick(0.01);

  expect(controller.state.phase, NinjaGoPhase.gameOver);
  expect(controller.state.bestDistance, controller.state.distance);
  expect(controller.state.bestScore, controller.state.score);
});

test('jump avoids ground barriers and slide avoids overhead obstacles', () {
  final jumpController = NinjaGoController(seed: 7)..startRun();
  jumpController
    ..jump()
    ..debugSetEntities([
      const NinjaGoEntity(
        id: 1,
        kind: NinjaGoEntityKind.groundBarrier,
        lane: NinjaGoLane.center,
        position: NinjaGoController.hitPosition,
      ),
    ])
    ..tick(0.01);

  expect(jumpController.state.phase, NinjaGoPhase.running);

  final slideController = NinjaGoController(seed: 7)..startRun();
  slideController
    ..slide()
    ..debugSetEntities([
      const NinjaGoEntity(
        id: 1,
        kind: NinjaGoEntityKind.overheadObstacle,
        lane: NinjaGoLane.center,
        position: NinjaGoController.hitPosition,
      ),
    ])
    ..tick(0.01);

  expect(slideController.state.phase, NinjaGoPhase.running);
});

test('spawns deterministic entities from the provided seed', () {
  final first = NinjaGoController(seed: 4)..startRun();
  final second = NinjaGoController(seed: 4)..startRun();

  for (var i = 0; i < 60; i++) {
    first.tick(0.1);
    second.tick(0.1);
  }

  expect(first.state.entities.map((entity) => entity.kind), second.state.entities.map((entity) => entity.kind));
  expect(first.state.entities.map((entity) => entity.lane), second.state.entities.map((entity) => entity.lane));
});
```

- [ ] **Step 2: Run the test and verify it fails**

Run:

```bash
/Users/vaneVanessa_KidNationssa_kidnation/development/flutter/bin/flutter test test/ninja_go/ninja_go_controller_test.dart
```

Expected: fails because spawning, collisions, scoring, and `debugSetEntities` are not implemented.

- [ ] **Step 3: Add collision helpers to the models**

Update `lib/ninja_go/models/ninja_go_models.dart` by keeping the existing content and adding this getter to `NinjaGoEntity`:

```dart
bool get isPastRunner => position < -0.15;
```

- [ ] **Step 4: Implement run mechanics**

Replace `lib/ninja_go/game/ninja_go_controller.dart` with:

```dart
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
  NinjaGoState state;
  double _spawnTimer = 0;
  int _nextEntityId = 1;

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
    final remaining = math.max(0.0, state.actionTimeRemaining - deltaSeconds);
    final runnerAction = remaining == 0
        ? NinjaGoRunnerAction.running
        : state.runnerAction;
    final movedEntities = state.entities
        .map(
          (entity) => entity.copyWith(
            position: entity.position - deltaSeconds * speed * 0.38,
          ),
        )
        .where((entity) => !entity.isPastRunner && !entity.collected)
        .toList();

    _spawnTimer -= deltaSeconds;
    if (_spawnTimer <= 0) {
      movedEntities.add(_createEntity());
      _spawnTimer = math.max(0.52, 1.15 - speed * 0.08);
    }

    state = state.copyWith(
      runnerAction: runnerAction,
      actionTimeRemaining: remaining,
      distance: distance,
      speed: speed,
      score: distance.floor() + state.stars * starBonus,
      entities: movedEntities,
    );

    _resolveHitWindow();
  }

  void debugSetEntities(List<NinjaGoEntity> entities) {
    state = state.copyWith(entities: entities);
  }

  NinjaGoLane _shiftLane(int offset) {
    final nextIndex = (state.currentLane.index + offset).clamp(
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
    final remainingEntities = <NinjaGoEntity>[];

    for (final entity in state.entities) {
      final inHitWindow = (entity.position - hitPosition).abs() <= hitWindow;
      if (!inHitWindow || entity.lane != state.currentLane) {
        remainingEntities.add(entity);
        continue;
      }

      if (entity.kind == NinjaGoEntityKind.star) {
        stars += 1;
        score += starBonus;
        continue;
      }

      if (_collidesWith(entity)) {
        state = state.copyWith(
          phase: NinjaGoPhase.gameOver,
          score: score,
          stars: stars,
          bestDistance: math.max(state.bestDistance, state.distance),
          bestScore: math.max(state.bestScore, score),
          entities: remainingEntities,
        );
        return;
      }

      remainingEntities.add(entity);
    }

    state = state.copyWith(
      stars: stars,
      score: score,
      entities: remainingEntities,
    );
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
}
```

- [ ] **Step 5: Run the test and verify it passes**

Run:

```bash
/Users/vaneVanessa_KidNationssa_kidnation/development/flutter/bin/flutter test test/ninja_go/ninja_go_controller_test.dart
```

Expected: `All tests passed!`

- [ ] **Step 6: Commit mechanics**

Run:

```bash
git add lib/ninja_go/models/ninja_go_models.dart lib/ninja_go/game/ninja_go_controller.dart test/ninja_go/ninja_go_controller_test.dart
git commit -m "feat: add Ninja Go runner mechanics"
```

---

### Task 4: Custom Painter Scene

**Files:**
- Create: `lib/ninja_go/rendering/ninja_go_painter.dart`

- [ ] **Step 1: Create the painter**

Create `lib/ninja_go/rendering/ninja_go_painter.dart`:

```dart
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../game/ninja_go_controller.dart';
import '../models/ninja_go_models.dart';

class NinjaGoPainter extends CustomPainter {
  const NinjaGoPainter({required this.state});

  final NinjaGoState state;

  @override
  void paint(Canvas canvas, Size size) {
    _drawSky(canvas, size);
    _drawTrack(canvas, size);
    _drawEntities(canvas, size);
    _drawRunner(canvas, size);
    _drawHud(canvas, size);
    if (state.phase == NinjaGoPhase.gameOver) {
      _drawGameOverGlow(canvas, size);
    }
  }

  void _drawSky(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFF69D8FF),
    );
    canvas.drawCircle(
      Offset(size.width * 0.82, size.height * 0.13),
      34,
      Paint()..color = const Color(0xFFFFD23F),
    );
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * 0.34, size.width, size.height * 0.18),
      Paint()..color = const Color(0xFFFFE27A),
    );
  }

  void _drawTrack(Canvas canvas, Size size) {
    final topY = size.height * 0.34;
    final bottomY = size.height;
    final centerX = size.width / 2;
    final road = Path()
      ..moveTo(centerX - size.width * 0.13, topY)
      ..lineTo(centerX + size.width * 0.13, topY)
      ..lineTo(size.width * 0.96, bottomY)
      ..lineTo(size.width * 0.04, bottomY)
      ..close();
    canvas.drawPath(road, Paint()..color = const Color(0xFF343434));

    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.72)
      ..strokeWidth = 3;
    for (final laneT in [1 / 3, 2 / 3]) {
      final topX = centerX - size.width * 0.13 + size.width * 0.26 * laneT;
      final bottomX = size.width * 0.04 + size.width * 0.92 * laneT;
      canvas.drawLine(Offset(topX, topY), Offset(bottomX, bottomY), linePaint);
    }
  }

  void _drawEntities(Canvas canvas, Size size) {
    for (final entity in state.entities) {
      final center = _lanePoint(size, entity.lane, entity.position);
      final scale = _scaleFor(entity.position);
      switch (entity.kind) {
        case NinjaGoEntityKind.star:
          _drawStar(canvas, center, 18 * scale);
        case NinjaGoEntityKind.groundBarrier:
          _drawBlock(canvas, center, Size(54 * scale, 36 * scale), const Color(0xFFFF4D5A));
        case NinjaGoEntityKind.overheadObstacle:
          _drawBlock(canvas, center.translate(0, -36 * scale), Size(66 * scale, 30 * scale), const Color(0xFF8B5CF6));
        case NinjaGoEntityKind.laneBlocker:
          _drawBlock(canvas, center, Size(48 * scale, 72 * scale), Colors.white);
      }
    }
  }

  void _drawRunner(Canvas canvas, Size size) {
    final center = _lanePoint(
      size,
      state.currentLane,
      NinjaGoController.hitPosition,
    );
    final lift = state.runnerAction == NinjaGoRunnerAction.jumping ? 42.0 : 0.0;
    final squash = state.runnerAction == NinjaGoRunnerAction.sliding ? 0.58 : 1.0;
    final rect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: center.translate(0, -lift),
        width: 74,
        height: 96 * squash,
      ),
      const Radius.circular(18),
    );
    canvas.drawRRect(rect, Paint()..color = const Color(0xFFFFD23F));
    canvas.drawRRect(
      rect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..color = const Color(0xFF151515),
    );
    _drawText(canvas, 'KN', rect.outerRect.center, 24, FontWeight.w900, Colors.black);
  }

  void _drawHud(Canvas canvas, Size size) {
    _drawPill(canvas, const Offset(14, 14), 'Score ${state.score}', 120);
    _drawPill(canvas, Offset(size.width - 134, 14), 'Stars ${state.stars}', 120);
    _drawPill(canvas, Offset(14, 56), '${state.distance.floor()} m', 100);
  }

  void _drawGameOverGlow(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = Colors.black.withValues(alpha: 0.12),
    );
  }

  Offset _lanePoint(Size size, NinjaGoLane lane, double position) {
    final t = (1 - position).clamp(0.0, 1.0);
    final y = size.height * (0.36 + 0.56 * t);
    final spread = size.width * (0.10 + 0.36 * t);
    final laneOffset = switch (lane) {
      NinjaGoLane.left => -spread,
      NinjaGoLane.center => 0.0,
      NinjaGoLane.right => spread,
    };
    return Offset(size.width / 2 + laneOffset, y);
  }

  double _scaleFor(double position) {
    return 0.42 + (1 - position).clamp(0.0, 1.0) * 0.92;
  }

  void _drawBlock(Canvas canvas, Offset center, Size size, Color color) {
    final rect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: size.width, height: size.height),
      const Radius.circular(8),
    );
    canvas.drawRRect(rect, Paint()..color = color);
    canvas.drawRRect(
      rect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..color = const Color(0xFF151515),
    );
  }

  void _drawStar(Canvas canvas, Offset center, double radius) {
    final path = Path();
    for (var i = 0; i < 10; i++) {
      final angle = -math.pi / 2 + i * math.pi / 5;
      final r = i.isEven ? radius : radius * 0.45;
      final point = center + Offset(math.cos(angle) * r, math.sin(angle) * r);
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    canvas.drawPath(path, Paint()..color = const Color(0xFFFFD23F));
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = const Color(0xFF151515),
    );
  }

  void _drawPill(Canvas canvas, Offset offset, String text, double width) {
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(offset.dx, offset.dy, width, 32),
      const Radius.circular(18),
    );
    canvas.drawRRect(rect, Paint()..color = Colors.white.withValues(alpha: 0.92));
    _drawText(canvas, text, rect.outerRect.center, 13, FontWeight.w900, Colors.black);
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset center,
    double fontSize,
    FontWeight fontWeight,
    Color color,
  ) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(fontSize: fontSize, fontWeight: fontWeight, color: color),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: 180);
    painter.paint(canvas, center - Offset(painter.width / 2, painter.height / 2));
  }

  @override
  bool shouldRepaint(covariant NinjaGoPainter oldDelegate) {
    return oldDelegate.state != state;
  }
}
```

- [ ] **Step 2: Run analyzer**

Run:

```bash
/Users/vaneVanessa_KidNationssa_kidnation/development/flutter/bin/flutter analyze
```

Expected: no analyzer errors from `ninja_go_painter.dart`.

- [ ] **Step 3: Commit painter**

Run:

```bash
git add lib/ninja_go/rendering/ninja_go_painter.dart
git commit -m "feat: draw Ninja Go runner scene"
```

---

### Task 5: Ninja Go Screen And Gestures

**Files:**
- Create: `lib/ninja_go/ui/ninja_go_screen.dart`
- Test: `test/widget_test.dart`

- [ ] **Step 1: Add a failing widget test for the standalone screen**

Add these imports to `test/widget_test.dart`:

```dart
import 'package:kidnation_mobile_games/ninja_go/ui/ninja_go_screen.dart';
```

Add this widget test:

```dart
testWidgets('Ninja Go screen starts and shows game over after collision controls are available', (tester) async {
  await tester.pumpWidget(const MaterialApp(home: NinjaGoScreen()));

  expect(find.text('KidNation Ninja Go'), findsOneWidget);
  expect(find.text('Start Run'), findsOneWidget);

  await tester.tap(find.text('Start Run'));
  await tester.pump();

  expect(find.text('Score'), findsOneWidget);
  expect(find.text('Jump'), findsOneWidget);
  expect(find.text('Slide'), findsOneWidget);
});
```

- [ ] **Step 2: Run the widget test and verify it fails**

Run:

```bash
/Users/vaneVanessa_KidNationssa_kidnation/development/flutter/bin/flutter test test/widget_test.dart
```

Expected: fails because `NinjaGoScreen` does not exist.

- [ ] **Step 3: Create the screen**

Create `lib/ninja_go/ui/ninja_go_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../game/ninja_go_controller.dart';
import '../models/ninja_go_models.dart';
import '../rendering/ninja_go_painter.dart';

class NinjaGoScreen extends StatefulWidget {
  const NinjaGoScreen({super.key});

  @override
  State<NinjaGoScreen> createState() => _NinjaGoScreenState();
}

class _NinjaGoScreenState extends State<NinjaGoScreen>
    with SingleTickerProviderStateMixin {
  late final NinjaGoController _controller;
  late final Ticker _ticker;
  Duration? _lastTick;

  @override
  void initState() {
    super.initState();
    _controller = NinjaGoController();
    _ticker = createTicker(_handleTick)..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _handleTick(Duration elapsed) {
    final lastTick = _lastTick;
    _lastTick = elapsed;
    if (lastTick == null) {
      return;
    }
    final delta =
        (elapsed - lastTick).inMicroseconds / Duration.microsecondsPerSecond;
    setState(() {
      _controller.tick(delta);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = _controller.state;
    return Scaffold(
      backgroundColor: const Color(0xFF69D8FF),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _TopBar(state: state),
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onHorizontalDragEnd: _handleHorizontalDrag,
                onVerticalDragEnd: _handleVerticalDrag,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CustomPaint(painter: NinjaGoPainter(state: state)),
                    if (state.phase == NinjaGoPhase.ready)
                      _StartOverlay(onStart: _startRun),
                    if (state.phase == NinjaGoPhase.gameOver)
                      _GameOverOverlay(state: state, onRetry: _startRun),
                  ],
                ),
              ),
            ),
            _ActionButtons(
              phase: state.phase,
              onLeft: () => setState(_controller.moveLeft),
              onRight: () => setState(_controller.moveRight),
              onJump: () => setState(_controller.jump),
              onSlide: () => setState(_controller.slide),
            ),
          ],
        ),
      ),
    );
  }

  void _startRun() {
    setState(_controller.startRun);
  }

  void _handleHorizontalDrag(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    if (velocity < 0) {
      setState(_controller.moveRight);
    } else if (velocity > 0) {
      setState(_controller.moveLeft);
    }
  }

  void _handleVerticalDrag(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    if (velocity < 0) {
      setState(_controller.jump);
    } else if (velocity > 0) {
      setState(_controller.slide);
    }
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.state});

  final NinjaGoState state;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'KidNation Ninja Go',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
          ),
          Text(
            'Score ${state.score}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
          ),
        ],
      ),
    );
  }
}

class _StartOverlay extends StatelessWidget {
  const _StartOverlay({required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.94),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Ready to run?',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: onStart,
                child: const Text('Start Run'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GameOverOverlay extends StatelessWidget {
  const _GameOverOverlay({required this.state, required this.onRetry});

  final NinjaGoState state;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.96),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Run Complete',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
              const SizedBox(height: 8),
              Text('Distance ${state.distance.floor()} m'),
              Text('Stars ${state.stars}'),
              Text('Best ${state.bestScore}'),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: onRetry,
                child: const Text('Play Again'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({
    required this.phase,
    required this.onLeft,
    required this.onRight,
    required this.onJump,
    required this.onSlide,
  });

  final NinjaGoPhase phase;
  final VoidCallback onLeft;
  final VoidCallback onRight;
  final VoidCallback onJump;
  final VoidCallback onSlide;

  @override
  Widget build(BuildContext context) {
    final enabled = phase == NinjaGoPhase.running;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      child: Row(
        children: [
          _SmallControl(label: 'Left', enabled: enabled, onPressed: onLeft),
          const SizedBox(width: 8),
          _SmallControl(label: 'Jump', enabled: enabled, onPressed: onJump),
          const SizedBox(width: 8),
          _SmallControl(label: 'Slide', enabled: enabled, onPressed: onSlide),
          const SizedBox(width: 8),
          _SmallControl(label: 'Right', enabled: enabled, onPressed: onRight),
        ],
      ),
    );
  }
}

class _SmallControl extends StatelessWidget {
  const _SmallControl({
    required this.label,
    required this.enabled,
    required this.onPressed,
  });

  final String label;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: FilledButton(
        onPressed: enabled ? onPressed : null,
        child: Text(label, maxLines: 1),
      ),
    );
  }
}
```

- [ ] **Step 4: Run widget tests and analyzer**

Run:

```bash
/Users/vaneVanessa_KidNationssa_kidnation/development/flutter/bin/flutter test test/widget_test.dart
/Users/vaneVanessa_KidNationssa_kidnation/development/flutter/bin/flutter analyze
```

Expected: widget tests pass and analyzer reports no errors.

- [ ] **Step 5: Commit screen**

Run:

```bash
git add lib/ninja_go/ui/ninja_go_screen.dart test/widget_test.dart
git commit -m "feat: add Ninja Go screen"
```

---

### Task 6: Home Screen Integration

**Files:**
- Modify: `lib/home_screen.dart`
- Modify: `test/widget_test.dart`

- [ ] **Step 1: Add failing home-screen tests**

Update the existing `shows the game picker` test in `test/widget_test.dart` to include `Ninja Go`:

```dart
testWidgets('shows the game picker', (tester) async {
  await tester.pumpWidget(const KidNationMobileGamesApp());

  expect(find.text('KidNation Games'), findsOneWidget);
  expect(find.text('Ninja Runner'), findsOneWidget);
  expect(find.text('Bubble Blast'), findsOneWidget);
  expect(find.text('Ninja Go'), findsOneWidget);
});
```

Add this test:

```dart
testWidgets('opens Ninja Go from the game picker', (tester) async {
  await tester.pumpWidget(const KidNationMobileGamesApp());

  await tester.tap(find.text('Ninja Go'));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));

  expect(find.text('KidNation Ninja Go'), findsOneWidget);
  expect(find.text('Start Run'), findsOneWidget);
});
```

- [ ] **Step 2: Run the widget test and verify it fails**

Run:

```bash
/Users/vaneVanessa_KidNationssa_kidnation/development/flutter/bin/flutter test test/widget_test.dart
```

Expected: fails because `HomeScreen` does not expose `Ninja Go`.

- [ ] **Step 3: Add Ninja Go to the game picker**

Modify `lib/home_screen.dart`:

```dart
import 'ninja_go/ui/ninja_go_screen.dart';
```

Add this `_GameButton` between `Ninja Runner` and `Bubble Blast`:

```dart
const SizedBox(height: 12),
_GameButton(
  title: 'Ninja Go',
  subtitle: 'Dodge obstacles in a three-lane reflex run.',
  color: const Color(0xFF16A34A),
  onPressed: () => _open(context, const NinjaGoScreen()),
),
```

Update the intro copy from learning-only language:

```dart
'Choose a quick KidNation game.'
```

- [ ] **Step 4: Run widget tests**

Run:

```bash
/Users/vaneVanessa_KidNationssa_kidnation/development/flutter/bin/flutter test test/widget_test.dart
```

Expected: widget tests pass.

- [ ] **Step 5: Commit integration**

Run:

```bash
git add lib/home_screen.dart test/widget_test.dart
git commit -m "feat: add Ninja Go to game picker"
```

---

### Task 7: Full Verification

**Files:**
- Verify all changed files.

- [ ] **Step 1: Run all tests**

Run:

```bash
/Users/vaneVanessa_KidNationssa_kidnation/development/flutter/bin/flutter test
```

Expected: all tests pass.

- [ ] **Step 2: Run analyzer**

Run:

```bash
/Users/vaneVanessa_KidNationssa_kidnation/development/flutter/bin/flutter analyze
```

Expected: no analyzer errors.

- [ ] **Step 3: Run mobile build readiness script**

Run:

```bash
./scripts/check_mobile_builds.sh
```

Expected: script completes or reports only known local platform setup blockers from `docs/mobile-build-readiness.md`.

- [ ] **Step 4: Optional local run**

Run:

```bash
/Users/vaneVanessa_KidNationssa_kidnation/development/flutter/bin/flutter run
```

Expected: app launches and the game picker includes `Ninja Go`. Manual smoke path: open `Ninja Go`, tap `Start Run`, use Left/Right/Jump/Slide buttons or swipe gestures, collide with an obstacle, and tap `Play Again`.

- [ ] **Step 5: Commit verification fixes if needed**

If verification finds small issues, fix them and commit with:

```bash
git add <fixed-files>
git commit -m "fix: polish Ninja Go verification issues"
```

If no fixes are needed, do not create an empty commit.

---

## Self-Review Notes

- Spec coverage: this plan covers separate module creation, pure reflex gameplay, three lanes, jump/slide/lane controls, stars, score, speed ramp, custom painter art, home-screen integration, and tests.
- Scope: the plan intentionally excludes Flame, production assets, audio, persistence, educational prompts, and modifications to `Ninja Runner` mechanics.
- Type consistency: public names are `NinjaGoController`, `NinjaGoState`, `NinjaGoPhase`, `NinjaGoLane`, `NinjaGoRunnerAction`, `NinjaGoEntity`, and `NinjaGoEntityKind`.
