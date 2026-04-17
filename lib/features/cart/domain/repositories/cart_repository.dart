import 'package:agrilink/features/cart/domain/entity/cart_item.dart';

abstract class CartRepository {
  // ================= CART =================
  Future<List<CartItem>> getCart();

  Future<CartItem> addToCart(String productId, int amount);

  Future<CartItem> updateCart(String productId, int amount);

  Future<void> removeItem(String productId);

  Future<void> clearCart(List<String> productIds);

  Future<double> getCartTotal();

  // ================= PAYMENT =================

  /// Create order + initialize payment

  Future<Map<String, dynamic>> checkout({
    required String address,
    required String paymentMethod,
    String? phone,
  });

  /// Verify payment after redirect
  Future<Map<String, dynamic>> verifyPayment(String orderId);

  /// Polling payment status
  Future<Map<String, dynamic>> checkPaymentStatus(String orderId);

  /// Cancel order (optional backend support)
  Future<void> cancelOrder(String orderId);

  /// Get all user orders
  Future<List<dynamic>> getMyOrders();

  /// Get single order details
  Future<Map<String, dynamic>> getOrderDetails(String orderId);
}
