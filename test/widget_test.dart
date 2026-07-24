import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kidnation_mobile_games/bubble_blast/audio/spoken_prompt_reader.dart';
import 'package:kidnation_mobile_games/bubble_blast/ui/bubble_blast_screen.dart';
import 'package:kidnation_mobile_games/main.dart';
import 'package:kidnation_mobile_games/ninja_go/ui/ninja_go_screen.dart';

class FakeTextToSpeechEngine implements TextToSpeechEngine {
  final spokenTexts = <String>[];

  @override
  Future<void> speak(String text) async {
    spokenTexts.add(text);
  }

  @override
  Future<void> stop() async {}
}

void main() {
  testWidgets('shows the game picker', (tester) async {
    await tester.pumpWidget(const KidNationMobileGamesApp());

    expect(find.text('KidNation Games'), findsOneWidget);
    expect(find.text('Ninja Runner'), findsOneWidget);
    expect(find.text('Ninja Go'), findsOneWidget);
    expect(find.text('Bubble Blast'), findsOneWidget);
  });

  testWidgets('opens Ninja Go from the game picker', (tester) async {
    await tester.pumpWidget(const KidNationMobileGamesApp());

    await tester.tap(find.text('Ninja Go'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('KidNation Ninja Go'), findsOneWidget);
    expect(find.text('Start Run'), findsOneWidget);
  });

  testWidgets('game picker scrolls on compact heights', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 320));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const KidNationMobileGamesApp());

    expect(find.text('KidNation Games'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.drag(find.byType(Scrollable), const Offset(0, -220));
    await tester.pump();
    await tester.tap(find.text('Ninja Go'));
    await tester.binding.setSurfaceSize(null);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('KidNation Ninja Go'), findsOneWidget);
    expect(find.text('Start Run'), findsOneWidget);
  });

  testWidgets('opens Bubble Blast from the game picker', (tester) async {
    await tester.pumpWidget(const KidNationMobileGamesApp());

    await tester.tap(find.text('Bubble Blast'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('KidNation Bubble Blast'), findsOneWidget);
    expect(find.text('Start Popping'), findsOneWidget);
    expect(find.text('Nari'), findsOneWidget);
    expect(find.textContaining('Level 1'), findsOneWidget);
    expect(find.textContaining('Ages 5-8'), findsOneWidget);
    expect(find.byTooltip('Mute sounds'), findsOneWidget);
    expect(find.byTooltip('Read prompt'), findsOneWidget);
  });

  testWidgets('Bubble Blast speaker button reads the current spoken prompt',
      (tester) async {
    final engine = FakeTextToSpeechEngine();

    await tester.pumpWidget(
      MaterialApp(
        home: BubbleBlastScreen(
          spokenPromptReader: SpokenPromptReader(engine: engine),
        ),
      ),
    );

    await tester.tap(find.byTooltip('Read prompt'));
    await tester.pump();

    expect(engine.spokenTexts, ['Can you pop the kind action?']);
  });

  testWidgets('Bubble Blast mute toggle changes sound state', (tester) async {
    await tester.pumpWidget(const KidNationMobileGamesApp());

    await tester.tap(find.text('Bubble Blast'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.byTooltip('Mute sounds'));
    await tester.pump();

    expect(find.byTooltip('Unmute sounds'), findsOneWidget);
  });

  testWidgets('Bubble Blast shows level complete before the next level',
      (tester) async {
    await tester.pumpWidget(const KidNationMobileGamesApp());

    await tester.tap(find.text('Bubble Blast'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('Start Popping'));
    await tester.pump();
    for (final answer in ['share', 'joy', 'please', 'blue', 'listen']) {
      await tester.tap(find.text(answer));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 900));
    }

    expect(find.text('Level 1 complete'), findsOneWidget);
    expect(find.text('Next Level'), findsOneWidget);

    await tester.tap(find.text('Next Level'));
    await tester.pump();

    expect(find.textContaining('Level 2'), findsOneWidget);
  });

  testWidgets('Bubble Blast auto-advances after correct feedback',
      (tester) async {
    await tester.pumpWidget(const KidNationMobileGamesApp());

    await tester.tap(find.text('Bubble Blast'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('Start Popping'));
    await tester.pump();
    await tester.tap(find.text('share'));
    await tester.pump();

    expect(find.text('Next Bubble'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 900));

    expect(find.text('joy'), findsOneWidget);
  });

  testWidgets('Ninja Go ready screen settles without active ticking',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: NinjaGoScreen()));
    await tester.pumpAndSettle(
      const Duration(milliseconds: 10),
      EnginePhase.sendSemanticsUpdate,
      const Duration(milliseconds: 100),
    );

    expect(find.text('Start Run'), findsOneWidget);
  });

  testWidgets('Ninja Go screen starts and shows run controls', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: NinjaGoScreen()));

    expect(find.text('KidNation Ninja Go'), findsOneWidget);
    expect(find.text('Start Run'), findsOneWidget);

    await tester.tap(find.text('Start Run'));
    await tester.pump();

    expect(find.text('Score'), findsOneWidget);
    expect(find.byKey(const Key('ninja-go-runner-sprite')), findsOneWidget);
    expect(find.text('Jump'), findsOneWidget);
    expect(find.text('Slide'), findsOneWidget);
  });
}
