import 'package:agrilink/core/localization/generated/app_localizations.dart';
import 'package:agrilink/features/auth/domain/usecase/auth_usecases.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:agrilink/features/auth/presentation/login_page.dart';
import 'package:agrilink/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:agrilink/core/localization/language_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';

// Mock all required use cases
class MockSignInUseCase extends Mock implements SignInUseCase {}

class MockSignUpUseCase extends Mock implements SignUpUseCase {}

class MockVerifyOtpUseCase extends Mock implements VerifyOtpUseCase {}

class MockGoogleSignInUseCase extends Mock implements GoogleSignInUseCase {}

class MockForgotPasswordUseCase extends Mock implements ForgotPasswordUseCase {}

class MockResetPasswordUseCase extends Mock implements ResetPasswordUseCase {}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Mock platform channels to prevent hanging
  const MethodChannel(
    'flutter.baseflow.com/geolocator',
  ).setMockMethodCallHandler((call) async => true);

  const MethodChannel(
    'flutter.baseflow.com/permissions/methods',
  ).setMockMethodCallHandler((call) async => 2);

  testWidgets('TEST 1: LoginPage UI Verification', (WidgetTester tester) async {
    print('Starting test...');

    // Create mocks
    final mockSignInUseCase = MockSignInUseCase();
    final mockSignUpUseCase = MockSignUpUseCase();
    final mockVerifyOtpUseCase = MockVerifyOtpUseCase();
    final mockGoogleSignInUseCase = MockGoogleSignInUseCase();
    final mockForgotPasswordUseCase = MockForgotPasswordUseCase();
    final mockResetPasswordUseCase = MockResetPasswordUseCase();

    // Create AuthBloc with all required use cases
    final authBloc = AuthBloc(
      signInUseCase: mockSignInUseCase,
      signUpUseCase: mockSignUpUseCase,
      verifyOtpUseCase: mockVerifyOtpUseCase,
      googleSignInUseCase: mockGoogleSignInUseCase,
      forgotPasswordUseCase: mockForgotPasswordUseCase,
      resetPasswordUseCase: mockResetPasswordUseCase,
    );

    // Create LanguageBloc
    final languageBloc = LanguageBloc();

    // Wrap LoginPage with required providers
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>.value(value: authBloc),
          BlocProvider<LanguageBloc>.value(value: languageBloc),
        ],
        child: MaterialApp(
          home: LoginPage(),
          debugShowCheckedModeBanner: false,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );

    // Wait for animations
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    print('\n🔍 Checking UI elements:');

    // Check if LoginPage is rendered
    expect(find.byType(LoginPage), findsOneWidget);
    print('  ✅ LoginPage found');

    // Check header elements
    final welcomeText = find.text('Welcome Back!');
    expect(welcomeText, findsOneWidget);
    print('  ✅ Welcome Back text found');

    final subtitleText = find.text('Sign in to continue to your account');
    expect(subtitleText, findsOneWidget);
    print('  ✅ Sign in subtitle found');

    // Check navigation buttons
    expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    print('  ✅ Back button found');

    expect(find.byIcon(Icons.language), findsOneWidget);
    print('  ✅ Language button found');

    // Check form fields
    final emailField = find.widgetWithText(TextField, 'Email or Phone');
    expect(emailField, findsOneWidget);
    print('  ✅ Email/Phone field found');

    final passwordField = find.widgetWithText(TextField, 'Password');
    expect(passwordField, findsOneWidget);
    print('  ✅ Password field found');

    // Check debug dropdown
    expect(find.text('Quick Debug Login'), findsOneWidget);
    print('  ✅ Debug dropdown found');

    // Check buttons and links
    expect(find.text('Remember Me'), findsOneWidget);
    print('  ✅ Remember Me checkbox found');

    expect(find.text('Forgot Password?'), findsOneWidget);
    print('  ✅ Forgot Password link found');

    expect(find.text('Login'), findsOneWidget);
    print('  ✅ Login button found');

    expect(find.text('OR'), findsOneWidget);
    print('  ✅ OR divider found');

    expect(find.text('Sign in with Google'), findsOneWidget);
    print('  ✅ Google Sign In button found');

    expect(find.text("Don't have an account?"), findsOneWidget);
    print('  ✅ No account text found');

    expect(find.text('Create Account'), findsOneWidget);
    print('  ✅ Create Account link found');

    // Test input fields
    print('\n📝 Testing input fields:');
    await tester.enterText(emailField, 'test@example.com');
    await tester.pump();
    expect(find.text('test@example.com'), findsOneWidget);
    print('  ✅ Email input works');

    await tester.enterText(passwordField, 'password123');
    await tester.pump();
    expect(find.text('password123'), findsOneWidget);
    print('  ✅ Password input works');

    // Test password visibility toggle
    final visibilityIcon = find.byIcon(Icons.visibility);
    expect(visibilityIcon, findsOneWidget);
    print('  ✅ Password visibility toggle found');

    // Test debug dropdown
    print('\n🔧 Testing debug dropdown:');
    final debugDropdown = find.byType(DropdownButtonFormField<DebugUser>);
    expect(debugDropdown, findsOneWidget);

    await tester.tap(debugDropdown);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Check if dropdown items appear
    expect(find.text('Agent - meronmulu2121@gmail.com'), findsOneWidget);
    print('  ✅ Debug dropdown items found');

    // Select a debug user
    await tester.tap(find.text('Agent - meronmulu2121@gmail.com'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Verify fields are populated
    expect(find.text('meronmulu2121@gmail.com'), findsOneWidget);
    print('  ✅ Debug user selection populates fields');

    print('\n═══════════════════════════════════════════════════');
    print('✅ TEST 1 COMPLETED SUCCESSFULLY');
    print('═══════════════════════════════════════════════════');
  });
}
