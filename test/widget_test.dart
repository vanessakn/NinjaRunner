import 'package:flutter_test/flutter_test.dart';
import 'package:kidnation_mobile_games/main.dart';

void main() {
  testWidgets('shows the app title', (tester) async {
    await tester.pumpWidget(const KidNationMobileGamesApp());

    expect(find.text('KidNation Ninja Runner'), findsOneWidget);
  });
}
