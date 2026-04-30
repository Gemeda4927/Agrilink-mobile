
import '../entities/order.dart' as order_entity;

abstract class OrderRepository {
  // Existing methods...
  Future<List<order_entity.Order>> getMyOrders();
  Future<List<order_entity.Order>> getFarmerOrders();
  Future<List<order_entity.Order>> getPendingFarmerOrders();
  Future<order_entity.Order> getOrderById(String orderId);
  Future<order_entity.Order> getFarmerOrderById(String orderId);
  Future<order_entity.Order> updateOrderStatus(String orderId, String status);
  Future<order_entity.Order> acceptOrder(String orderId);
  Future<order_entity.Order> rejectOrder(String orderId, {String? reason});
  Future<order_entity.Order> markAsDelivered(String orderId);
  Future<order_entity.Order> cancelOrder(String orderId);
  Future<order_entity.Order> completeOrder(String orderId);
  Future<Map<String, dynamic>> checkout({required String addressId, required String paymentMethod});
  Future<order_entity.Order> verifyOrder(String orderId);
  Future<Map<String, int>> getOrderCounts();
  Future<Map<String, int>> getFarmerOrderCounts();
  
  // ADD THIS NEW METHOD
  Future<List<order_entity.Order>> getOrdersByDateRange({
    required DateTime startDate,
    required DateTime endDate,
    String? role,
  });
}