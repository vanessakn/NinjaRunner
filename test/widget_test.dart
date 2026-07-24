import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kidnation_mobile_games/main.dart';
import 'package:kidnation_mobile_games/ninja_runner/game/level_progress_store.dart';
import 'package:kidnation_mobile_games/ninja_runner/rendering/kidnation_visual_theme.dart';
import 'package:kidnation_mobile_games/ninja_runner/ui/ninja_runner_screen.dart';

void main() {
  testWidgets('shows the Ninja Runner start screen', (tester) async {
    await pumpNinjaRunner(tester);

    expect(find.text('Ninja Runner'), findsOneWidget);
    expect(find.text('Warm-Up Dash'), findsOneWidget);
    expect(find.text('Quick Choice Dash'), findsOneWidget);
    expect(find.text('Star Streak Challenge'), findsOneWidget);
    expect(find.text('Friendship Focus Dash'), findsOneWidget);
    expect(find.text('Unlocked'), findsOneWidget);
    expect(find.text('Locked'), findsNWidgets(3));
    expect(find.text('Start Run'), findsOneWidget);
    expect(find.text('Jordan'), findsOneWidget);
    expect(find.text('Level 1'), findsOneWidget);
    expect(find.text('Help Jordan choose the kind gate.'), findsOneWidget);
    expect(find.text('5 quick choices'), findsOneWidget);
    expect(find.text('Runner Mode'), findsOneWidget);
  });

  testWidgets('uses KidNation visual shell colors', (tester) async {
    await pumpNinjaRunner(tester);

    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    expect(scaffold.backgroundColor, KidNationVisualTheme.backgroundBottom);
  });

  testWidgets('locked levels cannot be selected before unlock', (tester) async {
    await pumpNinjaRunner(tester);

    await tester.tap(find.text('Quick Choice Dash'));
    await tester.pump();

    expect(find.text('Jordan'), findsOneWidget);
    expect(find.text('Nari'), findsNothing);
  });

  testWidgets('completing first level unlocks next level', (tester) async {
    final feedbackEffects = RecordingRunnerFeedbackEffects();
    await pumpNinjaRunner(tester, feedbackEffects: feedbackEffects);

    await tester.tap(find.text('Start Run'));
    await tester.pump();

    for (final answer in ['share', 'gentle', 'try again', 'listen', 'cheer']) {
      await tester.tap(find.text(answer));
      await tester.pump();
      final keepRunning = find.text('Keep Running');
      if (keepRunning.evaluate().isNotEmpty) {
        await tester.tap(keepRunning);
        await tester.pump();
      }
    }

    expect(find.text('Level Complete!'), findsOneWidget);
    expect(find.text('Perfect run!'), findsOneWidget);
    expect(find.text('Next Level'), findsOneWidget);
    expect(
      feedbackEffects.events,
      [
        'start',
        'correct',
        'correct',
        'correct',
        'correct',
        'correct',
        'complete'
      ],
    );

    await tester.tap(find.text('Next Level'));
    await tester.pump();

    expect(find.text('Nari'), findsOneWidget);
    expect(find.text('breathe'), findsOneWidget);
  });

  testWidgets('restores unlocked levels from local progress', (tester) async {
    final progressStore = MemoryLevelProgressStore(
      initialHighestUnlockedLevelIndex: 1,
    );

    await tester.pumpWidget(
      MaterialApp(home: NinjaRunnerScreen(progressStore: progressStore)),
    );
    await tester.pump();

    expect(find.text('Locked'), findsNWidgets(2));

    await tester.tap(find.text('Quick Choice Dash'));
    await tester.pump();

    expect(find.text('Nari'), findsOneWidget);
  });

  testWidgets('saves progress when the next level unlocks', (tester) async {
    final progressStore = MemoryLevelProgressStore();

    await tester.pumpWidget(
      MaterialApp(home: NinjaRunnerScreen(progressStore: progressStore)),
    );
    await tester.pump();

    await tester.tap(find.text('Start Run'));
    await tester.pump();

    for (final answer in ['share', 'gentle', 'try again', 'listen', 'cheer']) {
      await tester.tap(find.text(answer));
      await tester.pump();
      final keepRunning = find.text('Keep Running');
      if (keepRunning.evaluate().isNotEmpty) {
        await tester.tap(keepRunning);
        await tester.pump();
      }
    }

    await tester.tap(find.text('Next Level'));
    await tester.pump();

    expect(progressStore.highestUnlockedLevelIndex, 1);
  });

  testWidgets('restores best scores and complete states from progress',
      (tester) async {
    final progressStore = MemoryLevelProgressStore(
      initialHighestUnlockedLevelIndex: 1,
      initialBestScoresByLevelId: {'warm-up-dash': 5},
    );

    await pumpNinjaRunner(tester, progressStore: progressStore);

    expect(find.text('Complete'), findsOneWidget);
    expect(find.text('Unlocked'), findsOneWidget);
    expect(find.text('Locked'), findsNWidgets(2));
    expect(find.text('Best: 5/5'), findsOneWidget);
  });

  testWidgets('saves best score without lowering it on replay', (tester) async {
    final progressStore = MemoryLevelProgressStore(
      initialBestScoresByLevelId: {'warm-up-dash': 4},
    );

    await pumpNinjaRunner(tester, progressStore: progressStore);

    await tester.tap(find.text('Start Run'));
    await tester.pump();

    for (final answer in [
      'share',
      'bossy',
      'hide forever',
      'listen',
      'tease'
    ]) {
      await tester.tap(find.text(answer));
      await tester.pump();
      final keepRunning = find.text('Keep Running');
      if (keepRunning.evaluate().isNotEmpty) {
        await tester.tap(keepRunning);
        await tester.pump();
      }
    }

    expect(progressStore.bestScoresByLevelId['warm-up-dash'], 4);
    expect(find.text('Best: 4/5'), findsOneWidget);
  });

  testWidgets('start screen settles while idle', (tester) async {
    await pumpNinjaRunner(tester);

    await tester.pumpAndSettle(
      const Duration(milliseconds: 16),
      EnginePhase.sendSemanticsUpdate,
      const Duration(milliseconds: 200),
    );

    expect(find.text('Start Run'), findsOneWidget);
  });

  testWidgets('running state shows a clear gate choice hint', (tester) async {
    await pumpNinjaRunner(tester);

    await tester.tap(find.text('Start Run'));
    await tester.pump();

    expect(find.text('Choose a gate'), findsOneWidget);
    expect(find.text('Run up the lane'), findsOneWidget);
    expect(find.text('Collect stars by choosing kind gates'), findsOneWidget);
    expect(find.text('Streak 0'), findsOneWidget);
    expect(find.text('share'), findsOneWidget);
    expect(find.text('grab'), findsOneWidget);
  });

  testWidgets('correct gate choice shows streak boost feedback',
      (tester) async {
    final feedbackEffects = RecordingRunnerFeedbackEffects();
    await pumpNinjaRunner(tester, feedbackEffects: feedbackEffects);

    await tester.tap(find.text('Start Run'));
    await tester.pump();
    await tester.tap(find.text('share'));
    await tester.pump();

    expect(feedbackEffects.events, ['start', 'correct']);
    expect(find.text('Nice choice!'), findsOneWidget);
    expect(find.text('Kind gate! +1 star'), findsOneWidget);
    expect(find.text('Streak 1'), findsOneWidget);
    expect(find.text('Keep Running'), findsOneWidget);
  });

  testWidgets('right half of vertical lane chooses the right gate',
      (tester) async {
    final feedbackEffects = RecordingRunnerFeedbackEffects();
    await pumpNinjaRunner(tester, feedbackEffects: feedbackEffects);

    await tester.tap(find.text('Start Run'));
    await tester.pump();

    final playfield = find.byKey(const Key('runner-playfield'));
    final topLeft = tester.getTopLeft(playfield);
    final size = tester.getSize(playfield);
    await tester.tapAt(topLeft + Offset(size.width * 0.6, size.height * 0.52));
    await tester.pump();

    expect(feedbackEffects.events, ['start', 'wrong']);
    expect(find.text('Almost there'), findsOneWidget);
    expect(find.text('Try the share gate next'), findsOneWidget);
    expect(find.text('Streak 0'), findsOneWidget);
  });

  testWidgets('platform feedback effects use polished sound and haptic cues',
      (tester) async {
    final actionPlayer = RecordingFeedbackActionPlayer();
    final feedbackEffects = PlatformRunnerFeedbackEffects(
      actionPlayer: actionPlayer,
    );

    feedbackEffects.playRoundStart();
    feedbackEffects.playCorrectAnswer();
    feedbackEffects.playWrongAnswer();
    feedbackEffects.playLevelComplete();

    expect(actionPlayer.actions, [
      RunnerFeedbackAction.selectionClick,
      RunnerFeedbackAction.clickSound,
      RunnerFeedbackAction.lightImpact,
      RunnerFeedbackAction.clickSound,
      RunnerFeedbackAction.selectionClick,
      RunnerFeedbackAction.mediumImpact,
      RunnerFeedbackAction.alertSound,
      RunnerFeedbackAction.heavyImpact,
      RunnerFeedbackAction.clickSound,
      RunnerFeedbackAction.lightImpact,
    ]);
  });
}

Future<void> pumpNinjaRunner(
  WidgetTester tester, {
  MemoryLevelProgressStore? progressStore,
  RunnerFeedbackEffects? feedbackEffects,
}) async {
  await tester.pumpWidget(
    KidNationMobileGamesApp(
      progressStore: progressStore ?? MemoryLevelProgressStore(),
      feedbackEffects: feedbackEffects,
    ),
  );
  await tester.pump();
}

class RecordingRunnerFeedbackEffects implements RunnerFeedbackEffects {
  final events = <String>[];

  @override
  void playCorrectAnswer() {
    events.add('correct');
  }

  @override
  void playLevelComplete() {
    events.add('complete');
  }

  @override
  void playRoundStart() {
    events.add('start');
  }

  @override
  void playWrongAnswer() {
    events.add('wrong');
  }
}

class RecordingFeedbackActionPlayer implements RunnerFeedbackActionPlayer {
  final actions = <RunnerFeedbackAction>[];

  @override
  void play(RunnerFeedbackAction action) {
    actions.add(action);
  }
}
