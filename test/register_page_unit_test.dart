import 'package:agrilink/features/registration/data/models/user_model.dart';
import 'package:agrilink/features/registration/presentation/screen/register_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:agrilink/features/registration/presentation/bloc/registration_bloc.dart';
import 'package:agrilink/features/registration/presentation/bloc/registration_state.dart';
import 'package:agrilink/features/registration/presentation/bloc/registration_event.dart';
import 'package:agrilink/features/registration/domain/usecases/registration_usecases.dart';

// Mock RegistrationUseCases
class MockRegistrationUseCases extends Mock implements RegistrationUseCases {}

void main() {
  late RegistrationBloc registrationBloc;
  late MockRegistrationUseCases mockRegistrationUseCases;

  setUp(() {
    mockRegistrationUseCases = MockRegistrationUseCases();
    registrationBloc = RegistrationBloc(mockRegistrationUseCases);
  });

  Widget createCreateFarmerScreen() {
    return MaterialApp(
      home: BlocProvider<RegistrationBloc>.value(
        value: registrationBloc,
        child: const CreateFarmerScreen(),
      ),
    );
  }

  group('CreateFarmerScreen Widget Tests', () {
    testWidgets('1. CreateFarmerScreen renders without crashing', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createCreateFarmerScreen());
      await tester.pump();
      expect(find.byType(CreateFarmerScreen), findsOneWidget);
    });

    testWidgets('2. CreateFarmerScreen has Scaffold', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createCreateFarmerScreen());
      await tester.pump();
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('3. CreateFarmerScreen has AppBar', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createCreateFarmerScreen());
      await tester.pump();
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('4. CreateFarmerScreen AppBar has correct title', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createCreateFarmerScreen());
      await tester.pump();
      expect(find.text('Create Farmer Account'), findsOneWidget);
    });

    testWidgets('5. CreateFarmerScreen has back button', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createCreateFarmerScreen());
      await tester.pump();
      expect(find.byIcon(Icons.arrow_back_ios), findsOneWidget);
    });

    testWidgets('6. CreateFarmerScreen has person add icon', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createCreateFarmerScreen());
      await tester.pump();
      expect(find.byIcon(Icons.person_add_alt_1), findsOneWidget);
    });

    testWidgets('7. CreateFarmerScreen shows title text', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createCreateFarmerScreen());
      await tester.pump();
      expect(find.text('Create New Farmer'), findsOneWidget);
    });

    testWidgets('8. CreateFarmerScreen shows subtitle', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createCreateFarmerScreen());
      await tester.pump();
      expect(
        find.text('Fill in the details to create a farmer account'),
        findsOneWidget,
      );
    });

    testWidgets('9. CreateFarmerScreen has email input field', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createCreateFarmerScreen());
      await tester.pump();
      expect(find.byIcon(Icons.email_outlined), findsOneWidget);
    });

    testWidgets('10. CreateFarmerScreen has phone input field', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createCreateFarmerScreen());
      await tester.pump();
      expect(find.byIcon(Icons.phone_outlined), findsOneWidget);
    });

    testWidgets('11. CreateFarmerScreen has password fields', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createCreateFarmerScreen());
      await tester.pump();
      expect(find.byIcon(Icons.lock_outline), findsNWidgets(2));
    });

    testWidgets('12. CreateFarmerScreen has 4 TextFormFields', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createCreateFarmerScreen());
      await tester.pump();
      expect(find.byType(TextField), findsNWidgets(4));
    });

    testWidgets('13. CreateFarmerScreen has create button', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createCreateFarmerScreen());
      await tester.pump();
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('14. CreateFarmerScreen button has correct text', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createCreateFarmerScreen());
      await tester.pump();
      expect(find.text('Create Farmer Account'), findsOneWidget);
    });

    testWidgets('15. CreateFarmerScreen has BlocListener', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createCreateFarmerScreen());
      await tester.pump();
      expect(
        find.byType(BlocListener<RegistrationBloc, RegistrationState>),
        findsOneWidget,
      );
    });

    testWidgets('16. CreateFarmerScreen has BlocBuilder', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createCreateFarmerScreen());
      await tester.pump();
      expect(
        find.byType(BlocBuilder<RegistrationBloc, RegistrationState>),
        findsOneWidget,
      );
    });

    testWidgets('17. CreateFarmerScreen has SingleChildScrollView', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createCreateFarmerScreen());
      await tester.pump();
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('18. CreateFarmerScreen has password visibility toggle', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createCreateFarmerScreen());
      await tester.pump();
      expect(find.byIcon(Icons.visibility_off_outlined), findsNWidgets(2));
    });

    testWidgets('19. Email field accepts text input', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createCreateFarmerScreen());
      await tester.pump();

      await tester.enterText(
        find.widgetWithText(TextField, 'Email'),
        'test@example.com',
      );
      await tester.pump();

      expect(find.text('test@example.com'), findsOneWidget);
    });

    testWidgets('20. Phone field accepts text input', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createCreateFarmerScreen());
      await tester.pump();

      await tester.enterText(
        find.widgetWithText(TextField, 'Phone'),
        '+251911223344',
      );
      await tester.pump();

      expect(find.text('+251911223344'), findsOneWidget);
    });

    testWidgets('21. Password field accepts text input', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createCreateFarmerScreen());
      await tester.pump();

      await tester.enterText(
        find.widgetWithText(TextField, 'Password'),
        '12345678',
      );
      await tester.pump();

      expect(find.text('12345678'), findsOneWidget);
    });

    testWidgets('22. Confirm password field accepts text input', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createCreateFarmerScreen());
      await tester.pump();

      await tester.enterText(
        find.widgetWithText(TextField, 'Confirm Password'),
        '12345678',
      );
      await tester.pump();

      expect(find.text('12345678'), findsOneWidget);
    });

    testWidgets('23. Create button is enabled when all fields filled', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createCreateFarmerScreen());
      await tester.pump();

      // Fill all fields
      await tester.enterText(
        find.widgetWithText(TextField, 'Email'),
        'test@example.com',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Phone'),
        '+251911223344',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Password'),
        '12345678',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Confirm Password'),
        '12345678',
      );
      await tester.pump();

      final button = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Create Farmer Account'),
      );
      expect(button.onPressed, isNotNull);
    });

    testWidgets(
      '24. Shows loading indicator when state is RegistrationLoading',
      (WidgetTester tester) async {
        // Set loading state
        when(
          () => mockRegistrationUseCases.createFarmer(
            email: any(named: 'email'),
            password: any(named: 'password'),
            confirmPassword: any(named: 'confirmPassword'),
            phone: any(named: 'phone'),
            role: any(named: 'role'),
          ),
        ).thenAnswer(
          (_) async => Future.delayed(
            const Duration(seconds: 1),
            () => CreateFarmerResponse(message: 'Success'),
          ),
        );

        await tester.pumpWidget(createCreateFarmerScreen());
        await tester.pump();

        // Fill fields
        await tester.enterText(
          find.widgetWithText(TextField, 'Email'),
          'test@example.com',
        );
        await tester.enterText(
          find.widgetWithText(TextField, 'Phone'),
          '+251911223344',
        );
        await tester.enterText(
          find.widgetWithText(TextField, 'Password'),
          '12345678',
        );
        await tester.enterText(
          find.widgetWithText(TextField, 'Confirm Password'),
          '12345678',
        );
        await tester.pump();

        // Tap create button
        await tester.tap(
          find.widgetWithText(ElevatedButton, 'Create Farmer Account'),
        );
        await tester.pump();

        // Should show loading indicator
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      },
    );
  });
}
