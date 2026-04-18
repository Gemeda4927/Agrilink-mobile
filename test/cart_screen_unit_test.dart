import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:agrilink/features/cart/presentation/cart.dart';
import 'package:agrilink/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:agrilink/features/cart/presentation/bloc/cart_event.dart';
import 'package:agrilink/features/cart/presentation/bloc/cart_state.dart';
import 'package:agrilink/features/cart/domain/usecases/cart_usecases.dart';

// Mock UseCases
class MockGetCartUseCase extends Mock implements GetCartUseCase {}
class MockAddToCartUseCase extends Mock implements AddToCartUseCase {}
class MockUpdateCartUseCase extends Mock implements UpdateCartUseCase {}
class MockRemoveFromCartUseCase extends Mock implements RemoveFromCartUseCase {}
class MockClearCartUseCase extends Mock implements ClearCartUseCase {}
class MockCheckoutUseCase extends Mock implements CheckoutUseCase {}
class MockVerifyPaymentUseCase extends Mock implements VerifyPaymentUseCase {}

void main() {
  late CartBloc cartBloc;
  late MockGetCartUseCase mockGetCartUseCase;
  late MockAddToCartUseCase mockAddToCartUseCase;
  late MockUpdateCartUseCase mockUpdateCartUseCase;
  late MockRemoveFromCartUseCase mockRemoveFromCartUseCase;
  late MockClearCartUseCase mockClearCartUseCase;
  late MockCheckoutUseCase mockCheckoutUseCase;
  late MockVerifyPaymentUseCase mockVerifyPaymentUseCase;

  setUp(() {
    mockGetCartUseCase = MockGetCartUseCase();
    mockAddToCartUseCase = MockAddToCartUseCase();
    mockUpdateCartUseCase = MockUpdateCartUseCase();
    mockRemoveFromCartUseCase = MockRemoveFromCartUseCase();
    mockClearCartUseCase = MockClearCartUseCase();
    mockCheckoutUseCase = MockCheckoutUseCase();
    mockVerifyPaymentUseCase = MockVerifyPaymentUseCase();

    // Mock getCart to return empty list
    when(() => mockGetCartUseCase.call()).thenAnswer((_) async => []);

    cartBloc = CartBloc(
      getCartUseCase: mockGetCartUseCase,
      addToCartUseCase: mockAddToCartUseCase,
      updateCartUseCase: mockUpdateCartUseCase,
      removeFromCartUseCase: mockRemoveFromCartUseCase,
      clearCartUseCase: mockClearCartUseCase,
      checkoutUseCase: mockCheckoutUseCase,
      verifyPaymentUseCase: mockVerifyPaymentUseCase,
    );
  });

  Widget createCartScreen() {
    return MaterialApp(
      home: BlocProvider<CartBloc>.value(
        value: cartBloc,
        child: const CartScreen(),
      ),
    );
  }

  group('CartScreen Unit Tests', () {
    testWidgets('1. CartScreen renders without crashing', (WidgetTester tester) async {
      await tester.pumpWidget(createCartScreen());
      await tester.pump();
      expect(find.byType(CartScreen), findsOneWidget);
    });

    testWidgets('2. CartScreen has Scaffold', (WidgetTester tester) async {
      await tester.pumpWidget(createCartScreen());
      await tester.pump();
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('3. CartScreen has AppBar', (WidgetTester tester) async {
      await tester.pumpWidget(createCartScreen());
      await tester.pump();
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('4. CartScreen has title "My Cart"', (WidgetTester tester) async {
      await tester.pumpWidget(createCartScreen());
      await tester.pump();
      expect(find.text('My Cart'), findsOneWidget);
    });

    testWidgets('5. AppBar background is green', (WidgetTester tester) async {
      await tester.pumpWidget(createCartScreen());
      await tester.pump();
      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBar.backgroundColor, Colors.green);
    });

    testWidgets('6. AppBar foreground is white', (WidgetTester tester) async {
      await tester.pumpWidget(createCartScreen());
      await tester.pump();
      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBar.foregroundColor, Colors.white);
    });

    testWidgets('7. Scaffold background is grey', (WidgetTester tester) async {
      await tester.pumpWidget(createCartScreen());
      await tester.pump();
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, Colors.grey.shade50);
    });

    testWidgets('8. CartScreen has SafeArea', (WidgetTester tester) async {
      await tester.pumpWidget(createCartScreen());
      await tester.pump();
      expect(find.byType(SafeArea), findsWidgets);
    });

    testWidgets('9. CartScreen shows loading indicator', (WidgetTester tester) async {
      // Set initial state to CartLoading before building
      cartBloc.emit(CartLoading());
      
      await tester.pumpWidget(createCartScreen());
      await tester.pump();
      
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('10. Loading text is displayed', (WidgetTester tester) async {
      cartBloc.emit(CartLoading());
      
      await tester.pumpWidget(createCartScreen());
      await tester.pump();
      
      expect(find.text('Loading your cart...'), findsOneWidget);
    });

    testWidgets('11. CartScreen has BlocConsumer', (WidgetTester tester) async {
      await tester.pumpWidget(createCartScreen());
      await tester.pump();
      expect(find.byType(BlocConsumer<CartBloc, CartState>), findsOneWidget);
    });

    testWidgets('12. Empty state shows cart icon', (WidgetTester tester) async {
      // Emit empty state before building
      cartBloc.emit(const CartLoaded(cartItems: [], totalPrice: 0, totalItems: 0));
      
      await tester.pumpWidget(createCartScreen());
      await tester.pump();
      
      expect(find.byIcon(Icons.shopping_cart_outlined), findsOneWidget);
    });

    testWidgets('13. Empty state shows "Your cart is empty"', (WidgetTester tester) async {
      cartBloc.emit(const CartLoaded(cartItems: [], totalPrice: 0, totalItems: 0));
      
      await tester.pumpWidget(createCartScreen());
      await tester.pump();
      
      expect(find.text('Your cart is empty'), findsOneWidget);
    });

    testWidgets('14. Empty state has Browse Products button', (WidgetTester tester) async {
      cartBloc.emit(const CartLoaded(cartItems: [], totalPrice: 0, totalItems: 0));
      
      await tester.pumpWidget(createCartScreen());
      await tester.pump();
      
      expect(find.text('Browse Products'), findsOneWidget);
    });

    testWidgets('15. Browse Products button is ElevatedButton', (WidgetTester tester) async {
      cartBloc.emit(const CartLoaded(cartItems: [], totalPrice: 0, totalItems: 0));
      
      await tester.pumpWidget(createCartScreen());
      await tester.pump();
      
      final browseButton = find.widgetWithText(ElevatedButton, 'Browse Products');
      expect(browseButton, findsOneWidget);
    });
  });
}