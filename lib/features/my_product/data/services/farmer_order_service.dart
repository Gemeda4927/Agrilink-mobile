// lib/features/order/data/services/farmer_order_service.dart

import 'package:agrilink/core/network/api_constants.dart';
import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../models/farmer_order_model.dart';

class FarmerOrderService {
  final DioClient _dioClient;

  FarmerOrderService(this._dioClient);

  /// Get all farmer orders (orders received from buyers)
  Future<List<FarmerOrderModel>> getFarmerOrders() async {
    try {
      final response = await _dioClient.get(ApiConstants.farmerOrders);

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => FarmerOrderModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load farmer orders: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Get pending farmer orders
  Future<List<FarmerOrderModel>> getPendingFarmerOrders() async {
    try {
      final response = await _dioClient.get(ApiConstants.farmerOrdersPending);

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => FarmerOrderModel.fromJson(json)).toList();
      } else {
        throw Exception(
          'Failed to load pending farmer orders: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Get farmer order by ID
  Future<FarmerOrderModel> getFarmerOrderById(String orderId) async {
    try {
      final response = await _dioClient.get(
        '${ApiConstants.farmerOrders}/$orderId',
      );

      if (response.statusCode == 200) {
        return FarmerOrderModel.fromJson(response.data);
      } else {
        throw Exception('Failed to load farmer order: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Update order status (for farmer to confirm/ship)
  Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      final response = await _dioClient.patch(
        '${ApiConstants.farmerOrders}/$orderId/status',
        data: {'status': status},
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to update order status: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Confirm order (mark as confirmed by farmer)
  Future<void> confirmOrder(String orderId) async {
    await updateOrderStatus(orderId, 'CONFIRMED');
  }

  /// Mark order as shipped
  Future<void> markAsShipped(String orderId) async {
    await updateOrderStatus(orderId, 'SHIPPED');
  }

  /// Mark order as delivered
  Future<void> markAsDelivered(String orderId) async {
    await updateOrderStatus(orderId, 'DELIVERED');
  }
}