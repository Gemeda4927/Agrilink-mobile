import '../../domain/entity/cart_item.dart';

abstract class CartEvent {
  const CartEvent();
}

// ================= CART OPERATIONS =================

/// Load cart items from server
class LoadCart extends CartEvent {
  const LoadCart();
}

/// Add product to cart
class AddToCart extends CartEvent {
  final String productId;
  final int amount;

  const AddToCart({required this.productId, required this.amount});

  @override
  List<Object> get props => [productId, amount];
}

/// Update cart item quantity
class UpdateCartItem extends CartEvent {
  final String productId;
  final int amount;

  const UpdateCartItem({required this.productId, required this.amount});

  @override
  List<Object> get props => [productId, amount];
}

/// Remove single item from cart
class RemoveFromCart extends CartEvent {
  final String productId;

  const RemoveFromCart({required this.productId});

  @override
  List<Object> get props => [productId];
}

/// Clear entire cart
class ClearCart extends CartEvent {
  const ClearCart();
}

// ================= PAYMENT OPERATIONS =================

/// Initialize checkout/payment

// In cart_event.dart - Update CheckoutEvent

// features/cart/presentation/bloc/cart_event.dart

class CheckoutEvent extends CartEvent {
  final String address;
  final String paymentMethod;
  final String? phone;

  const CheckoutEvent({
    required this.address,
    required this.paymentMethod,
    this.phone,
  });

  @override
  List<Object?> get props => [address, paymentMethod, phone];
}

/// Verify payment after WebView returns
class VerifyPaymentEvent extends CartEvent {
  final String orderId;

  const VerifyPaymentEvent({required this.orderId});

  @override
  List<Object> get props => [orderId];
}
