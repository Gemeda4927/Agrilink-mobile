import 'package:agrilink/core/network/api_constants.dart';
import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../models/order_item_model.dart';
import '../models/order_model.dart';

class OrderService {
  final DioClient dioClient;

  OrderService({required this.dioClient});

  // Get my orders as a BUYER
  Future<List<OrderModel>> getMyOrders() async {
    try {
      final Response response = await dioClient.get(ApiConstants.myOrders);

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => OrderModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load orders: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Error fetching orders: $e');
    }
  }

  // Get orders received as a FARMER/SELLER
  Future<List<OrderModel>> getFarmerOrders() async {
    try {
      final Response response = await dioClient.get(ApiConstants.farmerOrders);

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => OrderModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load farmer orders: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Error fetching farmer orders: $e');
    }
  }

  // Get pending farmer orders only
  Future<List<OrderModel>> getPendingFarmerOrders() async {
    try {
      final Response response = await dioClient.get(
        ApiConstants.farmerOrdersPending,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => OrderModel.fromJson(json)).toList();
      } else {
        throw Exception(
          'Failed to load pending farmer orders: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Error fetching pending farmer orders: $e');
    }
  }

  // Get single order details by ID (for buyers)
  Future<OrderModel> getOrderById(String orderId) async {
    try {
      final Response response = await dioClient.get(
        ApiConstants.verifyOrder(orderId),
      );

      if (response.statusCode == 200) {
        return OrderModel.fromJson(response.data);
      } else {
        throw Exception('Failed to load order details: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Error fetching order details: $e');
    }
  }

  // Get farmer order details by ID
  Future<OrderModel> getFarmerOrderById(String orderId) async {
    try {
      final Response response = await dioClient.get(
        '${ApiConstants.farmerOrders}/$orderId',
      );

      if (response.statusCode == 200) {
        return OrderModel.fromJson(response.data);
      } else {
        throw Exception(
          'Failed to load farmer order details: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Error fetching farmer order details: $e');
    }
  }

  // Update order status (for farmers to update order status)
  Future<OrderModel> updateOrderStatus(String orderId, String status) async {
    try {
      final Response response = await dioClient.patch(
        ApiConstants.updateOrderStatus(orderId),
        data: {'status': status},
      );

      if (response.statusCode == 200) {
        return OrderModel.fromJson(response.data);
      } else {
        throw Exception(
          'Failed to update order status: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Error updating order status: $e');
    }
  }

  // Accept order (for farmers)
  Future<OrderModel> acceptOrder(String orderId) async {
    return updateOrderStatus(orderId, 'ACCEPTED');
  }

  // Reject order (for farmers)
  Future<OrderModel> rejectOrder(String orderId, {String? reason}) async {
    try {
      final Response response = await dioClient.patch(
        ApiConstants.updateOrderStatus(orderId),
        data: {
          'status': 'REJECTED',
          if (reason != null) 'rejectionReason': reason,
        },
      );

      if (response.statusCode == 200) {
        return OrderModel.fromJson(response.data);
      } else {
        throw Exception('Failed to reject order: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Error rejecting order: $e');
    }
  }

  // Mark order as delivered (for farmers)
  Future<OrderModel> markAsDelivered(String orderId) async {
    return updateOrderStatus(orderId, 'DELIVERED');
  }

  // Cancel order (for buyers)
  Future<OrderModel> cancelOrder(String orderId) async {
    try {
      final Response response = await dioClient.patch(
        ApiConstants.updateOrderStatus(orderId),
        data: {'status': 'CANCELLED'},
      );

      if (response.statusCode == 200) {
        return OrderModel.fromJson(response.data);
      } else {
        throw Exception('Failed to cancel order: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Error cancelling order: $e');
    }
  }

  // Mark order as completed (for buyers)
  Future<OrderModel> completeOrder(String orderId) async {
    try {
      final Response response = await dioClient.patch(
        ApiConstants.updateOrderStatus(orderId),
        data: {'status': 'COMPLETED'},
      );

      if (response.statusCode == 200) {
        return OrderModel.fromJson(response.data);
      } else {
        throw Exception('Failed to complete order: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Error completing order: $e');
    }
  }

  // Checkout - create order from cart
  Future<Map<String, dynamic>> checkout({
    required String addressId,
    required String paymentMethod,
  }) async {
    try {
      final Response response = await dioClient.post(
        ApiConstants.checkout,
        data: {'addressId': addressId, 'paymentMethod': paymentMethod},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      } else {
        throw Exception('Failed to checkout: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Error during checkout: $e');
    }
  }

  // Verify order payment
  Future<OrderModel> verifyOrder(String orderId) async {
    try {
      final Response response = await dioClient.get(
        ApiConstants.verifyOrder(orderId),
      );

      if (response.statusCode == 200) {
        return OrderModel.fromJson(response.data);
      } else {
        throw Exception('Failed to verify order: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Error verifying order: $e');
    }
  }

  // Get order counts by status (for buyers)
  Future<Map<String, int>> getOrderCounts() async {
    try {
      final orders = await getMyOrders();
      final Map<String, int> counts = {};

      for (final order in orders) {
        counts[order.status] = (counts[order.status] ?? 0) + 1;
      }

      return counts;
    } catch (e) {
      throw Exception('Error calculating order counts: $e');
    }
  }

  // Get farmer order counts by status
  Future<Map<String, int>> getFarmerOrderCounts() async {
    try {
      final orders = await getFarmerOrders();
      final Map<String, int> counts = {};

      for (final order in orders) {
        counts[order.status] = (counts[order.status] ?? 0) + 1;
      }

      return counts;
    } catch (e) {
      throw Exception('Error calculating farmer order counts: $e');
    }
  }

  // ================= DATE RANGE ORDER METHODS =================

  // Get orders by date range (for both buyers and farmers)
  Future<List<OrderModel>> getOrdersByDateRange({
    required DateTime startDate,
    required DateTime endDate,
    String? role,
  }) async {
    try {
      // Format dates for API (YYYY-MM-DD)
      final formattedStartDate = _formatDate(startDate);
      final formattedEndDate = _formatDate(endDate);
      
      // Determine which endpoint to use based on role
      String endpoint;
      if (role == 'farmer') {
        endpoint = ApiConstants.farmerOrdersDateRange(formattedStartDate, formattedEndDate);
      } else {
        endpoint = ApiConstants.myOrdersDateRange(formattedStartDate, formattedEndDate);
      }
      
      final Response response = await dioClient.get(endpoint);

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => OrderModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load orders by date range: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Error fetching orders by date range: $e');
    }
  }

  // Helper method to format date as YYYY-MM-DD
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _handleDioError(DioException error) {
    if (error.response != null) {
      final data = error.response?.data;
      if (data != null && data is Map) {
        return data['message'] ?? 'Server error occurred';
      }
      return 'Server error: ${error.response?.statusCode}';
    } else if (error.type == DioExceptionType.connectionTimeout) {
      return 'Connection timeout. Please check your internet connection.';
    } else if (error.type == DioExceptionType.receiveTimeout) {
      return 'Receive timeout. Please try again.';
    } else if (error.type == DioExceptionType.connectionError) {
      return 'No internet connection. Please check your network.';
    } else {
      return 'Unexpected error: ${error.message}';
    }
  }
}