

abstract class CartEvent {}

class LoadCart extends CartEvent {}

class AddToCart extends CartEvent {
  final String productId;
  final int amount;
  AddToCart({required this.productId, required this.amount});
}

class UpdateCartItem extends CartEvent {
  final String productId;
  final int amount;
  UpdateCartItem({required this.productId, required this.amount});
}

class RemoveFromCart extends CartEvent {
  final String productId;
  RemoveFromCart({required this.productId});
}

class ClearCart extends CartEvent {}

class ProcessCheckout extends CartEvent {} // Add this event
