import 'package:agrilink/features/insight/data/model/market_insight.dart';

abstract class MarketEvent {}

class GetAllProductsEvent extends MarketEvent {}

class SubmitMarketPriceEvent extends MarketEvent {
  final MarketPriceRequest request;
  SubmitMarketPriceEvent(this.request);
}

class GetAllMarketPricesEvent extends MarketEvent {}

class GetApprovedMarketPricesEvent extends MarketEvent {}

class UpdateMarketPriceEvent extends MarketEvent {
  final String id;
  final MarketPriceRequest request;
  UpdateMarketPriceEvent({required this.id, required this.request});
}

class ResetMarketStateEvent extends MarketEvent {}
