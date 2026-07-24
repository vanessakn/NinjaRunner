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
