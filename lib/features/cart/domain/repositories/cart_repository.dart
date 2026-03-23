import 'package:agrilink/features/cart/domain/entity/cart_item.dart';

abstract class CartRepository {
  Future<List<CartItem>> getCart();
  Future<CartItem> addToCart(String productId, int amount);
  Future<CartItem> updateCart(String productId, int amount);
  Future<void> removeItem(String productId);
}
