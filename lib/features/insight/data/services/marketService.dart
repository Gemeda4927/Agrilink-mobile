import 'package:agrilink/core/network/api_constants.dart';
import 'package:agrilink/core/network/dio_client.dart';
import 'package:agrilink/features/insight/data/model/market_insight.dart';
import 'package:dio/dio.dart';

class MarketService {
  final DioClient dioClient;

  MarketService({required this.dioClient});

  // ================= PRODUCT ENDPOINTS =================

  /// Fetch all products (GET) - For privileged users (ADMIN, AGENT, DATA_CONTRIBUTOR)
  Future<List<ProductInfo>> getAllProducts() async {
    try {
      final response = await dioClient.get(ApiConstants.allProduct);

      if (response.statusCode == 200) {
        if (response.data is List) {
          return (response.data as List)
              .map((json) => ProductInfo.fromJson(json))
              .toList();
        } else if (response.data is Map && response.data['product'] != null) {
          final productsList = response.data['product'] as List;
          return productsList
              .map((json) => ProductInfo.fromJson(json))
              .toList();
        }
        return [];
      } else {
        throw Exception('Failed to load products: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Fetch public products (GET) - For BUYER/FARMER role
  Future<List<ProductInfo>> getPublicProducts() async {
    try {
      final response = await dioClient.get(ApiConstants.product);

      if (response.statusCode == 200) {
        if (response.data is List) {
          return (response.data as List)
              .map((json) => ProductInfo.fromJson(json))
              .toList();
        } else if (response.data is Map && response.data['product'] != null) {
          final productsList = response.data['product'] as List;
          return productsList
              .map((json) => ProductInfo.fromJson(json))
              .toList();
        }
        return [];
      } else {
        throw Exception(
          'Failed to load public products: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // ================= MARKET PRICE ENDPOINTS =================

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

  /// Fetch all market prices (GET) - For privileged users
  Future<List<MarketPriceResponse>> getAllMarketPrices() async {
    try {
      final response = await dioClient.get(ApiConstants.marketPrice);

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data is List
            ? response.data
            : (response.data['data'] as List?) ?? [];
        return data.map((json) => MarketPriceResponse.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load market prices: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Fetch approved market prices only (GET) - For all users (public)
  Future<List<MarketPriceResponse>> getApprovedMarketPrices() async {
    try {
      final response = await dioClient.get(ApiConstants.marketPriceApproved);

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data is List
            ? response.data
            : (response.data['data'] as List?) ?? [];
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

  /// Fetch my market prices (GET) - For DATA_CONTRIBUTOR
  Future<List<MarketPriceResponse>> getMyMarketPrices() async {
    try {
      final response = await dioClient.get(ApiConstants.marketPriceMyProduct);

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data is List
            ? response.data
            : (response.data['data'] as List?) ?? [];
        return data.map((json) => MarketPriceResponse.fromJson(json)).toList();
      } else {
        throw Exception(
          'Failed to load my market prices: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Fetch market price by ID (GET)
  Future<MarketPriceResponse> getMarketPriceById(String id) async {
    try {
      final response = await dioClient.get(ApiConstants.getMarketPriceById(id));

      if (response.statusCode == 200) {
        return MarketPriceResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to load market price: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Fetch market prices by woreda (GET)
  Future<List<MarketPriceResponse>> getMarketPricesByWoreda(
    String woredaId,
  ) async {
    try {
      final response = await dioClient.get(
        '${ApiConstants.marketPrice}/woreda/$woredaId',
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data is List
            ? response.data
            : (response.data['data'] as List?) ?? [];
        return data.map((json) => MarketPriceResponse.fromJson(json)).toList();
      } else {
        throw Exception(
          'Failed to load market prices by woreda: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Fetch market prices by product (GET)
  Future<List<MarketPriceResponse>> getMarketPricesByProduct(
    String productId,
  ) async {
    try {
      final response = await dioClient.get(
        '${ApiConstants.marketPrice}/product/$productId',
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data is List
            ? response.data
            : (response.data['data'] as List?) ?? [];
        return data.map((json) => MarketPriceResponse.fromJson(json)).toList();
      } else {
        throw Exception(
          'Failed to load market prices by product: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // ================= MARKET PRICE MODIFICATION ENDPOINTS =================

  /// Update market price by ID (PATCH)
  Future<MarketPriceResponse> updateMarketPrice(
    String id,
    MarketPriceRequest request,
  ) async {
    try {
      final response = await dioClient.patch(
        '${ApiConstants.marketPrice}/$id',
        data: request.toJson(),
      );

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

  /// Approve market price (PATCH) - For ADMIN/AGENT
  Future<MarketPriceResponse> approveMarketPrice(String id) async {
    try {
      final response = await dioClient.patch(
        ApiConstants.approveMarketPrice(id),
        data: {'approve': true}, // ✅ Send boolean true for approval
      );

      if (response.statusCode == 200) {
        return MarketPriceResponse.fromJson(response.data);
      } else {
        throw Exception(
          'Failed to approve market price: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Reject market price (PATCH) - For ADMIN/AGENT
  Future<MarketPriceResponse> rejectMarketPrice(String id) async {
    try {
      final response = await dioClient.patch(
        ApiConstants.rejectMarketPrice(id),
        data: {'approve': false}, 
      );

      if (response.statusCode == 200) {
        return MarketPriceResponse.fromJson(response.data);
      } else {
        throw Exception(
          'Failed to reject market price: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Delete market price (DELETE) - For ADMIN/AGENT
  Future<bool> deleteMarketPrice(String id) async {
    try {
      final response = await dioClient.delete(
        '${ApiConstants.marketPrice}/$id',
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        throw Exception(
          'Failed to delete market price: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // ================= STATISTICS & ALERTS ENDPOINTS =================

  /// Get price statistics for a product (GET)
  Future<PriceStatistics> getProductPriceStatistics(String productId) async {
    try {
      final response = await dioClient.get(
        '${ApiConstants.marketPrice}/statistics/product/$productId',
      );

      if (response.statusCode == 200) {
        return PriceStatistics.fromJson(response.data);
      } else {
        throw Exception(
          'Failed to load price statistics: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Get recent price alerts (GET)
  Future<List<MarketPriceResponse>> getRecentPriceAlerts() async {
    try {
      final response = await dioClient.get(
        '${ApiConstants.marketPrice}/alerts/recent',
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data is List
            ? response.data
            : (response.data['data'] as List?) ?? [];
        return data.map((json) => MarketPriceResponse.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load price alerts: ${response.statusCode}');
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
          return 'Bad request: ${_extractErrorMessage(data)}';
        case 401:
          return 'Unauthorized: Please login again';
        case 403:
          return 'Forbidden: You don\'t have permission to access this resource';
        case 404:
          return 'Resource not found';
        case 409:
          return 'Conflict: ${_extractErrorMessage(data)}';
        case 422:
          return 'Validation error: ${_extractErrorMessage(data)}';
        case 429:
          return 'Too many requests: Please try again later';
        case 500:
          return 'Server error: Please try again later';
        case 502:
          return 'Bad gateway: Server is temporarily unavailable';
        case 503:
          return 'Service unavailable: Please try again later';
        default:
          return 'Error: ${_extractErrorMessage(data) ?? e.message}';
      }
    } else if (e.type == DioExceptionType.connectionTimeout) {
      return 'Connection timeout: Please check your internet connection';
    } else if (e.type == DioExceptionType.receiveTimeout) {
      return 'Receive timeout: Server is not responding';
    } else if (e.type == DioExceptionType.sendTimeout) {
      return 'Send timeout: Unable to send data to server';
    } else if (e.type == DioExceptionType.cancel) {
      return 'Request was cancelled';
    } else if (e.type == DioExceptionType.connectionError) {
      return 'Connection error: Please check your internet connection';
    } else if (e.type == DioExceptionType.unknown) {
      if (e.message?.contains('SocketException') == true) {
        return 'Network error: Unable to connect to server';
      }
      return 'Unknown error: ${e.message}';
    } else {
      return 'Network error: ${e.message}';
    }
  }

  String _extractErrorMessage(dynamic data) {
    if (data == null) return '';
    if (data is String) return data;
    if (data is Map) {
      if (data.containsKey('message')) return data['message'].toString();
      if (data.containsKey('error')) return data['error'].toString();
      if (data.containsKey('errors')) {
        final errors = data['errors'];
        if (errors is Map) {
          return errors.values.join(', ');
        }
        if (errors is List) {
          return errors.join(', ');
        }
      }
      if (data.containsKey('data') && data['data'] is Map) {
        final innerData = data['data'] as Map;
        if (innerData.containsKey('message')) {
          return innerData['message'].toString();
        }
      }
    }
    return 'An unexpected error occurred';
  }
}

// ================= PRICE STATISTICS MODEL =================

/// Price statistics model
class PriceStatistics {
  final String productId;
  final String productName;
  final double averagePrice;
  final double minPrice;
  final double maxPrice;
  final double priceChange24h;
  final double priceChangePercentage;
  final int totalSubmissions;
  final DateTime lastUpdated;

  PriceStatistics({
    required this.productId,
    required this.productName,
    required this.averagePrice,
    required this.minPrice,
    required this.maxPrice,
    required this.priceChange24h,
    required this.priceChangePercentage,
    required this.totalSubmissions,
    required this.lastUpdated,
  });

  factory PriceStatistics.fromJson(Map<String, dynamic> json) {
    return PriceStatistics(
      productId: json['productId']?.toString() ?? '',
      productName: json['productName']?.toString() ?? '',
      averagePrice: (json['averagePrice'] as num?)?.toDouble() ?? 0.0,
      minPrice: (json['minPrice'] as num?)?.toDouble() ?? 0.0,
      maxPrice: (json['maxPrice'] as num?)?.toDouble() ?? 0.0,
      priceChange24h: (json['priceChange24h'] as num?)?.toDouble() ?? 0.0,
      priceChangePercentage:
          (json['priceChangePercentage'] as num?)?.toDouble() ?? 0.0,
      totalSubmissions: json['totalSubmissions'] ?? 0,
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'].toString())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'averagePrice': averagePrice,
      'minPrice': minPrice,
      'maxPrice': maxPrice,
      'priceChange24h': priceChange24h,
      'priceChangePercentage': priceChangePercentage,
      'totalSubmissions': totalSubmissions,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  bool get isPriceUp => priceChange24h > 0;
  bool get isPriceDown => priceChange24h < 0;
  String get trendIcon => isPriceUp ? '📈' : (isPriceDown ? '📉' : '➡️');
}
