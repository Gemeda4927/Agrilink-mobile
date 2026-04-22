import 'package:agrilink/features/insight/data/model/market_insight.dart';

abstract class IMarketRepository {
  Future<AllProductsResponse> getAllProducts();

  Future<MarketPriceResponse> submitMarketPrice(MarketPriceRequest request);

  Future<List<MarketPriceResponse>> getAllMarketPrices();

  Future<List<MarketPriceResponse>> getApprovedMarketPrices();

  Future<MarketPriceResponse> updateMarketPrice(
    String id,
    MarketPriceRequest request,
  );
}
