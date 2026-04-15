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
  
  String get formattedTotalAmount => '${totalAmount.toStringAsFixed(0)} $currency';
  String get formattedDate => _formatDate(createdAt);
  
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
  }
}