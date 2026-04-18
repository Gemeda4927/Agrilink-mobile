import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:agrilink/features/SplashScreen/splash_page.dart';

void main() {
  // Setup mocks for all tests
  setUpAll(() {
    const MethodChannel(
      'flutter.baseflow.com/geolocator',
    ).setMockMethodCallHandler((call) async => true);
    const MethodChannel(
      'flutter.baseflow.com/permissions/methods',
    ).setMockMethodCallHandler((call) async => 2);
  });

  testWidgets('1. SplashScreen renders without crashing', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: SplashScreen()));
    expect(find.byType(SplashScreen), findsOneWidget);
  });

  testWidgets('2. SplashScreen has skip button', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: SplashScreen()));
    expect(find.text('Skip'), findsOneWidget);
  });

  testWidgets('3. SplashScreen has page view for onboarding', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: SplashScreen()));
    expect(find.byType(PageView), findsOneWidget);
  });

  testWidgets('4. SplashScreen shows welcome title', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: SplashScreen()));
    expect(find.text('Welcome to AgriLink'), findsOneWidget);
  });

  testWidgets('5. SplashScreen has location required section', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: SplashScreen()));
    expect(find.text('Location Required'), findsOneWidget);
  });

  testWidgets('6. SplashScreen has location icon', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: SplashScreen()));
    expect(find.byIcon(Icons.location_on), findsOneWidget);
  });

  testWidgets('7. SplashScreen has benefit items', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: SplashScreen()));
    expect(find.text('Local weather forecasts'), findsOneWidget);
    expect(find.text('Market prices near you'), findsOneWidget);
    expect(find.text('Farming tips for your region'), findsOneWidget);
    expect(find.text('Connect with local farmers'), findsOneWidget);
  });

  testWidgets('8. SplashScreen has continue button', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: SplashScreen()));
    expect(find.byType(ElevatedButton), findsWidgets);
  });

  testWidgets('9. SplashScreen has skip for now button', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: SplashScreen()));
    expect(find.text('Skip for Now'), findsOneWidget);
  });

  testWidgets('10. SplashScreen page indicator dots exist', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: SplashScreen()));

    final pageIndicators = find.descendant(
      of: find.byType(Row),
      matching: find.byType(Container),
    );

    expect(pageIndicators, findsWidgets);
  });
}
