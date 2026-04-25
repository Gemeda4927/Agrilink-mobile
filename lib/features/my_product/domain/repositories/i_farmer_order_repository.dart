// lib/features/order/domain/repositories/i_farmer_order_repository.dart

import '../entities/farmer_order.dart';

abstract class IFarmerOrderRepository {
  /// Get all orders received by the farmer
  Future<List<FarmerOrder>> getFarmerOrders();

  /// Get pending orders only
  Future<List<FarmerOrder>> getPendingFarmerOrders();

  /// Get single order by ID
  Future<FarmerOrder> getFarmerOrderById(String orderId);

  /// Update order status
  Future<void> updateOrderStatus(String orderId, String status);

  /// PATCH: Partially update a product
  Future<Map<String, dynamic>> patchProduct({
    required String productId,
    String? name,
    int? amount,
    double? price,
    String? description,
    String? city,
    String? subCategoryId,
    bool? withDelivery,
    String? image,
  });
}
