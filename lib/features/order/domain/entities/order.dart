// lib/features/order/domain/entities/order.dart

import 'package:flutter/material.dart';

import 'order_item.dart';

class Order {
  final String id;
  final String buyerId;
  final double totalAmount;
  final String txRef;
  final String status;
  final String paymentId;
  final String paymentUrl;
  final String currency;
  final DateTime createdAt;
  final List<OrderItem> items;

  Order({
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
  });

  bool get isPaid => status == 'PAID';
  bool get isPending => status == 'PENDING';
  bool get isFailed => status == 'FAILED';
  bool get isCancelled => status == 'CANCELLED';

  String get formattedTotalAmount =>
      '${totalAmount.toStringAsFixed(0)} $currency';
  String get formattedDate => _formatDate(createdAt);

  // Get status color for UI
  Color get statusColor {
    switch (status) {
      case 'PAID':
        return Colors.green;
      case 'PENDING':
        return Colors.orange;
      case 'FAILED':
        return Colors.red;
      case 'CANCELLED':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }

  // Get status icon for UI
  IconData get statusIcon {
    switch (status) {
      case 'PAID':
        return Icons.check_circle;
      case 'PENDING':
        return Icons.pending;
      case 'FAILED':
        return Icons.error;
      case 'CANCELLED':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  // Get total items count
  int get totalItems => items.fold(0, (sum, item) => sum + item.amount);

  // Get unique products count
  int get uniqueProductsCount => items.length;
}
