import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gostore_partner/main.dart';

void main() {
  testWidgets('renders splash screen and eventually login', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // Splash screen should show logo or loading indicator
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Wait for navigation (simulate 3 seconds delay in SplashScreen)
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    // After splash, we should land on login screen
    expect(find.text('Login'), findsWidgets);
  });
}
