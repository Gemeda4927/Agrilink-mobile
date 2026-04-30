// lib/features/order/domain/entities/product.dart

import 'package:flutter/material.dart';

class Product {
  final String id;
  final String farmerId;
  final String name;
  final String subCategoryId;
  final int amount;
  final double price;
  final String description;
  final String? image;
  final DateTime createdAt;
  final String? city;
  final bool withDelivery;

  Product({
    required this.id,
    required this.farmerId,
    required this.name,
    required this.subCategoryId,
    required this.amount,
    required this.price,
    required this.description,
    this.image,
    required this.createdAt,
    this.city,
    required this.withDelivery,
  });
  
  String get formattedPrice => '${price.toStringAsFixed(0)} ETB';
  
  // Helper method to check if image exists
  bool get hasImage => image != null && image!.isNotEmpty;
  
  // Helper method to get image URL with fallback
  String get imageUrl => image ?? '';
  
  // Helper method to get product display name
  String get displayName => name.isNotEmpty ? name : 'Unknown Product';
  
  // Helper to check if delivery is available
  String get deliveryStatus => withDelivery ? 'Delivery Available' : 'Pickup Only';
  
  // Helper to get location display
  String get locationDisplay => city != null && city!.isNotEmpty ? '📍 $city' : '📍 Location not specified';
  
  // Helper to check if product is in stock
  bool get isInStock => amount > 0;
  
  String get stockStatus {
    if (amount <= 0) return 'Out of Stock';
    if (amount < 10) return 'Low Stock ($amount left)';
    return 'In Stock ($amount available)';
  }
  
  Color get stockStatusColor {
    if (amount <= 0) return Colors.red;
    if (amount < 10) return Colors.orange;
    return Colors.green;
  }
}