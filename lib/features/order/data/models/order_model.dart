import '../../domain/entities/order.dart';
import 'order_item_model.dart';

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
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'],
      buyerId: json['buyerId'],
      totalAmount: (json['totalAmount'] as num).toDouble(),
      txRef: json['tx_ref'],
      status: json['status'],
      paymentId: json['paymentId'],
      paymentUrl: json['paymentUrl'],
      currency: json['currency'],
      createdAt: DateTime.parse(json['createdAt']),
      items: (json['items'] as List)
          .map((item) => OrderItemModel.fromJson(item))
          .toList(),
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
    );
  }
}
