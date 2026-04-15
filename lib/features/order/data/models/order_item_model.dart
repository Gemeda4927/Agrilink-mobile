import '../../domain/entities/order_item.dart';
import 'product_model.dart';

class OrderItemModel {
  final String id;
  final String orderId;
  final String productId;
  final int amount;
  final double priceAtOrder;
  final ProductModel product;

  OrderItemModel({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.amount,
    required this.priceAtOrder,
    required this.product,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['id'],
      orderId: json['orderId'],
      productId: json['productId'],
      amount: json['amount'],
      priceAtOrder: (json['priceAtOrder'] as num).toDouble(),
      product: ProductModel.fromJson(json['product']),
    );
  }

  OrderItem toEntity() {
    return OrderItem(
      id: id,
      orderId: orderId,
      productId: productId,
      amount: amount,
      priceAtOrder: priceAtOrder,
      product: product.toEntity(),
    );
  }
}