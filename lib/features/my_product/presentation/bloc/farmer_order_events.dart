
// ================= EVENTS =================
import 'package:equatable/equatable.dart';

abstract class FarmerOrderEvent extends Equatable {
  const FarmerOrderEvent();

  @override
  List<Object?> get props => [];
}

class LoadFarmerOrdersEvent extends FarmerOrderEvent {
  const LoadFarmerOrdersEvent();
}

class LoadPendingFarmerOrdersEvent extends FarmerOrderEvent {
  const LoadPendingFarmerOrdersEvent();
}

class LoadFarmerOrderByIdEvent extends FarmerOrderEvent {
  final String orderId;
  const LoadFarmerOrderByIdEvent(this.orderId);

  @override
  List<Object?> get props => [orderId];
}

class UpdateOrderStatusEvent extends FarmerOrderEvent {
  final String orderId;
  final String status;
  const UpdateOrderStatusEvent({required this.orderId, required this.status});

  @override
  List<Object?> get props => [orderId, status];
}

class PatchProductEvent extends FarmerOrderEvent {
  final String productId;
  final String? name;
  final int? amount;
  final double? price;
  final String? description;
  final String? city;
  final String? subCategoryId;
  final bool? withDelivery;
  final String? image;

  const PatchProductEvent({
    required this.productId,
    this.name,
    this.amount,
    this.price,
    this.description,
    this.city,
    this.subCategoryId,
    this.withDelivery,
    this.image,
  });

  @override
  List<Object?> get props => [
    productId,
    name,
    amount,
    price,
    description,
    city,
    subCategoryId,
    withDelivery,
    image,
  ];
}