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

  // Helper to get product name safely
  String get productName => product.displayName;

  // Helper to check if product has image
  bool get productHasImage => product.hasImage;
}
