// market_repository_impl.dart
import 'package:agrilink/features/insight/data/model/market_insight.dart';
import 'package:agrilink/features/insight/data/services/marketService.dart';
import 'package:agrilink/features/insight/domain/repository/i_market_repository.dart';

class MarketRepositoryImpl implements IMarketRepository {
  final MarketService marketService;

  MarketRepositoryImpl({required this.marketService});

  @override
  Future<AllProductsResponse> getAllProducts() async {
    try {
      return await marketService.getAllProducts();
    } catch (e) {
      throw Exception('Failed to get all products: $e');
    }
  }

  @override
  Future<AllProductsResponse> getPublicProducts() async {
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
}