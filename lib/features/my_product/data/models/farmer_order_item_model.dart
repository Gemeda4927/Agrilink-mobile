// lib/features/order/data/models/farmer_order_item_model.dart

import '../../domain/entities/farmer_order_item.dart';
import 'farmer_product_model.dart';

class FarmerOrderItemModel extends FarmerOrderItem {
  FarmerOrderItemModel({
    required super.id,
    required super.orderId,
    required super.productId,
    required super.amount,
    required super.priceAtOrder,
    required super.product,
  });

  factory FarmerOrderItemModel.fromJson(Map<String, dynamic> json) {
    return FarmerOrderItemModel(
      id: json['id'] as String? ?? '',
      orderId: json['orderId'] as String? ?? '',
      productId: json['productId'] as String? ?? '',
      amount: json['amount'] as int? ?? 0,
      priceAtOrder: json['priceAtOrder'] as int? ?? 0,
      product: FarmerProductModel.fromJson(json['product'] as Map<String, dynamic>? ?? {}),
    );
  }
}