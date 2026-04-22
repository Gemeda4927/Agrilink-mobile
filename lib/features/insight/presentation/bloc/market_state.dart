import 'package:agrilink/features/insight/data/model/market_insight.dart';

abstract class MarketState {}

// Initial State
class MarketInitial extends MarketState {}

// Loading State
class MarketLoading extends MarketState {}

// Loaded States
class ProductsLoaded extends MarketState {
  final AllProductsResponse productsResponse;
  ProductsLoaded(this.productsResponse);
}

class MarketPricesLoaded extends MarketState {
  final List<MarketPriceResponse> marketPrices;
  MarketPricesLoaded(this.marketPrices);
}

// Success States
class MarketPriceSubmitted extends MarketState {
  final MarketPriceResponse response;
  MarketPriceSubmitted(this.response);
}

class MarketPriceUpdated extends MarketState {
  final MarketPriceResponse response;
  MarketPriceUpdated(this.response);
}

// Error State
class MarketError extends MarketState {
  final String message;
  MarketError(this.message);
}
