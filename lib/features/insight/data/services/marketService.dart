import 'package:agrilink/core/network/api_constants.dart';
import 'package:agrilink/core/network/dio_client.dart';
import 'package:agrilink/features/insight/data/model/market_insight.dart';
import 'package:dio/dio.dart';

class MarketService {
  final DioClient dioClient;

  MarketService({required this.dioClient});

  // ================= API METHODS =================

  /// Fetch all products (GET)
  Future<AllProductsResponse> getAllProducts() async {
    try {
      final response = await dioClient.get(ApiConstants.allProduct);

      if (response.statusCode == 200) {
        return AllProductsResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to load products: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Submit new market price (POST)
  Future<MarketPriceResponse> submitMarketPrice(
    MarketPriceRequest request,
  ) async {
    try {
      final response = await dioClient.post(
        ApiConstants.marketPrice,
        data: request.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return MarketPriceResponse.fromJson(response.data);
      } else {
        throw Exception(
          'Failed to submit market price: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Fetch all market prices (GET)
  Future<List<MarketPriceResponse>> getAllMarketPrices() async {
    try {
      final response = await dioClient.get(ApiConstants.marketPrice);

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => MarketPriceResponse.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load market prices: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Fetch approved market prices only (GET)
  Future<List<MarketPriceResponse>> getApprovedMarketPrices() async {
    try {
      final response = await dioClient.get(ApiConstants.marketPriceApproved);

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => MarketPriceResponse.fromJson(json)).toList();
      } else {
        throw Exception(
          'Failed to load approved market prices: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Update market price by ID (PATCH)
  Future<MarketPriceResponse> updateMarketPrice(
    String id,
    MarketPriceRequest request,
  ) async {
    try {
      final url = "${ApiConstants.marketPrice}/$id";
      final response = await dioClient.patch(url, data: request.toJson());

      if (response.statusCode == 200) {
        return MarketPriceResponse.fromJson(response.data);
      } else {
        throw Exception(
          'Failed to update market price: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // ================= ERROR HANDLING =================

  String _handleDioError(DioException e) {
    if (e.response != null) {
      final statusCode = e.response?.statusCode;
      final data = e.response?.data;

      switch (statusCode) {
        case 400:
          return 'Bad request: ${data?['message'] ?? 'Invalid data'}';
        case 401:
          return 'Unauthorized: Please login again';
        case 403:
          return 'Forbidden: You don\'t have permission';
        case 404:
          return 'Resource not found';
        case 500:
          return 'Server error: Please try again later';
        default:
          return 'Error: ${data?['message'] ?? e.message}';
      }
    } else if (e.type == DioExceptionType.connectionTimeout) {
      return 'Connection timeout: Please check your internet';
    } else if (e.type == DioExceptionType.receiveTimeout) {
      return 'Receive timeout: Server not responding';
    } else {
      return 'Network error: ${e.message}';
    }
  }
}
