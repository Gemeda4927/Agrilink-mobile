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
      expect(find.byWidgetPredicate(
        (widget) => widget is TextField && widget.decoration?.labelText == 'Email',
      ), findsOneWidget);
    });

    testWidgets('10. CreateFarmerScreen has phone input field', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createCreateFarmerScreen());
      await tester.pump();
      expect(find.byWidgetPredicate(
        (widget) => widget is TextField && widget.decoration?.labelText == 'Phone',
      ), findsOneWidget);
    });

    testWidgets('11. CreateFarmerScreen has password fields', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createCreateFarmerScreen());
      await tester.pump();
      expect(find.byWidgetPredicate(
        (widget) => widget is TextField && widget.decoration?.labelText == 'Password',
      ), findsOneWidget);
      expect(find.byWidgetPredicate(
        (widget) => widget is TextField && widget.decoration?.labelText == 'Confirm Password',
      ), findsOneWidget);
    });

    testWidgets('12. CreateFarmerScreen has 4 TextFields', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createCreateFarmerScreen());
      await tester.pump();
      expect(find.byType(TextField), findsWidgets);
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
      expect(find.text('Review & Create'), findsOneWidget);
    });

    testWidgets('15. CreateFarmerScreen has BlocBuilder', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createCreateFarmerScreen());
      await tester.pump();
      expect(find.byWidgetPredicate(
        (widget) => widget is BlocBuilder<RegistrationBloc, RegistrationState>,
      ), findsOneWidget);
    });

    testWidgets('16. CreateFarmerScreen has SingleChildScrollView', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createCreateFarmerScreen());
      await tester.pump();
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('17. CreateFarmerScreen has password visibility toggle', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createCreateFarmerScreen());
      await tester.pump();
      expect(find.byIcon(Icons.visibility_off_outlined), findsWidgets);
    });

    testWidgets('18. Email field accepts text input', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createCreateFarmerScreen());
      await tester.pump();

      final emailField = find.byWidgetPredicate(
        (widget) => widget is TextField && widget.decoration?.labelText == 'Email',
      );
      
      await tester.enterText(emailField, 'test@example.com');
      await tester.pump();

      expect(find.text('test@example.com'), findsOneWidget);
    });

    testWidgets('19. Phone field accepts text input', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createCreateFarmerScreen());
      await tester.pump();

      final phoneField = find.byWidgetPredicate(
        (widget) => widget is TextField && widget.decoration?.labelText == 'Phone',
      );
      
      await tester.enterText(phoneField, '+251911223344');
      await tester.pump();

      expect(find.text('+251911223344'), findsOneWidget);
    });

    testWidgets('20. Password field accepts text input', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createCreateFarmerScreen());
      await tester.pump();

      final passwordField = find.byWidgetPredicate(
        (widget) => widget is TextField && widget.decoration?.labelText == 'Password',
      );
      
      await tester.enterText(passwordField, '12345678');
      await tester.pump();

      expect(find.text('12345678'), findsOneWidget);
    });

    testWidgets('21. Confirm password field accepts text input', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createCreateFarmerScreen());
      await tester.pump();

      final confirmPasswordField = find.byWidgetPredicate(
        (widget) => widget is TextField && widget.decoration?.labelText == 'Confirm Password',
      );
      
      await tester.enterText(confirmPasswordField, '12345678');
      await tester.pump();

      expect(find.text('12345678'), findsOneWidget);
    });

    testWidgets('22. Shows loading indicator when state is RegistrationLoading', (
      WidgetTester tester,
    ) async {
      registrationBloc.emit(RegistrationLoading());
      
      await tester.pumpWidget(createCreateFarmerScreen());
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}