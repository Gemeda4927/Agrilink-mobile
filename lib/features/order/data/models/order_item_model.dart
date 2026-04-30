// lib/features/order/data/models/order_model.dart

import '../../domain/entities/order.dart';
import 'order_item_model.dart';
import 'order_model.dart';

class BuyerInfo {
  final String id;
  final String email;
  final String? phone;
  final BuyerProfile? profile;

  BuyerInfo({
    required this.id,
    required this.email,
    this.phone,
    this.profile,
  });

  factory BuyerInfo.fromJson(Map<String, dynamic> json) {
    return BuyerInfo(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      profile: json['profile'] != null
          ? BuyerProfile.fromJson(json['profile'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'phone': phone,
      'profile': profile?.toJson(),
    };
  }
}

class BuyerProfile {
  final String fullName;
  final String? imageUrl;
  final BuyerKebele? kebele;

  BuyerProfile({
    required this.fullName,
    this.imageUrl,
    this.kebele,
  });

  factory BuyerProfile.fromJson(Map<String, dynamic> json) {
    return BuyerProfile(
      fullName: json['fullName'] ?? '',
      imageUrl: json['imageUrl'],
      kebele: json['kebele'] != null
          ? BuyerKebele.fromJson(json['kebele'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'imageUrl': imageUrl,
      'kebele': kebele?.toJson(),
    };
  }
}

class BuyerKebele {
  final String name;

  BuyerKebele({
    required this.name,
  });

  factory BuyerKebele.fromJson(Map<String, dynamic> json) {
    return BuyerKebele(
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
    };
  }
}

class OrderModel {
  final String id;
  final String buyerId;
  final double totalAmount;
  final String txRef;
  final String status;
  final String paymentId;
  final String paymentUrl;
  final String currency;
  final DateTime createdAt;
  final List<OrderItemModel> items;
  final BuyerInfo? buyer; // Added buyer info

  OrderModel({
    required this.id,
    required this.buyerId,
    required this.totalAmount,
    required this.txRef,
    required this.status,
    required this.paymentId,
    required this.paymentUrl,
    required this.currency,
    required this.createdAt,
    required this.items,
    this.buyer,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] ?? '',
      buyerId: json['buyerId'] ?? '',
      totalAmount: json['totalAmount'] != null
          ? (json['totalAmount'] as num).toDouble()
          : 0.0,
      txRef: json['tx_ref'] ?? '',
      status: json['status'] ?? 'PENDING',
      paymentId: json['paymentId'] ?? '',
      paymentUrl: json['paymentUrl'] ?? '',
      currency: json['currency'] ?? 'ETB',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      items: json['items'] != null && json['items'] is List
          ? (json['items'] as List)
              .map((item) => OrderItemModel.fromJson(item))
              .toList()
          : [],
      buyer: json['buyer'] != null
          ? BuyerInfo.fromJson(json['buyer'])
          : null,
    );
  }

  Order toEntity() {
    return Order(
      id: id,
      buyerId: buyerId,
      totalAmount: totalAmount,
      txRef: txRef,
      status: status,
      paymentId: paymentId,
      paymentUrl: paymentUrl,
      currency: currency,
      createdAt: createdAt,
      items: items.map((item) => item.toEntity()).toList(),
      buyerName: buyer?.profile?.fullName,
      buyerEmail: buyer?.email,
      buyerPhone: buyer?.phone,
      buyerImageUrl: buyer?.profile?.imageUrl,
      buyerKebele: buyer?.profile?.kebele?.name,
    );
  }

  // Helper method to check if order is pending
  bool get isPending => status == 'PENDING';
  bool get isPaid => status == 'PAID';
  bool get isCancelled => status == 'CANCELLED';
  bool get isRejected => status == 'REJECTED';
  bool get isApproved => status == 'APPROVED';
  bool get isCompleted => status == 'COMPLETED';
  bool get isDelivered => status == 'DELIVERED';
}