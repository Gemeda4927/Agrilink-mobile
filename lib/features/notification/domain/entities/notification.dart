import 'package:flutter/material.dart';

class NotificationEntity {
  final String id;
  final String userId;
  final NotificationType type;
  final String title;
  final String message;
  final bool isSent;
  bool isRead;
  final DateTime createdAt;

  NotificationEntity({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.message,
    required this.isSent,
    this.isRead = false,
    required this.createdAt,
  });

  // Helper getters
  bool get isWelcome => type == NotificationType.welcome;
  bool get isNewOrder => type == NotificationType.newOrder;
  bool get isOrderPlaced => type == NotificationType.orderPlaced;
  bool get isProductCreated => type == NotificationType.productCreated;
  bool get isProductUpdated => type == NotificationType.productUpdated;
  bool get isRoleApproved => type == NotificationType.roleApproved;
  bool get isRoleRejected => type == NotificationType.roleRejected;

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

  Color get iconColor {
    switch (type) {
      case NotificationType.welcome:
        return Colors.blue;
      case NotificationType.newOrder:
      case NotificationType.orderPlaced:
        return Colors.green;
      case NotificationType.productCreated:
      case NotificationType.productUpdated:
        return Colors.teal;
      case NotificationType.roleApproved:
        return Colors.green;
      case NotificationType.roleRejected:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData get iconData {
    switch (type) {
      case NotificationType.welcome:
        return Icons.waving_hand;
      case NotificationType.newOrder:
        return Icons.shopping_bag;
      case NotificationType.orderPlaced:
        return Icons.check_circle;
      case NotificationType.productCreated:
        return Icons.add_box;
      case NotificationType.productUpdated:
        return Icons.update;
      case NotificationType.roleApproved:
        return Icons.verified_user;
      case NotificationType.roleRejected:
        return Icons.cancel;
      default:
        return Icons.notifications;
    }
  }
}

enum NotificationType {
  welcome,
  newOrder,
  orderPlaced,
  productCreated,
  productUpdated,
  roleApproved,
  roleRejected,
  unknown;

  static NotificationType fromString(String value) {
    switch (value) {
      case 'WELCOME':
        return NotificationType.welcome;
      case 'NEW_ORDER':
        return NotificationType.newOrder;
      case 'ORDER_PLACED':
        return NotificationType.orderPlaced;
      case 'PRODUCT_CREATED':
        return NotificationType.productCreated;
      case 'PRODUCT_UPDATED':
        return NotificationType.productUpdated;
      case 'ROLE_APPROVED':
        return NotificationType.roleApproved;
      case 'ROLE_REJECTED':
        return NotificationType.roleRejected;
      default:
        return NotificationType.unknown;
    }
  }

  String get stringValue {
    switch (this) {
      case NotificationType.welcome:
        return 'WELCOME';
      case NotificationType.newOrder:
        return 'NEW_ORDER';
      case NotificationType.orderPlaced:
        return 'ORDER_PLACED';
      case NotificationType.productCreated:
        return 'PRODUCT_CREATED';
      case NotificationType.productUpdated:
        return 'PRODUCT_UPDATED';
      case NotificationType.roleApproved:
        return 'ROLE_APPROVED';
      case NotificationType.roleRejected:
        return 'ROLE_REJECTED';
      default:
        return 'UNKNOWN';
    }
  }
}