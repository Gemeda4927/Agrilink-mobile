// lib/features/order/domain/entities/order_item.dart

import 'product.dart';

class OrderItem {
  final String id;
  final String orderId;
  final String productId;
  final int amount;
  final double priceAtOrder;
  final Product product;

  OrderItem({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.amount,
    required this.priceAtOrder,
    required this.product,
  });

  double get subtotal => amount * priceAtOrder;
  
  String get formattedSubtotal => '${subtotal.toStringAsFixed(0)} ETB';
  
  String get formattedPriceAtOrder => '${priceAtOrder.toStringAsFixed(0)} ETB';

  // Helper to get product name safely
  String get productName => product.displayName;

  // Helper to check if product has image
  bool get productHasImage => product.hasImage;
  
  String get productImageUrl => product.imageUrl;
  
  String get productDescription => product.description;
  
  int get productAvailableAmount => product.amount;
  
  String get productFarmerId => product.farmerId;
  
  String get productCity => product.city ?? 'Not specified';
  
  bool get productWithDelivery => product.withDelivery;
}