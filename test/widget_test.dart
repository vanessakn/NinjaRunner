import 'package:flutter_test/flutter_test.dart';
import 'package:kidnation_mobile_games/main.dart';

void main() {
  testWidgets('shows the Ninja Runner start screen', (tester) async {
    await tester.pumpWidget(const KidNationMobileGamesApp());

    expect(find.text('KidNation Ninja Runner'), findsOneWidget);
    expect(find.text('Start Run'), findsOneWidget);
    expect(find.text('Jordan'), findsOneWidget);
  });
}
