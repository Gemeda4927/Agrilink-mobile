import 'package:agrilink/features/insight/data/model/market_insight.dart';

import '../../data/services/marketService.dart';

abstract class MarketState {}

// Initial State
class MarketInitial extends MarketState {}

// Loading State
class MarketLoading extends MarketState {}

// Loaded States
class ProductsLoaded extends MarketState {
  final List<ProductInfo> products;
  ProductsLoaded(this.products);
}

class MarketPricesLoaded extends MarketState {
  final List<MarketPriceResponse> marketPrices;
  MarketPricesLoaded(this.marketPrices);
}

class PriceStatisticsLoaded extends MarketState {
  final PriceStatistics statistics;
  PriceStatisticsLoaded(this.statistics);
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

class MarketPriceApproved extends MarketState {
  final MarketPriceResponse response;
  MarketPriceApproved(this.response);
}

class MarketPriceRejected extends MarketState {
  final MarketPriceResponse response;
  MarketPriceRejected(this.response);
}

class MarketPriceDeleted extends MarketState {
  final String id;
  MarketPriceDeleted(this.id);
}

// Error State
class MarketError extends MarketState {
  final String message;
  MarketError(this.message);
}
