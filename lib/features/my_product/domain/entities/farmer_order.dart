// lib/features/order/domain/entities/farmer_order.dart

import 'package:flutter/material.dart';

import 'farmer_order_item.dart';

class FarmerOrder {
  final String id;
  final String buyerId;
  final int totalAmount;
  final String txRef;
  final String status;
  final String paymentId;
  final String paymentUrl;
  final String currency;
  final DateTime createdAt;
  final BuyerInfo buyer;
  final List<FarmerOrderItem> items;

  FarmerOrder({
    required this.id,
    required this.buyerId,
    required this.totalAmount,
    required this.txRef,
    required this.status,
    required this.paymentId,
    required this.paymentUrl,
    required this.currency,
    required this.createdAt,
    required this.buyer,
    required this.items,
  });

  bool get isPaid => status == 'PAID';
  bool get isPending => status == 'PENDING';
  bool get isFailed => status == 'FAILED';
  bool get isCancelled => status == 'CANCELLED';
  
  String get formattedTotalAmount => '${totalAmount.toStringAsFixed(0)} $currency';
  String get formattedDate => _formatDate(createdAt);
  int get totalItems => items.fold(0, (sum, item) => sum + item.amount);
  
  Color get statusColor {
    switch (status) {
      case 'PAID': return Colors.green;
      case 'PENDING': return Colors.orange;
      case 'FAILED': return Colors.red;
      case 'CANCELLED': return Colors.grey;
      default: return Colors.blue;
    }
  }
  
  String get statusText {
    switch (status) {
      case 'PAID': return 'Paid';
      case 'PENDING': return 'Pending';
      case 'FAILED': return 'Failed';
      case 'CANCELLED': return 'Cancelled';
      default: return status;
    }
  }
  
  // ADD THIS - statusIcon getter
  IconData get statusIcon {
    switch (status) {
      case 'PAID': return Icons.check_circle;
      case 'PENDING': return Icons.pending;
      case 'FAILED': return Icons.error;
      case 'CANCELLED': return Icons.cancel;
      default: return Icons.info;
    }
  }
  
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

class BuyerInfo {
  final String id;
  final String email;
  final String phone;
  final BuyerProfile? profile;

  BuyerInfo({
    required this.id,
    required this.email,
    required this.phone,
    this.profile,
  });

  String get displayName => profile?.fullName ?? email.split('@').first;
  String? get imageUrl => profile?.imageUrl;
  bool get hasImage => imageUrl != null && imageUrl!.isNotEmpty;
  String? get location => profile?.kebele?.name;
}

class BuyerProfile {
  final String? fullName;
  final String? imageUrl;
  final KebeleInfo? kebele;

  BuyerProfile({this.fullName, this.imageUrl, this.kebele});
}

class KebeleInfo {
  final String? name;
  KebeleInfo({this.name});
}