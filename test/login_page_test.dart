import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:agrilink/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:agrilink/features/auth/presentation/login_page.dart';
import 'package:agrilink/features/auth/domain/usecase/auth_usecases.dart';
import 'package:agrilink/features/auth/domain/repository/auth_repository.dart';
import 'package:agrilink/features/auth/domain/entities/auth_response_entity.dart';
import 'package:agrilink/core/localization/language_bloc.dart';
import 'package:agrilink/core/localization/generated/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// Mock AuthRepository
class MockAuthRepository extends Mock implements AuthRepository {}

class MockAuthResponseEntity extends Mock implements AuthResponseEntity {}

void main() {
  late MockAuthRepository mockRepository;
  late SignInUseCase signInUseCase;
  late SignUpUseCase signUpUseCase;
  late VerifyOtpUseCase verifyOtpUseCase;
  late GoogleSignInUseCase googleSignInUseCase;
  late ForgotPasswordUseCase forgotPasswordUseCase;
  late ResetPasswordUseCase resetPasswordUseCase;

  setUp(() {
    mockRepository = MockAuthRepository();
    signInUseCase = SignInUseCase(mockRepository);
    signUpUseCase = SignUpUseCase(mockRepository);
    verifyOtpUseCase = VerifyOtpUseCase(mockRepository);
    googleSignInUseCase = GoogleSignInUseCase(mockRepository);
    forgotPasswordUseCase = ForgotPasswordUseCase(mockRepository);
    resetPasswordUseCase = ResetPasswordUseCase(mockRepository);
  });

  Widget createLoginPage() {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => AuthBloc(
            signInUseCase: signInUseCase,
            signUpUseCase: signUpUseCase,
            verifyOtpUseCase: verifyOtpUseCase,
            googleSignInUseCase: googleSignInUseCase,
            forgotPasswordUseCase: forgotPasswordUseCase,
            resetPasswordUseCase: resetPasswordUseCase,
          ),
        ),
        BlocProvider<LanguageBloc>(
          create: (_) => LanguageBloc(),
        ),
      ],
      child: const MaterialApp(
        home: LoginPage(),
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [
          Locale('en'),
          Locale('am'),
          Locale('om'),
        ],
      ),
    );
  }

  group('LoginPage Unit Tests', () {
    testWidgets('1. LoginPage renders without crashing', (WidgetTester tester) async {
      await tester.pumpWidget(createLoginPage());
      await tester.pump(const Duration(seconds: 1));
      expect(find.byType(LoginPage), findsOneWidget);
    });

    testWidgets('2. LoginPage has Scaffold', (WidgetTester tester) async {
      await tester.pumpWidget(createLoginPage());
      await tester.pump(const Duration(seconds: 1));
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('3. LoginPage has back button', (WidgetTester tester) async {
      await tester.pumpWidget(createLoginPage());
      await tester.pump(const Duration(seconds: 1));
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('4. LoginPage has language switcher', (WidgetTester tester) async {
      await tester.pumpWidget(createLoginPage());
      await tester.pump(const Duration(seconds: 1));
      expect(find.byIcon(Icons.language), findsOneWidget);
    });

    testWidgets('5. LoginPage has agriculture logo', (WidgetTester tester) async {
      await tester.pumpWidget(createLoginPage());
      await tester.pump(const Duration(seconds: 1));
      expect(find.byIcon(Icons.agriculture_rounded), findsOneWidget);
    });

    testWidgets('6. LoginPage has email field icon', (WidgetTester tester) async {
      await tester.pumpWidget(createLoginPage());
      await tester.pump(const Duration(seconds: 1));
      expect(find.byIcon(Icons.person_outline), findsOneWidget);
    });

    testWidgets('7. LoginPage has password field icon', (WidgetTester tester) async {
      await tester.pumpWidget(createLoginPage());
      await tester.pump(const Duration(seconds: 1));
      expect(find.byIcon(Icons.lock_outline), findsOneWidget);
    });

    testWidgets('8. LoginPage has debug dropdown icon', (WidgetTester tester) async {
      await tester.pumpWidget(createLoginPage());
      await tester.pump(const Duration(seconds: 1));
      expect(find.byIcon(Icons.bug_report_outlined), findsOneWidget);
    });

    testWidgets('9. LoginPage has checkbox', (WidgetTester tester) async {
      await tester.pumpWidget(createLoginPage());
      await tester.pump(const Duration(seconds: 1));
      expect(find.byType(Checkbox), findsOneWidget);
    });

    testWidgets('10. LoginPage has ElevatedButton', (WidgetTester tester) async {
      await tester.pumpWidget(createLoginPage());
      await tester.pump(const Duration(seconds: 1));
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('11. LoginPage has TextFormFields', (WidgetTester tester) async {
      await tester.pumpWidget(createLoginPage());
      await tester.pump(const Duration(seconds: 1));
      expect(find.byType(TextFormField), findsNWidgets(2));
    });

    testWidgets('12. LoginPage has SingleChildScrollView', (WidgetTester tester) async {
      await tester.pumpWidget(createLoginPage());
      await tester.pump(const Duration(seconds: 1));
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('13. LoginPage has SafeArea', (WidgetTester tester) async {
      await tester.pumpWidget(createLoginPage());
      await tester.pump(const Duration(seconds: 1));
      expect(find.byType(SafeArea), findsOneWidget);
    });

    testWidgets('14. LoginPage has Container widgets', (WidgetTester tester) async {
      await tester.pumpWidget(createLoginPage());
      await tester.pump(const Duration(seconds: 1));
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('15. LoginPage has Column widget', (WidgetTester tester) async {
      await tester.pumpWidget(createLoginPage());
      await tester.pump(const Duration(seconds: 1));
      expect(find.byType(Column), findsWidgets);
    });
  });
}