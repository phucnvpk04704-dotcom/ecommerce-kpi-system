import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ecommerce_kpi_mobile/main.dart';

void main() {
  testWidgets('App starts and redirects to Login Screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: MyApp(),
      ),
    );

    // Let the GoRouter navigation settle
    await tester.pumpAndSettle();

    // Verify that the login screen is displayed by searching for its text
    expect(find.text('Burgundy KPI Portal'), findsOneWidget);
  });
}
