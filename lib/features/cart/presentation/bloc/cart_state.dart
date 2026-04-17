// features/cart/presentation/bloc/cart_state.dart

import 'package:agrilink/features/cart/domain/entity/cart_item.dart';

// ==================================================
// CART STATE
// ==================================================

abstract class CartState {
  const CartState();
}

// ================= INITIAL STATE =================

/// Initial state before any action
class CartInitial extends CartState {
  const CartInitial();
}

// ================= LOADING STATES =================

/// Loading cart data
class CartLoading extends CartState {
  const CartLoading();
}

/// Processing state for any cart operation (add, remove, update, checkout)
class CartProcessing extends CartState {
  final String message;

  const CartProcessing({required this.message});

  @override
  List<Object> get props => [message];
}

// ================= SUCCESS STATES =================

/// Cart loaded with items
class CartLoaded extends CartState {
  final List<CartItem> cartItems;
  final double totalPrice;
  final int totalItems;

  const CartLoaded({
    required this.cartItems,
    required this.totalPrice,
    required this.totalItems,
  });

  @override
  List<Object> get props => [cartItems, totalPrice, totalItems];
}

/// Success state for cart operations (add, remove, update, clear)
class CartSuccess extends CartState {
  final String message;

  const CartSuccess({required this.message});

  @override
  List<Object> get props => [message];
}

class CartCheckoutSuccess extends CartState {
  final String orderId;
  final String paymentUrl;
  final List<CartItem> cartItems; // ✅ ADD THIS
  final double totalPrice; // ✅ ADD THIS
  final int totalItems; // ✅ ADD THIS

  const CartCheckoutSuccess({
    required this.orderId,
    required this.paymentUrl,
    required this.cartItems, // ✅ ADD THIS
    required this.totalPrice, // ✅ ADD THIS
    required this.totalItems, // ✅ ADD THIS
  });

  @override
  List<Object> get props => [
    orderId,
    paymentUrl,
    cartItems,
    totalPrice,
    totalItems,
  ];
}

// ================= PAYMENT STATES =================

/// Payment verified successfully
class PaymentSuccess extends CartState {
  final String orderId;

  const PaymentSuccess({required this.orderId});

  @override
  List<Object> get props => [orderId];
}

/// Payment is pending verification
class PaymentPending extends CartState {
  const PaymentPending();
}

/// Payment failed
class PaymentFailed extends CartState {
  final String message;

  const PaymentFailed({required this.message});

  @override
  List<Object> get props => [message];
}

// ================= ERROR STATE =================

/// Error state for any failure
class CartError extends CartState {
  final String message;

  const CartError({required this.message});

  @override
  List<Object> get props => [message];
}
