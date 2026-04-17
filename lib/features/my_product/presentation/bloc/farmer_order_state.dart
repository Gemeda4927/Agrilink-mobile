
import 'package:equatable/equatable.dart';

import '../../domain/entities/farmer_order.dart';

abstract class FarmerOrderState extends Equatable {
  const FarmerOrderState();
  @override
  List<Object?> get props => [];
}

class FarmerOrderInitial extends FarmerOrderState {}

class FarmerOrderLoading extends FarmerOrderState {}

class FarmerOrderActionLoading extends FarmerOrderState {}

class FarmerOrderLoaded extends FarmerOrderState {
  final List<FarmerOrder> orders;
  const FarmerOrderLoaded({required this.orders});
  @override
  List<Object?> get props => [orders];
}

class FarmerOrderDetailLoaded extends FarmerOrderState {
  final FarmerOrder order;
  const FarmerOrderDetailLoaded({required this.order});
  @override
  List<Object?> get props => [order];
}

class FarmerOrderActionSuccess extends FarmerOrderState {
  final String message;
  const FarmerOrderActionSuccess({required this.message});
  @override
  List<Object?> get props => [message];
}

class FarmerOrderError extends FarmerOrderState {
  final String message;
  const FarmerOrderError({required this.message});
  @override
  List<Object?> get props => [message];
}