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
  
  // Buyer info fields (from API response)
  final String? buyerName;
  final String? buyerEmail;
  final String? buyerPhone;
  final String? buyerImageUrl;
  final String? buyerKebele;

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
    this.buyerName,
    this.buyerEmail,
    this.buyerPhone,
    this.buyerImageUrl,
    this.buyerKebele,
  });

  // Status helpers
  bool get isPaid => status == 'PAID';
  bool get isPending => status == 'PENDING';
  bool get isFailed => status == 'FAILED';
  bool get isCancelled => status == 'CANCELLED';
  bool get isRejected => status == 'REJECTED';
  bool get isApproved => status == 'APPROVED';
  bool get isDelivered => status == 'DELIVERED';
  bool get isCompleted => status == 'COMPLETED';

  String get formattedTotalAmount =>
      '${totalAmount.toStringAsFixed(0)} $currency';
  
  String get formattedDate => _formatDate(createdAt);

  // Get status color for UI
  Color get statusColor {
    switch (status) {
      case 'PAID':
        return Colors.blue;
      case 'APPROVED':
        return Colors.green;
      case 'DELIVERED':
        return Colors.teal;
      case 'COMPLETED':
        return Colors.green;
      case 'PENDING':
        return Colors.orange;
      case 'FAILED':
        return Colors.red;
      case 'CANCELLED':
        return Colors.grey;
      case 'REJECTED':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  // Get status display text
  String get statusDisplay {
    switch (status) {
      case 'PENDING':
        return 'Pending Payment';
      case 'PAID':
        return 'Paid';
      case 'APPROVED':
        return 'Approved';
      case 'DELIVERED':
        return 'Delivered';
      case 'COMPLETED':
        return 'Completed';
      case 'CANCELLED':
        return 'Cancelled';
      case 'REJECTED':
        return 'Rejected';
      case 'FAILED':
        return 'Failed';
      default:
        return status;
    }
  }

  // Get status icon for UI
  IconData get statusIcon {
    switch (status) {
      case 'PAID':
        return Icons.payment;
      case 'APPROVED':
        return Icons.check_circle;
      case 'DELIVERED':
        return Icons.local_shipping;
      case 'COMPLETED':
        return Icons.done_all;
      case 'PENDING':
        return Icons.pending;
      case 'FAILED':
        return Icons.error;
      case 'CANCELLED':
        return Icons.cancel;
      case 'REJECTED':
        return Icons.block;
      default:
        return Icons.info;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  // Get relative time (e.g., "2 days ago")
  String get relativeTime {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }

  // Get total items count
  int get totalItems => items.fold(0, (sum, item) => sum + item.amount);

  // Get unique products count
  int get uniqueProductsCount => items.length;

  // Get buyer display name (with fallback)
  String get buyerDisplayName {
    if (buyerName != null && buyerName!.isNotEmpty) {
      return buyerName!;
    }
    if (buyerEmail != null && buyerEmail!.isNotEmpty) {
      return buyerEmail!.split('@').first;
    }
    return 'Customer';
  }

  // Get buyer initials for avatar
  String get buyerInitials {
    final name = buyerDisplayName;
    if (name.isEmpty) return '?';
    
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  // Check if buyer has image
  bool get buyerHasImage => buyerImageUrl != null && buyerImageUrl!.isNotEmpty;
}