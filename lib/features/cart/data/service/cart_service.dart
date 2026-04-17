import 'package:agrilink/core/network/api_constants.dart';
import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entity/cart_item.dart';

class CartService {
  final DioClient dioClient;

  CartService(this.dioClient);

  /// 🛒 GET CART ITEMS
  Future<Response> getCart() async {
    try {
      return await dioClient.get(ApiConstants.cart);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// ➕ ADD TO CART
  Future<Response> addToCart({
    required String productId,
    required int amount,
  }) async {
    try {
      return await dioClient.post(
        ApiConstants.cart,
        data: {"productId": productId, "amount": amount},
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// 🔄 UPDATE CART ITEM
  Future<Response> updateCart({
    required String productId,
    required int amount,
  }) async {
    try {
      return await dioClient.patch(
        ApiConstants.cart,
        data: {"productId": productId, "amount": amount},
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// ❌ REMOVE SINGLE ITEM
  Future<Response> removeItem(String productId) async {
    try {
      return await dioClient.delete(ApiConstants.deleteCartItem(productId));
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// 🧹 CLEAR CART
  Future<void> clearCart(List<String> productIds) async {
    try {
      await Future.wait(productIds.map(removeItem));
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ================= PAYMENT FLOW =================

  Future<Response> checkout({
    required String address,
    required String paymentMethod,
    String? phone,
  }) async {
    try {
      return await dioClient.post(
        ApiConstants.checkout,
        data: {
          "address": address,
          "paymentMethod": paymentMethod,
          "phone": phone,
        },
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// 🔍 2. VERIFY PAYMENT / ORDER STATUS
  Future<Response> verifyPayment(String orderId) async {
    try {
      return await dioClient.get(ApiConstants.verifyOrder(orderId));
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// 🔄 3. RE-CHECK PAYMENT (Polling)
  Future<Response> checkPaymentStatus(String orderId) async {
    try {
      return await dioClient.get(ApiConstants.verifyOrder(orderId));
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// ❌ 4. CANCEL ORDER (Optional if backend supports)
  Future<Response> cancelOrder(String orderId) async {
    try {
      return await dioClient.post(
        "${ApiConstants.baseUrl}/orders/cancel/$orderId",
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// 📦 5. GET MY ORDERS
  Future<Response> getMyOrders() async {
    try {
      return await dioClient.get(ApiConstants.myOrders);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// 📄 6. GET SINGLE ORDER DETAILS
  Future<Response> getOrderDetails(String orderId) async {
    try {
      return await dioClient.get("${ApiConstants.baseUrl}/orders/$orderId");
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ================= EXTRA =================

  /// 💰 CALCULATE TOTAL
  Future<double> getCartTotal() async {
    final response = await getCart();
    final items = response.data['items'] as List;

    double total = 0;
    for (var item in items) {
      total += (item['price'] * item['amount']);
    }

    return total;
  }

  /// ⚠️ ERROR HANDLER
  String _handleError(DioException e) {
    if (e.response != null) {
      return e.response?.data['message'] ?? "Server error";
    } else {
      return "Network error. Please check your connection.";
    }
  }
}
