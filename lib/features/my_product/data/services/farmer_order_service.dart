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

  /// Update order status
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
  }) async {
    try {
      final Map<String, dynamic> data = {};
      
      if (name != null) data['name'] = name;
      if (amount != null) data['amount'] = amount;
      if (price != null) data['price'] = price;
      if (description != null) data['description'] = description;
      if (city != null) data['city'] = city;
      if (subCategoryId != null) data['subCategoryId'] = subCategoryId;
      if (withDelivery != null) data['withDelivery'] = withDelivery;
      if (image != null) data['image'] = image;

      final response = await _dioClient.patch(
        ApiConstants.patchProduct(productId),
        data: data,
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to update product: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
}