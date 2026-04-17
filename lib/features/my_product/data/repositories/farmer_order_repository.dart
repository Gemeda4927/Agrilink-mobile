// lib/features/order/data/repositories/farmer_order_repository.dart

import '../../domain/entities/farmer_order.dart';
import '../../domain/repositories/i_farmer_order_repository.dart';
import '../services/farmer_order_service.dart';

class FarmerOrderRepository implements IFarmerOrderRepository {
  final FarmerOrderService _service;

  FarmerOrderRepository(this._service);

  @override
  Future<List<FarmerOrder>> getFarmerOrders() async {
    try {
      final models = await _service.getFarmerOrders();
      return models;
    } catch (e) {
      throw Exception('Failed to get farmer orders: $e');
    }
  }

  @override
  Future<List<FarmerOrder>> getPendingFarmerOrders() async {
    try {
      final models = await _service.getPendingFarmerOrders();
      return models;
    } catch (e) {
      throw Exception('Failed to get pending farmer orders: $e');
    }
  }

  @override
  Future<FarmerOrder> getFarmerOrderById(String orderId) async {
    try {
      final model = await _service.getFarmerOrderById(orderId);
      return model;
    } catch (e) {
      throw Exception('Failed to get farmer order: $e');
    }
  }

  @override
  Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      await _service.updateOrderStatus(orderId, status);
    } catch (e) {
      throw Exception('Failed to update order status: $e');
    }
  }

  @override
  Future<void> confirmOrder(String orderId) async {
    try {
      await _service.confirmOrder(orderId);
    } catch (e) {
      throw Exception('Failed to confirm order: $e');
    }
  }

  @override
  Future<void> markAsShipped(String orderId) async {
    try {
      await _service.markAsShipped(orderId);
    } catch (e) {
      throw Exception('Failed to mark order as shipped: $e');
    }
  }

  @override
  Future<void> markAsDelivered(String orderId) async {
    try {
      await _service.markAsDelivered(orderId);
    } catch (e) {
      throw Exception('Failed to mark order as delivered: $e');
    }
  }
}
