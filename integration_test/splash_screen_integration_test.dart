import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:integration_test/integration_test.dart';
import 'package:agrilink/features/SplashScreen/splash_page.dart';
import 'package:agrilink/core/config/routes/route_name.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    print('═══════════════════════════════════════════════════');
    print('🚀 SETTING UP INTEGRATION TESTS');
    print('═══════════════════════════════════════════════════');
    
    const MethodChannel('flutter.baseflow.com/geolocator')
        .setMockMethodCallHandler((call) async {
      print('📍 Geolocator called: ${call.method}');
      return true;
    });
    
    const MethodChannel('flutter.baseflow.com/permissions/methods')
        .setMockMethodCallHandler((call) async {
      print('🔐 Permission handler called: ${call.method}');
      return 2; // PermissionStatus.granted
    });
    
    print('✅ Mocks configured successfully');
    print('');
  });

  GoRouter createTestRouter() {
    return GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          name: 'splash',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: '/login',
          name: RouteName.login,
          builder: (context, state) => const Scaffold(
            body: Center(child: Text('Login Screen')),
          ),
        ),
      ],
    );
  }

  testWidgets('TEST 1: SplashScreen UI Verification', (WidgetTester tester) async {
    print('═══════════════════════════════════════════════════');
    print('📱 TEST 1: SplashScreen UI Verification');
    print('═══════════════════════════════════════════════════');
    
    await tester.pumpWidget(MaterialApp.router(
      routerConfig: createTestRouter(),
    ));
    
    // Wait longer for loading to complete
    await tester.pump(const Duration(seconds: 3));
    await tester.pump(const Duration(seconds: 1));
    
    print('\n🔍 Checking UI elements:');
    
    expect(find.byType(SplashScreen), findsOneWidget);
    print('  ✅ SplashScreen found');
    
    expect(find.text('Skip'), findsOneWidget);
    print('  ✅ Skip button found');
    
    expect(find.text('Welcome to AgriLink'), findsOneWidget);
    print('  ✅ Welcome text found');
    
    expect(find.text('Location Required'), findsOneWidget);
    print('  ✅ Location Required found');
    
    expect(find.text('Skip for Now'), findsOneWidget);
    print('  ✅ Skip for Now button found');
    
    // Check for Continue OR loading spinner
    if (find.text('Continue').evaluate().isNotEmpty) {
      print('  ✅ Continue button found');
    } else if (find.byType(CircularProgressIndicator).evaluate().isNotEmpty) {
      print('  ⏳ Still loading, waiting more...');
      await tester.pump(const Duration(seconds: 2));
      
      if (find.text('Continue').evaluate().isNotEmpty) {
        print('  ✅ Continue button found after waiting');
      }
    }
    
    // Test PageView exists
    final pageView = find.byType(PageView);
    expect(pageView, findsOneWidget);
    print('  ✅ PageView found');
    
    // Swipe to page 2
    await tester.drag(pageView, const Offset(-300, 0));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Fresh Produce Direct'), findsOneWidget);
    print('  ✅ Swiped to page 2');
    
    // Swipe to page 3
    await tester.drag(pageView, const Offset(-300, 0));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Smart Farming'), findsOneWidget);
    print('  ✅ Swiped to page 3');
    
    // Swipe to page 4
    await tester.drag(pageView, const Offset(-300, 0));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Real-time Market'), findsOneWidget);
    print('  ✅ Swiped to page 4');
    
    print('\n═══════════════════════════════════════════════════');
    print('✅ TEST 1 COMPLETED SUCCESSFULLY');
    print('═══════════════════════════════════════════════════');
  });

  testWidgets('TEST 2: Skip button navigates to login', (WidgetTester tester) async {
    print('═══════════════════════════════════════════════════');
    print('🧭 TEST 2: Skip Button Navigation');
    print('═══════════════════════════════════════════════════');
    
    await tester.pumpWidget(MaterialApp.router(
      routerConfig: createTestRouter(),
    ));
    await tester.pump(const Duration(seconds: 3));
    
    print('  ✅ SplashScreen loaded');
    
    print('  👆 Tapping Skip button...');
    await tester.tap(find.text('Skip'));
    await tester.pump(const Duration(seconds: 1));
    
    expect(find.byType(SplashScreen), findsNothing);
    expect(find.text('Login Screen'), findsOneWidget);
    print('  ✅ Navigated to Login Screen');
    
    print('\n═══════════════════════════════════════════════════');
    print('✅ TEST 2 COMPLETED SUCCESSFULLY');
    print('═══════════════════════════════════════════════════');
  });
}