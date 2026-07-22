import 'package:flutter_test/flutter_test.dart';
import 'package:kidnation_mobile_games/main.dart';

void main() {
  testWidgets('shows the Gate Dash start screen', (tester) async {
    await tester.pumpWidget(const KidNationMobileGamesApp());

    expect(find.text('KidNation Gate Dash'), findsOneWidget);
    expect(find.text('Warm-Up Dash'), findsOneWidget);
    expect(find.text('Quick Choice Dash'), findsOneWidget);
    expect(find.text('Star Streak Challenge'), findsOneWidget);
    expect(find.text('Locked'), findsNWidgets(2));
    expect(find.text('Start Run'), findsOneWidget);
    expect(find.text('Jordan'), findsOneWidget);
  });

  testWidgets('locked levels cannot be selected before unlock', (tester) async {
    await tester.pumpWidget(const KidNationMobileGamesApp());

    await tester.tap(find.text('Quick Choice Dash'));
    await tester.pump();

    expect(find.text('Jordan'), findsOneWidget);
    expect(find.text('Nari'), findsNothing);
  });

  testWidgets('completing first level unlocks next level', (tester) async {
    await tester.pumpWidget(const KidNationMobileGamesApp());

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

  testWidgets('start screen settles while idle', (tester) async {
    await tester.pumpWidget(const KidNationMobileGamesApp());

    await tester.pumpAndSettle(
      const Duration(milliseconds: 16),
      EnginePhase.sendSemanticsUpdate,
      const Duration(milliseconds: 200),
    );

    expect(find.text('Start Run'), findsOneWidget);
  });
}
