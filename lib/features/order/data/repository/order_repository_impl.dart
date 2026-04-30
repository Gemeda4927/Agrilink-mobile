// lib/features/order/data/repositories/order_repository_impl.dart

import '../../domain/entities/order.dart';
import '../../domain/repositories/order_repository.dart';
import '../services/order_service.dart';

class OrderRepositoryImpl implements OrderRepository {
  final OrderService orderService;

  OrderRepositoryImpl({required this.orderService});

  // ================= BUYER ORDER METHODS =================

  @override
  Future<List<Order>> getMyOrders() async {
    try {
      final orderModels = await orderService.getMyOrders();
      return orderModels.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to get my orders: $e');
    }
  }

  @override
  Future<Order> getOrderById(String orderId) async {
    try {
      final orderModel = await orderService.getOrderById(orderId);
      return orderModel.toEntity();
    } catch (e) {
      throw Exception('Failed to get order by id: $e');
    }
  }

  @override
  Future<Order> cancelOrder(String orderId) async {
    try {
      final orderModel = await orderService.cancelOrder(orderId);
      return orderModel.toEntity();
    } catch (e) {
      throw Exception('Failed to cancel order: $e');
    }
  }

  @override
  Future<Order> completeOrder(String orderId) async {
    try {
      final orderModel = await orderService.completeOrder(orderId);
      return orderModel.toEntity();
    } catch (e) {
      throw Exception('Failed to complete order: $e');
    }
  }

  @override
  Future<Map<String, int>> getOrderCounts() async {
    try {
      return await orderService.getOrderCounts();
    } catch (e) {
      throw Exception('Failed to get order counts: $e');
    }
  }

  // ================= FARMER/SELLER ORDER METHODS =================

  @override
  Future<List<Order>> getFarmerOrders() async {
    try {
      final orderModels = await orderService.getFarmerOrders();
      return orderModels.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to get farmer orders: $e');
    }
  }

  @override
  Future<List<Order>> getPendingFarmerOrders() async {
    try {
      final orderModels = await orderService.getPendingFarmerOrders();
      return orderModels.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to get pending farmer orders: $e');
    }
  }

  @override
  Future<Order> getFarmerOrderById(String orderId) async {
    try {
      final orderModel = await orderService.getFarmerOrderById(orderId);
      return orderModel.toEntity();
    } catch (e) {
      throw Exception('Failed to get farmer order by id: $e');
    }
  }

  @override
  Future<Order> updateOrderStatus(String orderId, String status) async {
    try {
      final orderModel = await orderService.updateOrderStatus(orderId, status);
      return orderModel.toEntity();
    } catch (e) {
      throw Exception('Failed to update order status: $e');
    }
  }

  @override
  Future<Order> acceptOrder(String orderId) async {
    try {
      final orderModel = await orderService.acceptOrder(orderId);
      return orderModel.toEntity();
    } catch (e) {
      throw Exception('Failed to accept order: $e');
    }
  }

  @override
  Future<Order> rejectOrder(String orderId, {String? reason}) async {
    try {
      final orderModel = await orderService.rejectOrder(orderId, reason: reason);
      return orderModel.toEntity();
    } catch (e) {
      throw Exception('Failed to reject order: $e');
    }
  }

  @override
  Future<Order> markAsDelivered(String orderId) async {
    try {
      final orderModel = await orderService.markAsDelivered(orderId);
      return orderModel.toEntity();
    } catch (e) {
      throw Exception('Failed to mark order as delivered: $e');
    }
  }

  @override
  Future<Map<String, int>> getFarmerOrderCounts() async {
    try {
      return await orderService.getFarmerOrderCounts();
    } catch (e) {
      throw Exception('Failed to get farmer order counts: $e');
    }
  }

  // ================= CHECKOUT METHODS =================

  @override
  Future<Map<String, dynamic>> checkout({
    required String addressId,
    required String paymentMethod,
  }) async {
    try {
      return await orderService.checkout(
        addressId: addressId,
        paymentMethod: paymentMethod,
      );
    } catch (e) {
      throw Exception('Failed to checkout: $e');
    }
  }

  @override
  Future<Order> verifyOrder(String orderId) async {
    try {
      final orderModel = await orderService.verifyOrder(orderId);
      return orderModel.toEntity();
    } catch (e) {
      throw Exception('Failed to verify order: $e');
    }
  }

  // ================= DATE RANGE ORDER METHODS =================

  @override
  Future<List<Order>> getOrdersByDateRange({
    required DateTime startDate,
    required DateTime endDate,
    String? role,
  }) async {
    try {
      final orderModels = await orderService.getOrdersByDateRange(
        startDate: startDate,
        endDate: endDate,
        role: role,
      );
      return orderModels.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to get orders by date range: $e');
    }
  }
}