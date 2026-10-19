import 'package:flutter_test/flutter_test.dart';
import 'package:frontendmovil/main.dart';

void main() {
  testWidgets('login screen is the unauthenticated entry point', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const UlimaReciclaApp());

    expect(find.text('Tu campus. Tu impacto.'), findsOneWidget);
    expect(find.text('Iniciar sesión'), findsOneWidget);
  });
}
