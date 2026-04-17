// lib/features/order/domain/entities/farmer_order_item.dart

import 'farmer_product.dart';

class FarmerOrderItem {
  final String id;
  final String orderId;
  final String productId;
  final int amount;
  final int priceAtOrder;
  final FarmerProduct product;

  FarmerOrderItem({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.amount,
    required this.priceAtOrder,
    required this.product,
  });

  int get subtotal => amount * priceAtOrder;
  String get formattedSubtotal => '$subtotal ETB';
  String get productName => product.name;
}