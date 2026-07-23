import 'package:flutter_test/flutter_test.dart';
import 'package:kidnation_mobile_games/ninja_runner/analytics/analytics_logger.dart';
import 'package:kidnation_mobile_games/ninja_runner/data/sample_content_pack.dart';
import 'package:kidnation_mobile_games/ninja_runner/game/runner_controller.dart';

void main() {
  test('starts a round and shows the first prompt', () {
    final logger = AnalyticsLogger();
    final controller = RunnerController(
      level: sampleNinjaRunnerLevels().first,
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
      level: sampleNinjaRunnerLevels().first,
      analyticsLogger: AnalyticsLogger(),
    )..startRound();

    final result = controller.selectAnswer('share');

    expect(result.isCorrect, isTrue);
    expect(controller.state.score, 1);
    expect(controller.state.streak, 1);
    expect(controller.state.phase, RunnerPhase.feedback);
  });

  test('second answer during feedback does not change state or analytics', () {
    final logger = AnalyticsLogger();
    final controller = RunnerController(
      level: sampleNinjaRunnerLevels().first,
      analyticsLogger: logger,
    )..startRound();

    controller.selectAnswer('share');
    final eventCount = logger.events.length;
    final score = controller.state.score;
    final streak = controller.state.streak;

    expect(
      () => controller.selectAnswer('share'),
      throwsA(
        isA<StateError>().having(
          (error) => error.message,
          'message',
          'Answers can only be selected while running.',
        ),
      ),
    );

    expect(controller.state.score, score);
    expect(controller.state.streak, streak);
    expect(logger.events.length, eventCount);
  });

  test('incorrect answer resets streak and keeps score', () {
    final controller = RunnerController(
      level: sampleNinjaRunnerLevels().first,
      analyticsLogger: AnalyticsLogger(),
    )..startRound();

    final result = controller.selectAnswer('grab');

    expect(result.isCorrect, isFalse);
    expect(controller.state.score, 0);
    expect(controller.state.streak, 0);
    expect(result.feedback, 'Nice choice! Sharing helps your friends.');
  });

  test(
      'unknown answer while running is rejected without state or analytics changes',
      () {
    final logger = AnalyticsLogger();
    final controller = RunnerController(
      level: sampleNinjaRunnerLevels().first,
      analyticsLogger: logger,
    )..startRound();
    final state = controller.state;
    final eventCount = logger.events.length;

    expect(
      () => controller.selectAnswer('missing-answer'),
      throwsA(
        isA<ArgumentError>()
            .having((error) => error.name, 'name', 'answerId')
            .having(
              (error) => error.message,
              'message',
              'Answer is not available for the current prompt.',
            ),
      ),
    );

    expect(controller.state, same(state));
    expect(logger.events.length, eventCount);
  });

  test('advances through five prompts and completes the round', () {
    final controller = RunnerController(
      level: sampleNinjaRunnerLevels().first,
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

  test('summary transition clears feedback result and resets progress', () {
    final controller = RunnerController(
      level: sampleNinjaRunnerLevels().first,
      analyticsLogger: AnalyticsLogger(),
    )..startRound();

    for (final answerId in ['share', 'gentle', 'try', 'listen']) {
      controller.selectAnswer(answerId);
      controller.continueAfterFeedback();
    }

    controller.tick(1);
    controller.selectAnswer('cheer');
    controller.continueAfterFeedback();

    expect(controller.state.phase, RunnerPhase.summary);
    expect(controller.state.runnerProgress, 0);
    expect(controller.state.lastResult, isNull);
  });

  test('runner speed comes from selected level', () {
    final controller = RunnerController(
      level: sampleNinjaRunnerLevels()[2],
      analyticsLogger: AnalyticsLogger(),
    )..startRound();

    controller.tick(1);

    expect(controller.state.runnerProgress, 0.2);
  });

  test('round completion reports whether selected level is complete', () {
    final logger = AnalyticsLogger();
    final controller = RunnerController(
      level: sampleNinjaRunnerLevels()[1],
      analyticsLogger: logger,
    )..startRound();

    for (final answerId in [
      'shout',
      'invite',
      'practice',
      'take-turns',
      'look'
    ]) {
      controller.selectAnswer(answerId);
      controller.continueAfterFeedback();
    }

    expect(controller.isLevelComplete, isTrue);
    expect(logger.events.last.payload, containsPair('level_complete', true));
  });

  test('perfect Level 1 round exposes a kid-friendly result title', () {
    final controller = RunnerController(
      level: sampleNinjaRunnerLevels().first,
      analyticsLogger: AnalyticsLogger(),
    )..startRound();

    for (final answerId in ['share', 'gentle', 'try', 'listen', 'cheer']) {
      controller.selectAnswer(answerId);
      controller.continueAfterFeedback();
    }

    expect(controller.isPerfectRun, isTrue);
    expect(controller.roundResultTitle, 'Perfect run!');
  });
}
