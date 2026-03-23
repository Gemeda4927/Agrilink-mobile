import 'package:agrilink/core/network/api_constants.dart';
import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';

class CartService {
  final DioClient dioClient;

  CartService(this.dioClient);

  /// 🛒 GET CART ITEMS
  Future<Response> getCart() async {
    final response = await dioClient.get(ApiConstants.cart);
    return response;
  }

  /// ➕ ADD TO CART
  Future<Response> addToCart({
    required String productId,
    required int amount,
  }) async {
    final response = await dioClient.post(
      ApiConstants.cart,
      data: {"productId": productId, "amount": amount},
    );
    return response;
  }

  /// 🔄 UPDATE CART ITEM
  Future<Response> updateCart({
    required String productId,
    required int amount,
  }) async {
    final response = await dioClient.patch(
      ApiConstants.cart,
      data: {"productId": productId, "amount": amount},
    );
    return response;
  }

  /// ❌ REMOVE SINGLE ITEM
  Future<Response> removeItem(String productId) async {
    final response = await dioClient.delete(
      ApiConstants.deleteCartItem(productId),
    );
    return response;
  }

  /// ⚠️ CLEAR CART (TEMP SOLUTION)
  Future<void> clearCart(List<String> productIds) async {
    for (final id in productIds) {
      await removeItem(id);
    }
  }
}
