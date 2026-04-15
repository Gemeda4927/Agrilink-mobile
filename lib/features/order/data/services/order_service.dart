import 'package:agrilink/core/network/api_constants.dart';
import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../models/order_model.dart';

class OrderService {
  final DioClient dioClient;

  OrderService({required this.dioClient});

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
