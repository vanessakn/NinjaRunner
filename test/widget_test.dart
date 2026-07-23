import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kidnation_mobile_games/main.dart';
import 'package:kidnation_mobile_games/ninja_runner/game/level_progress_store.dart';
import 'package:kidnation_mobile_games/ninja_runner/ui/ninja_runner_screen.dart';

void main() {
  testWidgets('shows the Ninja Runner start screen', (tester) async {
    await pumpNinjaRunner(tester);

    expect(find.text('Ninja Runner'), findsOneWidget);
    expect(find.text('Warm-Up Dash'), findsOneWidget);
    expect(find.text('Quick Choice Dash'), findsOneWidget);
    expect(find.text('Star Streak Challenge'), findsOneWidget);
    expect(find.text('Locked'), findsNWidgets(2));
    expect(find.text('Start Run'), findsOneWidget);
    expect(find.text('Jordan'), findsOneWidget);
  });

  testWidgets('locked levels cannot be selected before unlock', (tester) async {
    await pumpNinjaRunner(tester);

    await tester.tap(find.text('Quick Choice Dash'));
    await tester.pump();

    expect(find.text('Jordan'), findsOneWidget);
    expect(find.text('Nari'), findsNothing);
  });

  testWidgets('completing first level unlocks next level', (tester) async {
    await pumpNinjaRunner(tester);

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
    expect(find.text('Next Level'), findsOneWidget);

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

    expect(find.text('Locked'), findsOneWidget);

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

  testWidgets('start screen settles while idle', (tester) async {
    await pumpNinjaRunner(tester);

    await tester.pumpAndSettle(
      const Duration(milliseconds: 16),
      EnginePhase.sendSemanticsUpdate,
      const Duration(milliseconds: 200),
    );

    expect(find.text('Start Run'), findsOneWidget);
  });
}

Future<void> pumpNinjaRunner(
  WidgetTester tester, {
  MemoryLevelProgressStore? progressStore,
}) async {
  await tester.pumpWidget(
    KidNationMobileGamesApp(
      progressStore: progressStore ?? MemoryLevelProgressStore(),
    ),
  );
  await tester.pump();
}
