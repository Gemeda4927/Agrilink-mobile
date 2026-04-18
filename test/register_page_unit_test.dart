import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:agrilink/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:agrilink/features/auth/presentation/bloc/auth_state.dart';
import 'package:agrilink/features/auth/domain/usecase/auth_usecases.dart';
import 'package:agrilink/features/registration/presentation/screen/register_page.dart';

// Mock UseCases
class MockSignInUseCase extends Mock implements SignInUseCase {}

class MockSignUpUseCase extends Mock implements SignUpUseCase {}

class MockVerifyOtpUseCase extends Mock implements VerifyOtpUseCase {}

class MockGoogleSignInUseCase extends Mock implements GoogleSignInUseCase {}

class MockForgotPasswordUseCase extends Mock implements ForgotPasswordUseCase {}

class MockResetPasswordUseCase extends Mock implements ResetPasswordUseCase {}

void main() {
  late AuthBloc authBloc;
  late MockSignInUseCase mockSignInUseCase;
  late MockSignUpUseCase mockSignUpUseCase;
  late MockVerifyOtpUseCase mockVerifyOtpUseCase;
  late MockGoogleSignInUseCase mockGoogleSignInUseCase;
  late MockForgotPasswordUseCase mockForgotPasswordUseCase;
  late MockResetPasswordUseCase mockResetPasswordUseCase;

  setUp(() {
    mockSignInUseCase = MockSignInUseCase();
    mockSignUpUseCase = MockSignUpUseCase();
    mockVerifyOtpUseCase = MockVerifyOtpUseCase();
    mockGoogleSignInUseCase = MockGoogleSignInUseCase();
    mockForgotPasswordUseCase = MockForgotPasswordUseCase();
    mockResetPasswordUseCase = MockResetPasswordUseCase();

    authBloc = AuthBloc(
      signInUseCase: mockSignInUseCase,
      signUpUseCase: mockSignUpUseCase,
      verifyOtpUseCase: mockVerifyOtpUseCase,
      googleSignInUseCase: mockGoogleSignInUseCase,
      forgotPasswordUseCase: mockForgotPasswordUseCase,
      resetPasswordUseCase: mockResetPasswordUseCase,
    );
  });

  Widget createRegisterPage() {
    return MaterialApp(
      home: BlocProvider<AuthBloc>.value(
        value: authBloc,
        child: const RegisterPage(),
      ),
    );
  }

  group('RegisterPage Unit Tests', () {
    testWidgets('1. RegisterPage renders without crashing', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createRegisterPage());
      await tester.pump();
      expect(find.byType(RegisterPage), findsOneWidget);
    });

    testWidgets('2. RegisterPage has Scaffold', (WidgetTester tester) async {
      await tester.pumpWidget(createRegisterPage());
      await tester.pump();
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('3. RegisterPage has SafeArea', (WidgetTester tester) async {
      await tester.pumpWidget(createRegisterPage());
      await tester.pump();
      expect(find.byType(SafeArea), findsOneWidget);
    });

    testWidgets('4. RegisterPage has SingleChildScrollView', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createRegisterPage());
      await tester.pump();
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('5. RegisterPage shows header title', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createRegisterPage());
      await tester.pump();
      expect(find.text('Add New Farmer'), findsOneWidget);
    });

    testWidgets('6. RegisterPage shows subtitle', (WidgetTester tester) async {
      await tester.pumpWidget(createRegisterPage());
      await tester.pump();
      expect(find.text('Register farmer to the system'), findsOneWidget);
    });

    testWidgets('7. RegisterPage has agriculture logo icon', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createRegisterPage());
      await tester.pump();
      expect(find.byIcon(Icons.agriculture_rounded), findsOneWidget);
    });

    testWidgets('8. RegisterPage has name input field', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createRegisterPage());
      await tester.pump();
      expect(find.byIcon(Icons.person_outline), findsOneWidget);
    });

    testWidgets('9. RegisterPage has email input field', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createRegisterPage());
      await tester.pump();
      expect(find.byIcon(Icons.email_outlined), findsOneWidget);
    });

    testWidgets('10. RegisterPage has phone input field', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createRegisterPage());
      await tester.pump();
      expect(find.byIcon(Icons.phone_outlined), findsOneWidget);
    });

    testWidgets('11. RegisterPage has password fields', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createRegisterPage());
      await tester.pump();
      expect(find.byIcon(Icons.lock_outline), findsNWidgets(2));
    });

    testWidgets('12. RegisterPage has terms checkbox', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createRegisterPage());
      await tester.pump();
      expect(find.byType(Checkbox), findsOneWidget);
    });

    testWidgets('13. RegisterPage has register button', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createRegisterPage());
      await tester.pump();
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('14. RegisterPage button has correct text', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createRegisterPage());
      await tester.pump();
      expect(find.text('Register Farmer'), findsOneWidget);
    });

    testWidgets('15. RegisterPage has reset form button', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createRegisterPage());
      await tester.pump();
      expect(find.text('Reset Form'), findsOneWidget);
    });

    testWidgets('16. RegisterPage has Form widget', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createRegisterPage());
      await tester.pump();
      expect(find.byType(Form), findsOneWidget);
    });

    testWidgets('17. RegisterPage has 5 TextFormFields', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createRegisterPage());
      await tester.pump();
      expect(find.byType(TextFormField), findsNWidgets(5));
    });

    testWidgets('18. Register button is disabled when terms not checked', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createRegisterPage());
      await tester.pump();

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('19. RegisterPage has terms text', (WidgetTester tester) async {
      await tester.pumpWidget(createRegisterPage());
      await tester.pump();

      expect(find.byType(RichText), findsWidgets);

      final richTextFinder = find.byWidgetPredicate(
        (widget) =>
            widget is RichText &&
            widget.text.toPlainText().contains(
              'I confirm that the information is accurate',
            ),
      );

      expect(richTextFinder, findsOneWidget);
    });

    testWidgets('20. RegisterPage has BlocBuilder', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createRegisterPage());
      await tester.pump();
      expect(find.byType(BlocBuilder<AuthBloc, AuthState>), findsOneWidget);
    });
  });
}
