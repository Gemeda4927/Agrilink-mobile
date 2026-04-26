import 'package:agrilink/features/insight/data/model/market_insight.dart';
import 'package:agrilink/features/insight/data/services/marketService.dart';

abstract class IMarketRepository {
  // Product methods
  Future<List<ProductInfo>> getAllProducts();
  Future<List<ProductInfo>> getPublicProducts();

  // Market price methods
  Future<MarketPriceResponse> submitMarketPrice(MarketPriceRequest request);
  Future<List<MarketPriceResponse>> getAllMarketPrices();
  Future<List<MarketPriceResponse>> getApprovedMarketPrices();
  Future<List<MarketPriceResponse>> getMyMarketPrices();
  Future<List<MarketPriceResponse>> getMarketPricesByWoreda(String woredaId);
  Future<List<MarketPriceResponse>> getMarketPricesByProduct(String productId);
  Future<MarketPriceResponse> getMarketPriceById(String id);
  Future<MarketPriceResponse> updateMarketPrice(
    String id,
    MarketPriceRequest request,
  );
  Future<MarketPriceResponse> approveMarketPrice(String id);
  Future<MarketPriceResponse> rejectMarketPrice(String id);
  Future<bool> deleteMarketPrice(String id);

  // Statistics methods
  Future<PriceStatistics> getProductPriceStatistics(String productId);
  Future<List<MarketPriceResponse>> getRecentPriceAlerts();
}
