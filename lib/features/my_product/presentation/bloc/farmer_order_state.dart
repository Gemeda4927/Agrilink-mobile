// ================= STATES =================
import 'package:agrilink/features/my_product/domain/entities/farmer_order.dart';
import 'package:equatable/equatable.dart';

abstract class FarmerOrderState extends Equatable {
  const FarmerOrderState();

  @override
  List<Object?> get props => [];
}

class FarmerOrderInitial extends FarmerOrderState {}

class FarmerOrderLoading extends FarmerOrderState {}

class FarmerOrdersLoaded extends FarmerOrderState {
  final List<FarmerOrder> orders;
  const FarmerOrdersLoaded(this.orders);

  @override
  List<Object?> get props => [orders];
}

class PendingFarmerOrdersLoaded extends FarmerOrderState {
  final List<FarmerOrder> orders;
  const PendingFarmerOrdersLoaded(this.orders);

  @override
  List<Object?> get props => [orders];
}

class FarmerOrderLoaded extends FarmerOrderState {
  final FarmerOrder order;
  const FarmerOrderLoaded(this.order);

  @override
  List<Object?> get props => [order];
}

class OrderStatusUpdated extends FarmerOrderState {
  final String message;
  const OrderStatusUpdated(this.message);

  @override
  List<Object?> get props => [message];
}

class ProductPatched extends FarmerOrderState {
  final Map<String, dynamic> product;
  const ProductPatched(this.product);

  @override
  List<Object?> get props => [product];
}

class FarmerOrderError extends FarmerOrderState {
  final String message;
  const FarmerOrderError(this.message);

  @override
  List<Object?> get props => [message];
}
