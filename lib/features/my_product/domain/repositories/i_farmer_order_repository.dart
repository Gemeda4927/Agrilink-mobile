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

  /// Confirm order
  Future<void> confirmOrder(String orderId);

  /// Mark order as shipped
  Future<void> markAsShipped(String orderId);

  /// Mark order as delivered
  Future<void> markAsDelivered(String orderId);
}