import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kidnation_mobile_games/bubble_blast/data/sample_bubble_pack.dart';
import 'package:kidnation_mobile_games/bubble_blast/game/bubble_blast_controller.dart';

void main() {
  test('starts a round and shows the first prompt', () {
    final controller = BubbleBlastController(contentPack: sampleBubblePack());

    controller.startRound();

    expect(controller.state.phase, BubbleBlastPhase.playing);
    expect(controller.currentPrompt.id, 'kind-action');
    expect(controller.visibleBubbles, hasLength(3));
    expect(controller.state.audioCue, BubbleAudioCue.roundStart);
  });

  test('correct bubble increases score and streak', () {
    final controller = BubbleBlastController(contentPack: sampleBubblePack())
      ..startRound();

    final result = controller.selectBubble('share');

    expect(result.isCorrect, isTrue);
    expect(controller.state.score, 1);
    expect(controller.state.streak, 1);
    expect(controller.state.popProgress, 0);
    expect(controller.state.audioCue, BubbleAudioCue.correctPop);
    expect(
      controller.feedbackAutoAdvanceDelay,
      const Duration(milliseconds: 850),
    );
    expect(controller.state.phase, BubbleBlastPhase.feedback);
  });

  test('incorrect bubble resets streak and keeps score', () {
    final controller = BubbleBlastController(contentPack: sampleBubblePack())
      ..startRound();

    final result = controller.selectBubble('wait');

    expect(result.isCorrect, isFalse);
    expect(controller.state.score, 0);
    expect(controller.state.streak, 0);
    expect(result.feedback, 'Sharing helps friends feel included.');
    expect(controller.state.audioCue, BubbleAudioCue.wrongBubble);
    expect(
      controller.feedbackAutoAdvanceDelay,
      const Duration(milliseconds: 1350),
    );
  });

  test('advances through fifteen prompts and completes the round', () {
    final controller = BubbleBlastController(contentPack: sampleBubblePack())
      ..startRound();

    for (final prompt in controller.contentPack.prompts) {
      controller.selectBubble(prompt.correctAnswerId);
      controller.continueAfterFeedback();
      if (controller.state.phase == BubbleBlastPhase.levelComplete) {
        controller.continueAfterFeedback();
      }
    }

    expect(controller.state.phase, BubbleBlastPhase.summary);
    expect(controller.state.score, 15);
    expect(controller.state.currentPromptIndex, 14);
    expect(controller.state.audioCue, BubbleAudioCue.roundComplete);
  });

  test('shows level complete before advancing to a higher level', () {
    final controller = BubbleBlastController(contentPack: sampleBubblePack())
      ..startRound();

    for (var index = 0; index < 5; index++) {
      controller.selectBubble(controller.currentPrompt.correctAnswerId);
      controller.continueAfterFeedback();
    }

    expect(controller.state.phase, BubbleBlastPhase.levelComplete);
    expect(controller.state.completedLevel, 1);
    expect(controller.state.audioCue, BubbleAudioCue.levelComplete);

    controller.continueAfterFeedback();

    expect(controller.state.phase, BubbleBlastPhase.playing);
    expect(controller.currentPrompt.level, 2);
  });

  test('moves higher level bubbles faster', () {
    final controller = BubbleBlastController(contentPack: sampleBubblePack())
      ..startRound();

    final levelOneBefore = controller.visibleBubbles.first.y;
    controller.tick(0.5);
    final levelOneDelta = levelOneBefore - controller.visibleBubbles.first.y;

    for (var index = 0; index < 5; index++) {
      controller.selectBubble(controller.currentPrompt.correctAnswerId);
      controller.continueAfterFeedback();
    }
    controller.continueAfterFeedback();
    final levelTwoBefore = controller.visibleBubbles.first.y;
    controller.tick(0.5);
    final levelTwoDelta = levelTwoBefore - controller.visibleBubbles.first.y;

    expect(levelTwoDelta, greaterThan(levelOneDelta));
  });

  test('tick advances pop feedback while feedback is visible', () {
    final controller = BubbleBlastController(contentPack: sampleBubblePack())
      ..startRound();

    controller.selectBubble('share');
    controller.tick(0.25);

    expect(controller.state.popProgress, greaterThan(0));
  });

  test('tick moves bubbles upward while playing', () {
    final controller = BubbleBlastController(contentPack: sampleBubblePack())
      ..startRound();
    final before = controller.visibleBubbles.first.y;

    controller.tick(0.5);

    expect(controller.visibleBubbles.first.y, lessThan(before));
  });

  test('finds the answer tapped inside a visible bubble', () {
    final controller = BubbleBlastController(contentPack: sampleBubblePack())
      ..startRound();
    const playSize = Size(400, 600);
    final bubble = controller.visibleBubbles.first;
    final tapPosition =
        Offset(bubble.x * playSize.width, bubble.y * playSize.height);

    final answerId = controller.answerIdAt(tapPosition, playSize);

    expect(answerId, bubble.answer.id);
  });

  test('returns null when a tap misses every bubble', () {
    final controller = BubbleBlastController(contentPack: sampleBubblePack())
      ..startRound();

    final answerId = controller.answerIdAt(Offset.zero, const Size(400, 600));

    expect(answerId, isNull);
  });
}
