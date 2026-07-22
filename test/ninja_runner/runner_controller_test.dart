import 'package:flutter_test/flutter_test.dart';
import 'package:kidnation_mobile_games/ninja_runner/analytics/analytics_logger.dart';
import 'package:kidnation_mobile_games/ninja_runner/data/sample_content_pack.dart';
import 'package:kidnation_mobile_games/ninja_runner/game/runner_controller.dart';

void main() {
  test('starts a round and shows the first prompt', () {
    final logger = AnalyticsLogger();
    final controller = RunnerController(
      contentPack: sampleContentPack(),
      analyticsLogger: logger,
    );

    controller.startRound();

    expect(controller.state.phase, RunnerPhase.running);
    expect(controller.currentPrompt.id, 'helpful-action');
    expect(logger.events.map((event) => event.name), contains('round_start'));
    expect(logger.events.map((event) => event.name), contains('prompt_shown'));
  });

  test('correct answer increases score and streak', () {
    final controller = RunnerController(
      contentPack: sampleContentPack(),
      analyticsLogger: AnalyticsLogger(),
    )..startRound();

    final result = controller.selectAnswer('share');

    expect(result.isCorrect, isTrue);
    expect(controller.state.score, 1);
    expect(controller.state.streak, 1);
    expect(controller.state.phase, RunnerPhase.feedback);
  });

  test('incorrect answer resets streak and keeps score', () {
    final controller = RunnerController(
      contentPack: sampleContentPack(),
      analyticsLogger: AnalyticsLogger(),
    )..startRound();

    final result = controller.selectAnswer('grab');

    expect(result.isCorrect, isFalse);
    expect(controller.state.score, 0);
    expect(controller.state.streak, 0);
    expect(result.feedback, 'Nice choice! Sharing helps your friends.');
  });

  test('advances through five prompts and completes the round', () {
    final controller = RunnerController(
      contentPack: sampleContentPack(),
      analyticsLogger: AnalyticsLogger(),
    )..startRound();

    for (final answerId in ['share', 'gentle', 'try', 'listen', 'cheer']) {
      controller.selectAnswer(answerId);
      controller.continueAfterFeedback();
    }

    expect(controller.state.phase, RunnerPhase.summary);
    expect(controller.state.score, 5);
    expect(controller.state.currentPromptIndex, 4);
  });
}
