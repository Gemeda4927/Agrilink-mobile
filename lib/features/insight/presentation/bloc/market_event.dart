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

class GetMarketPricesByWoredaEvent extends MarketEvent {
  final String woredaId;
  const GetMarketPricesByWoredaEvent(this.woredaId);
  @override
  List<Object> get props => [woredaId];
}

class GetMarketPricesByProductEvent extends MarketEvent {
  final String productId;
  const GetMarketPricesByProductEvent(this.productId);
  @override
  List<Object> get props => [productId];
}

class GetMarketPriceByIdEvent extends MarketEvent {
  final String id;
  const GetMarketPriceByIdEvent(this.id);
  @override
  List<Object> get props => [id];
}

// Statistics Events
class GetProductPriceStatisticsEvent extends MarketEvent {
  final String productId;
  const GetProductPriceStatisticsEvent(this.productId);
  @override
  List<Object> get props => [productId];
}

class GetRecentPriceAlertsEvent extends MarketEvent {}

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

class DeleteMarketPriceEvent extends MarketEvent {
  final String priceId;
  const DeleteMarketPriceEvent(this.priceId);
  @override
  List<Object> get props => [priceId];
}

// Reset Event
class ResetMarketStateEvent extends MarketEvent {}
