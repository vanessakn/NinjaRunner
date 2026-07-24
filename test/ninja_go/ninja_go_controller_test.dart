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
