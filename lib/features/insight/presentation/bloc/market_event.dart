import 'package:agrilink/features/insight/data/model/market_insight.dart';
import 'package:equatable/equatable.dart';

abstract class MarketEvent extends Equatable {
  const MarketEvent();
  @override
  List<Object> get props => [];
}

// Product Events
class GetAllProductsEvent extends MarketEvent {}
class GetPublicProductsEvent extends MarketEvent {}

// Market Price Events
class GetAllMarketPricesEvent extends MarketEvent {}
class GetApprovedMarketPricesEvent extends MarketEvent {}
class GetMyMarketPricesEvent extends MarketEvent {}

// Submission Events
class SubmitMarketPriceEvent extends MarketEvent {
  final MarketPriceRequest request;
  const SubmitMarketPriceEvent(this.request);
  @override
  List<Object> get props => [request];
}

class UpdateMarketPriceEvent extends MarketEvent {
  final String id;
  final MarketPriceRequest request;
  const UpdateMarketPriceEvent({required this.id, required this.request});
  @override
  List<Object> get props => [id, request];
}

// Approval Events (ADMIN/AGENT only)
class ApproveMarketPriceEvent extends MarketEvent {
  final String priceId;
  const ApproveMarketPriceEvent(this.priceId);
  @override
  List<Object> get props => [priceId];
}

class RejectMarketPriceEvent extends MarketEvent {
  final String priceId;
  const RejectMarketPriceEvent(this.priceId);
  @override
  List<Object> get props => [priceId];
}

// Reset Event
class ResetMarketStateEvent extends MarketEvent {}