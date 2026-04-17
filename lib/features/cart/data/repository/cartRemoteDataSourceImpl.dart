import 'package:agrilink/features/cart/data/models/CartItemModel.dart';
import 'package:agrilink/features/cart/data/service/cart_service.dart';
import 'package:agrilink/features/cart/domain/entity/cart_item.dart';
import 'package:agrilink/features/cart/domain/repositories/cart_repository.dart';
import 'package:agrilink/features/product/domain/entities/product_entities.dart';

class CartRepositoryImpl implements CartRepository {
  final CartService service;

  CartRepositoryImpl(this.service);

  // ================= MAPPER (REMOVE DUPLICATION) =================
  CartItem _mapToEntity(CartItemModel model) {
    return CartItem(
      id: model.id,
      productId: model.productId,
      amount: model.amount,
      product: ProductEntity(
        id: model.product.id,
        farmerId: model.product.farmerId,
        name: model.product.name,
        subCategoryId: model.product.subCategoryId,
        amount: model.product.amount,
        price: model.product.price,
        description: model.product.description,
        image: model.product.image,
        createdAt: model.product.createdAt,
        subCategoryName: model.product.subCategoryName,
        categoryId: model.product.categoryId,
        farmerEmail: model.product.farmerEmail,
        farmerPhone: model.product.farmerPhone,
        farmerRole: model.product.farmerRole,
      ),
    );
  }

  // ================= CART =================

  @override
  Future<List<CartItem>> getCart() async {
    final response = await service.getCart();

    final data = response.data;

    // Handle both List and {items: []}
    final List items = data is List ? data : data['items'];

    return items.map((e) => _mapToEntity(CartItemModel.fromJson(e))).toList();
  }

  @override
  Future<CartItem> addToCart(String productId, int amount) async {
    final response = await service.addToCart(
      productId: productId,
      amount: amount,
    );

    return _mapToEntity(CartItemModel.fromJson(response.data));
  }

  @override
  Future<CartItem> updateCart(String productId, int amount) async {
    final response = await service.updateCart(
      productId: productId,
      amount: amount,
    );

    return _mapToEntity(CartItemModel.fromJson(response.data));
  }

  @override
  Future<void> removeItem(String productId) async {
    await service.removeItem(productId);
  }

  @override
  Future<void> clearCart(List<String> productIds) async {
    await service.clearCart(productIds);
  }

  // ================= PAYMENT =================

  @override
  @override
  Future<Map<String, dynamic>> checkout({
    required String address,
    required String paymentMethod,
    String? phone,
  }) async {
    final response = await service.checkout(
      address: address,
      paymentMethod: paymentMethod,
      phone: phone,
    );
    return response.data;
  }

  @override
  Future<Map<String, dynamic>> verifyPayment(String orderId) async {
    final response = await service.verifyPayment(orderId);
    return response.data;
  }

  @override
  Future<Map<String, dynamic>> checkPaymentStatus(String orderId) async {
    final response = await service.checkPaymentStatus(orderId);
    return response.data;
  }

  @override
  Future<void> cancelOrder(String orderId) async {
    await service.cancelOrder(orderId);
  }

  @override
  Future<List<dynamic>> getMyOrders() async {
    final response = await service.getMyOrders();
    return response.data;
  }

  @override
  Future<Map<String, dynamic>> getOrderDetails(String orderId) async {
    final response = await service.getOrderDetails(orderId);
    return response.data;
  }

  // ================= EXTRA =================

  @override
  Future<double> getCartTotal() async {
    return await service.getCartTotal();
  }
}
