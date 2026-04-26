// market_repository_impl.dart
import 'package:agrilink/features/insight/data/model/market_insight.dart';
import 'package:agrilink/features/insight/data/services/marketService.dart';
import 'package:agrilink/features/insight/domain/repository/i_market_repository.dart';

class MarketRepositoryImpl implements IMarketRepository {
  final MarketService marketService;

  MarketRepositoryImpl({required this.marketService});

  @override
  Future<List<ProductInfo>> getAllProducts() async {
    try {
      return await marketService.getAllProducts();
    } catch (e) {
      throw Exception('Failed to get all products: $e');
    }
  }

  @override
  Future<List<ProductInfo>> getPublicProducts() async {
    try {
      return await marketService.getPublicProducts();
    } catch (e) {
      throw Exception('Failed to get public products: $e');
    }
  }

  @override
  Future<MarketPriceResponse> submitMarketPrice(
    MarketPriceRequest request,
  ) async {
    try {
      return await marketService.submitMarketPrice(request);
    } catch (e) {
      throw Exception('Failed to submit market price: $e');
    }
  }

  @override
  Future<List<MarketPriceResponse>> getAllMarketPrices() async {
    try {
      return await marketService.getAllMarketPrices();
    } catch (e) {
      throw Exception('Failed to get all market prices: $e');
    }
  }

  @override
  Future<List<MarketPriceResponse>> getApprovedMarketPrices() async {
    try {
      return await marketService.getApprovedMarketPrices();
    } catch (e) {
      throw Exception('Failed to get approved market prices: $e');
    }
  }

  @override
  Future<List<MarketPriceResponse>> getMyMarketPrices() async {
    try {
      return await marketService.getMyMarketPrices();
    } catch (e) {
      throw Exception('Failed to get my market prices: $e');
    }
  }

  @override
  Future<List<MarketPriceResponse>> getMarketPricesByWoreda(String woredaId) async {
    try {
      return await marketService.getMarketPricesByWoreda(woredaId);
    } catch (e) {
      throw Exception('Failed to get market prices by woreda: $e');
    }
  }

  @override
  Future<List<MarketPriceResponse>> getMarketPricesByProduct(String productId) async {
    try {
      return await marketService.getMarketPricesByProduct(productId);
    } catch (e) {
      throw Exception('Failed to get market prices by product: $e');
    }
  }

  @override
  Future<MarketPriceResponse> getMarketPriceById(String id) async {
    try {
      return await marketService.getMarketPriceById(id);
    } catch (e) {
      throw Exception('Failed to get market price by id: $e');
    }
  }

  @override
  Future<MarketPriceResponse> updateMarketPrice(
    String id,
    MarketPriceRequest request,
  ) async {
    try {
      return await marketService.updateMarketPrice(id, request);
    } catch (e) {
      throw Exception('Failed to update market price: $e');
    }
  }

  @override
  Future<MarketPriceResponse> approveMarketPrice(String id) async {
    try {
      return await marketService.approveMarketPrice(id);
    } catch (e) {
      throw Exception('Failed to approve market price: $e');
    }
  }

  @override
  Future<MarketPriceResponse> rejectMarketPrice(String id) async {
    try {
      return await marketService.rejectMarketPrice(id);
    } catch (e) {
      throw Exception('Failed to reject market price: $e');
    }
  }

  @override
  Future<bool> deleteMarketPrice(String id) async {
    try {
      return await marketService.deleteMarketPrice(id);
    } catch (e) {
      throw Exception('Failed to delete market price: $e');
    }
  }

  @override
  Future<PriceStatistics> getProductPriceStatistics(String productId) async {
    try {
      return await marketService.getProductPriceStatistics(productId);
    } catch (e) {
      throw Exception('Failed to get product price statistics: $e');
    }
  }

  @override
  Future<List<MarketPriceResponse>> getRecentPriceAlerts() async {
    try {
      return await marketService.getRecentPriceAlerts();
    } catch (e) {
      throw Exception('Failed to get recent price alerts: $e');
    }
  }
}