import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gostore_partner/main.dart';

void main() {
  testWidgets('renders splash screen and eventually login', (WidgetTester tester) async {
    // Provide a fallback theme for testing
    final dummyTheme = ThemeData(
      brightness: Brightness.light,
      useMaterial3: true,
    );

    await tester.pumpWidget(
      MyApp(themeData: dummyTheme), // ⬅️ Removed const here
    );

    // Splash screen check
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Simulate splash delay
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    // Confirm login is present
    expect(find.text('Login'), findsWidgets);
  });
}
