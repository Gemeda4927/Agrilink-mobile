// i_market_repository.dart
import 'package:agrilink/features/insight/data/model/market_insight.dart';

abstract class IMarketRepository {
  // Product methods
  Future<AllProductsResponse> getAllProducts();
  Future<AllProductsResponse> getPublicProducts();

  // Market price methods
  Future<MarketPriceResponse> submitMarketPrice(MarketPriceRequest request);
  Future<List<MarketPriceResponse>> getAllMarketPrices();
  Future<List<MarketPriceResponse>> getApprovedMarketPrices();
  Future<List<MarketPriceResponse>> getMyMarketPrices();
  Future<MarketPriceResponse> updateMarketPrice(
    String id,
    MarketPriceRequest request,
  );

  // Approval methods (ADMIN/AGENT only)
  Future<MarketPriceResponse> approveMarketPrice(String id);
  Future<MarketPriceResponse> rejectMarketPrice(String id);
}
