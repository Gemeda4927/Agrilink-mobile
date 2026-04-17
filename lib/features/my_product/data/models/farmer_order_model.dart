// lib/features/order/data/models/farmer_order_model.dart

import '../../domain/entities/farmer_order.dart';
import 'farmer_order_item_model.dart';

class FarmerOrderModel extends FarmerOrder {
  FarmerOrderModel({
    required super.id,
    required super.buyerId,
    required super.totalAmount,
    required super.txRef,
    required super.status,
    required super.paymentId,
    required super.paymentUrl,
    required super.currency,
    required super.createdAt,
    required super.buyer,
    required super.items,
  });

  factory FarmerOrderModel.fromJson(Map<String, dynamic> json) {
    return FarmerOrderModel(
      id: json['id'] as String? ?? '',
      buyerId: json['buyerId'] as String? ?? '',
      totalAmount: json['totalAmount'] as int? ?? 0,
      txRef: json['tx_ref'] as String? ?? '',
      status: json['status'] as String? ?? 'PENDING',
      paymentId: json['paymentId'] as String? ?? '',
      paymentUrl: json['paymentUrl'] as String? ?? '',
      currency: json['currency'] as String? ?? 'ETB',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      buyer: _parseBuyerInfo(json['buyer'] as Map<String, dynamic>? ?? {}),
      items: (json['items'] as List? ?? [])
          .map(
            (item) =>
                FarmerOrderItemModel.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  static BuyerInfo _parseBuyerInfo(Map<String, dynamic> json) {
    return BuyerInfo(
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      profile: json['profile'] != null
          ? _parseBuyerProfile(json['profile'] as Map<String, dynamic>)
          : null,
    );
  }

  static BuyerProfile _parseBuyerProfile(Map<String, dynamic> json) {
    return BuyerProfile(
      fullName: json['fullName'] as String?,
      imageUrl: json['imageUrl'] as String?,
      kebele: json['kebele'] != null
          ? KebeleInfo(
              name: (json['kebele'] as Map<String, dynamic>)['name'] as String?,
            )
          : null,
    );
  }
}
