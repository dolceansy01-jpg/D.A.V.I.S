import 'package:flutter_test/flutter_test.dart';
import 'package:davis_ultra_jarvis/main.dart';

void main() {
  testWidgets('D.A.V.I.S. starts correctly', (tester) async {
    await tester.pumpWidget(const DavisApp());

    expect(find.text('D.A.V.I.S.'), findsOneWidget);
    expect(find.text('ULTRA JARVIS AI'), findsOneWidget);
    expect(find.text('BONJOUR, KIM DOLCE'), findsOneWidget);
  });
}
