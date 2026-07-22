import 'package:flutter_test/flutter_test.dart';
import 'package:kidnation_mobile_games/main.dart';

void main() {
  testWidgets('shows the Gate Dash start screen', (tester) async {
    await tester.pumpWidget(const KidNationMobileGamesApp());

    expect(find.text('KidNation Gate Dash'), findsOneWidget);
    expect(find.text('Start Run'), findsOneWidget);
    expect(find.text('Jordan'), findsOneWidget);
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
