// lib/features/order/presentation/bloc/farmer_order_event.dart

import 'package:equatable/equatable.dart';

abstract class FarmerOrderEvent extends Equatable {
  const FarmerOrderEvent();
  @override
  List<Object?> get props => [];
}

class LoadFarmerOrders extends FarmerOrderEvent {}

class LoadPendingFarmerOrders extends FarmerOrderEvent {}

class RefreshFarmerOrders extends FarmerOrderEvent {}

class GetFarmerOrderById extends FarmerOrderEvent {
  final String orderId;
  const GetFarmerOrderById({required this.orderId});
  @override
  List<Object?> get props => [orderId];
}

class ConfirmFarmerOrder extends FarmerOrderEvent {
  final String orderId;
  const ConfirmFarmerOrder({required this.orderId});
  @override
  List<Object?> get props => [orderId];
}

class MarkOrderAsShipped extends FarmerOrderEvent {
  final String orderId;
  const MarkOrderAsShipped({required this.orderId});
  @override
  List<Object?> get props => [orderId];
}

class MarkOrderAsDelivered extends FarmerOrderEvent {
  final String orderId;
  const MarkOrderAsDelivered({required this.orderId});
  @override
  List<Object?> get props => [orderId];
}