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

    test('jump and slide actions return to running after their timers expire',
        () {
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

    test('increases distance score and speed while running', () {
      final controller = NinjaGoController(seed: 7)..startRun();

      controller.tick(1);
      controller.tick(1);

      expect(controller.state.distance, greaterThan(0));
      expect(controller.state.score, controller.state.distance.floor());
      expect(controller.state.speed, greaterThan(1));
    });

    test('collects current lane star in the hit window', () {
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

    test('collects current lane star when a large tick crosses the hit window',
        () {
      final controller = NinjaGoController(seed: 7)..startRun();

      controller.debugSetEntities([
        const NinjaGoEntity(
          id: 1,
          kind: NinjaGoEntityKind.star,
          lane: NinjaGoLane.center,
          position: NinjaGoController.hitPosition +
              NinjaGoController.hitWindow +
              0.01,
        ),
      ]);

      controller.tick(0.6);

      expect(controller.state.stars, 1);
      expect(controller.state.score, greaterThanOrEqualTo(50));
      expect(controller.state.entities, isEmpty);
    });

    test('current lane lane blocker in the hit window ends the run', () {
      final controller = NinjaGoController(seed: 7)..startRun();

      controller.tick(1);
      final distanceBeforeCollision = controller.state.distance;
      final scoreBeforeCollision = controller.state.score;
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
      expect(controller.state.bestDistance,
          greaterThanOrEqualTo(distanceBeforeCollision));
      expect(controller.state.bestScore,
          greaterThanOrEqualTo(scoreBeforeCollision));
    });

    test(
        'current lane lane blocker ends the run when a large tick crosses the hit window',
        () {
      final controller = NinjaGoController(seed: 7)..startRun();

      controller.debugSetEntities([
        const NinjaGoEntity(
          id: 1,
          kind: NinjaGoEntityKind.laneBlocker,
          lane: NinjaGoLane.center,
          position: NinjaGoController.hitPosition +
              NinjaGoController.hitWindow +
              0.01,
        ),
      ]);

      controller.tick(0.6);

      expect(controller.state.phase, NinjaGoPhase.gameOver);
      expect(controller.state.bestDistance, controller.state.distance);
      expect(controller.state.bestScore, controller.state.score);
    });

    test('jumping avoids ground barriers and sliding avoids overhead obstacles',
        () {
      final controller = NinjaGoController(seed: 7)..startRun();

      controller.jump();
      controller.debugSetEntities([
        const NinjaGoEntity(
          id: 1,
          kind: NinjaGoEntityKind.groundBarrier,
          lane: NinjaGoLane.center,
          position: NinjaGoController.hitPosition,
        ),
      ]);

      controller.tick(0.01);

      expect(controller.state.phase, NinjaGoPhase.running);

      controller.slide();
      controller.debugSetEntities([
        const NinjaGoEntity(
          id: 2,
          kind: NinjaGoEntityKind.overheadObstacle,
          lane: NinjaGoLane.center,
          position: NinjaGoController.hitPosition,
        ),
      ]);

      controller.tick(0.01);

      expect(controller.state.phase, NinjaGoPhase.running);
    });

    test('jumping avoids swept ground barriers crossed before jump expires',
        () {
      final controller = NinjaGoController(seed: 7)..startRun();

      controller.jump();
      controller.debugSetEntities([
        const NinjaGoEntity(
          id: 1,
          kind: NinjaGoEntityKind.groundBarrier,
          lane: NinjaGoLane.center,
          position: NinjaGoController.hitPosition +
              NinjaGoController.hitWindow +
              0.01,
        ),
      ]);

      controller.tick(0.7);

      expect(controller.state.runnerAction, NinjaGoRunnerAction.running);
      expect(controller.state.phase, NinjaGoPhase.running);
    });

    test('sliding avoids swept overhead obstacles crossed before slide expires',
        () {
      final controller = NinjaGoController(seed: 7)..startRun();

      controller.slide();
      controller.debugSetEntities([
        const NinjaGoEntity(
          id: 1,
          kind: NinjaGoEntityKind.overheadObstacle,
          lane: NinjaGoLane.center,
          position: NinjaGoController.hitPosition +
              NinjaGoController.hitWindow +
              0.01,
        ),
      ]);

      controller.tick(0.7);

      expect(controller.state.runnerAction, NinjaGoRunnerAction.running);
      expect(controller.state.phase, NinjaGoPhase.running);
    });

    test('spawns deterministic entity sequences with the same seed', () {
      final first = NinjaGoController(seed: 7)..startRun();
      final second = NinjaGoController(seed: 7)..startRun();

      for (var i = 0; i < 18; i += 1) {
        first.tick(0.2);
        second.tick(0.2);
      }

      final firstSequence = first.state.entities
          .map((entity) => (kind: entity.kind, lane: entity.lane))
          .toList();
      final secondSequence = second.state.entities
          .map((entity) => (kind: entity.kind, lane: entity.lane))
          .toList();

      expect(firstSequence, isNotEmpty);
      expect(firstSequence, secondSequence);
    });

    test('ignores movement and actions before the run starts', () {
      final controller = NinjaGoController(seed: 7);

      controller.moveLeft();
      controller.jump();
      controller.slide();

      expect(controller.state.currentLane, NinjaGoLane.center);
      expect(controller.state.runnerAction, NinjaGoRunnerAction.running);
    });
  });
}
