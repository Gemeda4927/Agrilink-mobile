
import 'package:agrilink/features/cart/domain/entity/cart_item.dart';

abstract class CartState {}

class CartInitial extends CartState {}

class CartLoading extends CartState {}

class CartLoaded extends CartState {
  final List<CartItem> cartItems;
  final double totalPrice;
  final int totalItems;
  CartLoaded({
    required this.cartItems,
    required this.totalPrice,
    required this.totalItems,
  });
}

class CartError extends CartState {
  final String message;
  CartError({required this.message});
}

class CartSuccess extends CartState {
  final String message;
  CartSuccess({required this.message});
}

class CartProcessing extends CartState {
  final String message;
  CartProcessing({required this.message});
}

class CartCheckoutSuccess extends CartState {
  final String orderId;
  final String paymentUrl;
  
  CartCheckoutSuccess({
    required this.orderId,
    required this.paymentUrl,
  });
}