import 'package:agrilink/features/cart/presentation/bloc/cart_event.dart';
import 'package:agrilink/features/cart/presentation/bloc/cart_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entity/cart_item.dart';
import '../../domain/usecases/cart_usecases.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  // ================= CART USE CASES =================
  final GetCartUseCase getCartUseCase;
  final AddToCartUseCase addToCartUseCase;
  final UpdateCartUseCase updateCartUseCase;
  final RemoveFromCartUseCase removeFromCartUseCase;
  final ClearCartUseCase clearCartUseCase;

  // ================= PAYMENT USE CASES =================
  final CheckoutUseCase checkoutUseCase;
  final VerifyPaymentUseCase verifyPaymentUseCase;

  CartBloc({
    required this.getCartUseCase,
    required this.addToCartUseCase,
    required this.updateCartUseCase,
    required this.removeFromCartUseCase,
    required this.clearCartUseCase,
    required this.checkoutUseCase,
    required this.verifyPaymentUseCase,
  }) : super(CartInitial()) {
    // ================= CART EVENT HANDLERS =================
    on<LoadCart>(_onLoadCart);
    on<AddToCart>(_onAddToCart);
    on<UpdateCartItem>(_onUpdateCartItem);
    on<RemoveFromCart>(_onRemoveFromCart);
    on<ClearCart>(_onClearCart);

    // ================= PAYMENT EVENT HANDLERS =================
    on<CheckoutEvent>(_onCheckout);
    on<VerifyPaymentEvent>(_onVerifyPayment);
  }

  // ==================================================
  // CART EVENT HANDLERS
  // ==================================================

  /// Load cart from repository
  Future<void> _onLoadCart(LoadCart event, Emitter<CartState> emit) async {
    try {
      emit(CartLoading());

      final cartItems = await getCartUseCase();

      emit(
        CartLoaded(
          cartItems: cartItems,
          totalPrice: _calculateTotalPrice(cartItems),
          totalItems: _calculateTotalItems(cartItems),
        ),
      );
    } catch (e) {
      emit(CartError(message: 'Failed to load cart: ${e.toString()}'));
    }
  }

  /// Add product to cart
  Future<void> _onAddToCart(AddToCart event, Emitter<CartState> emit) async {
    try {
      emit(CartProcessing(message: 'Adding to cart...'));

      await addToCartUseCase(productId: event.productId, amount: event.amount);

      // Reload cart after adding
      add(LoadCart());

      emit(CartSuccess(message: 'Item added to cart'));
    } catch (e) {
      emit(CartError(message: 'Failed to add item: ${e.toString()}'));
    }
  }

  /// Update cart item quantity
  Future<void> _onUpdateCartItem(
    UpdateCartItem event,
    Emitter<CartState> emit,
  ) async {
    try {
      emit(CartProcessing(message: 'Updating cart...'));

      await updateCartUseCase(productId: event.productId, amount: event.amount);

      // Reload cart after update
      add(LoadCart());

      emit(CartSuccess(message: 'Cart updated'));
    } catch (e) {
      emit(CartError(message: 'Failed to update cart: ${e.toString()}'));
    }
  }

  /// Remove single item from cart
  Future<void> _onRemoveFromCart(
    RemoveFromCart event,
    Emitter<CartState> emit,
  ) async {
    try {
      emit(CartProcessing(message: 'Removing item...'));

      await removeFromCartUseCase(event.productId);

      // Reload cart after removal
      add(LoadCart());

      emit(CartSuccess(message: 'Item removed from cart'));
    } catch (e) {
      emit(CartError(message: 'Failed to remove item: ${e.toString()}'));
    }
  }

  /// Clear entire cart
  Future<void> _onClearCart(ClearCart event, Emitter<CartState> emit) async {
    try {
      emit(CartProcessing(message: 'Clearing cart...'));

      // Get current cart items to get their IDs
      final items = await getCartUseCase();
      final ids = items.map((e) => e.productId).toList();

      if (ids.isNotEmpty) {
        await clearCartUseCase(ids);
      }

      // Reload cart after clearing
      add(LoadCart());

      emit(CartSuccess(message: 'Cart cleared successfully'));
    } catch (e) {
      emit(CartError(message: 'Failed to clear cart: ${e.toString()}'));
    }
  }

  // ==================================================
  // PAYMENT EVENT HANDLERS
  // ==================================================

  Future<void> _onCheckout(CheckoutEvent event, Emitter<CartState> emit) async {
    try {
      emit(CartProcessing(message: "Initializing payment..."));

      final result = await checkoutUseCase(
        address: event.address,
        paymentMethod: event.paymentMethod,
        phone: event.phone,
      );

      // Extract values with null safety
      final orderId =
          result['orderId']?.toString() ??
          result['order_id']?.toString() ??
          result['id']?.toString();

      final paymentUrl =
          result['checkout_url']?.toString() ??
          result['paymentUrl']?.toString() ??
          result['payment_url']?.toString();

      if (orderId == null || orderId.isEmpty) {
        throw Exception('Order ID is missing from response');
      }

      if (paymentUrl == null || paymentUrl.isEmpty) {
        if (event.paymentMethod.toLowerCase() == 'cod') {
          emit(PaymentSuccess(orderId: orderId));
          return;
        }
        throw Exception('Payment URL is missing from response');
      }

      // Get current cart items for passing to next screen
      final currentState = state;
      List<CartItem> cartItems = [];
      double totalPrice = 0;
      int totalItems = 0;

      if (currentState is CartLoaded) {
        cartItems = currentState.cartItems;
        totalPrice = currentState.totalPrice;
        totalItems = currentState.totalItems;
      }

      emit(
        CartCheckoutSuccess(
          orderId: orderId,
          paymentUrl: paymentUrl,
          cartItems: cartItems,
          totalPrice: totalPrice,
          totalItems: totalItems,
        ),
      );
    } catch (e) {
      emit(CartError(message: "Checkout failed: ${e.toString()}"));
    }
  }

  /// Verify payment status after WebView returns
  Future<void> _onVerifyPayment(
    VerifyPaymentEvent event,
    Emitter<CartState> emit,
  ) async {
    try {
      emit(CartProcessing(message: "Verifying payment..."));

      final result = await verifyPaymentUseCase(event.orderId);

      final status = result['status']?.toString().toLowerCase() ?? 'pending';

      if (status == 'success' || status == 'paid' || status == 'completed') {
        // Clear cart after successful payment
        final items = await getCartUseCase();
        final ids = items.map((e) => e.productId).toList();
        if (ids.isNotEmpty) {
          await clearCartUseCase(ids);
        }

        emit(PaymentSuccess(orderId: event.orderId));
      } else if (status == 'pending') {
        emit(PaymentPending());
      } else {
        emit(PaymentFailed(message: "Payment ${status.toUpperCase()}"));
      }
    } catch (e) {
      emit(PaymentFailed(message: "Verification failed: ${e.toString()}"));
    }
  }

  // ==================================================
  // HELPER METHODS
  // ==================================================

  /// Calculate total price from cart items
  double _calculateTotalPrice(List<CartItem> cartItems) {
    double total = 0.0;
    for (final item in cartItems) {
      final price = double.tryParse(item.product.price) ?? 0.0;
      total += price * item.amount;
    }
    return total;
  }

  /// Calculate total number of items in cart
  int _calculateTotalItems(List<CartItem> cartItems) {
    int total = 0;
    for (final item in cartItems) {
      total += item.amount;
    }
    return total;
  }
}
