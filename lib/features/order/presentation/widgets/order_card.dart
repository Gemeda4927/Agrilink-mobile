// lib/features/order/presentation/widgets/order_card.dart

import 'package:flutter/material.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/product.dart';
import '../screens/order_details_screen.dart';
import '../bloc/order_bloc.dart';
import '../bloc/order_event.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OrderCard extends StatelessWidget {
  final Order order;
  final bool isFarmerView;
  final VoidCallback? onTap;

  const OrderCard({
    Key? key,
    required this.order,
    this.isFarmerView = false,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade100,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Left side - Order info
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            isFarmerView ? Icons.store_rounded : Icons.receipt_long_rounded,
                            size: 18,
                            color: Colors.green.shade700,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isFarmerView
                                    ? 'Order #${order.id.substring(0, order.id.length > 8 ? 8 : order.id.length).toUpperCase()}'
                                    : 'Order #${order.id.substring(0, order.id.length > 8 ? 8 : order.id.length).toUpperCase()}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today_rounded,
                                    size: 11,
                                    color: Colors.grey.shade500,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      order.formattedDate,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey.shade600,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              if (isFarmerView && order.buyerName != null) ...[
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.person_outline_rounded,
                                      size: 11,
                                      color: Colors.grey.shade500,
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        order.buyerDisplayName,
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey.shade600,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Status Badge
                  _buildStatusBadge(order.status),
                ],
              ),
            ),

            // Items List
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  ...order.items
                      .take(2)
                      .map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Product Image
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: _buildProductImage(item.product),
                              ),
                              const SizedBox(width: 12),
                              // Product Details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.product.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${item.amount} x ${item.priceAtOrder.toStringAsFixed(0)} ETB',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Price
                              SizedBox(
                                width: 65,
                                child: Text(
                                  '${(item.amount * item.priceAtOrder).toStringAsFixed(0)} ETB',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                    color: Colors.green.shade700,
                                  ),
                                  textAlign: TextAlign.right,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  if (order.items.length > 2)
                    Padding(
                      padding: const EdgeInsets.only(top: 4, bottom: 8),
                      child: Text(
                        '+${order.items.length - 2} more items',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const Divider(height: 1, color: Colors.grey),

            // Footer
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Total Amount
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isFarmerView ? 'Total Amount' : 'Total Amount',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          order.formattedTotalAmount,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade700,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Action Buttons
                  _buildActionButtons(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductImage(Product product) {
    if (product.hasImage) {
      return Image.network(
        product.imageUrl,
        width: 45,
        height: 45,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 45,
            height: 45,
            color: Colors.grey.shade200,
            child: Icon(
              Icons.image_not_supported_rounded,
              size: 20,
              color: Colors.grey.shade400,
            ),
          );
        },
      );
    } else {
      return Container(
        width: 45,
        height: 45,
        color: Colors.grey.shade200,
        child: Icon(
          Icons.image_not_supported_rounded,
          size: 20,
          color: Colors.grey.shade400,
        ),
      );
    }
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String label;

    switch (status) {
      case 'PAID':
        color = Colors.green;
        label = 'Paid';
        break;
      case 'PENDING':
        color = Colors.orange;
        label = 'Pending';
        break;
      case 'FAILED':
        color = Colors.red;
        label = 'Failed';
        break;
      case 'CANCELLED':
        color = Colors.grey;
        label = 'Cancelled';
        break;
      case 'APPROVED':
        color = Colors.green;
        label = 'Approved';
        break;
      case 'REJECTED':
        color = Colors.red;
        label = 'Rejected';
        break;
      case 'DELIVERED':
        color = Colors.teal;
        label = 'Delivered';
        break;
      case 'COMPLETED':
        color = Colors.green;
        label = 'Completed';
        break;
      default:
        color = Colors.blue;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    if (isFarmerView) {
      // Farmer View Actions
      if (order.status == 'PAID') {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildActionButton(
              context: context,
              onTap: () => _showRejectDialog(context),
              icon: Icons.close_rounded,
              label: 'Reject',
              color: Colors.red,
            ),
            const SizedBox(width: 8),
            _buildActionButton(
              context: context,
              onTap: () => _acceptOrder(context),
              icon: Icons.check_rounded,
              label: 'Accept',
              color: Colors.green,
              backgroundColor: Colors.green,
              textColor: Colors.white,
            ),
          ],
        );
      } else if (order.status == 'APPROVED') {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildActionButton(
              context: context,
              onTap: () => _markAsDelivered(context),
              icon: Icons.local_shipping_rounded,
              label: 'Deliver',
              color: Colors.teal,
            ),
          ],
        );
      } else if (order.status == 'DELIVERED') {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildActionButton(
              context: context,
              onTap: () => _viewDetails(context),
              icon: Icons.visibility_rounded,
              label: 'View',
              color: Colors.blue,
            ),
          ],
        );
      }
    } else {
      // Buyer View Actions
      if (order.status == 'PAID') {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildActionButton(
              context: context,
              onTap: () => _showCancelDialog(context),
              icon: Icons.cancel_rounded,
              label: 'Cancel',
              color: Colors.red,
            ),
            const SizedBox(width: 8),
            _buildActionButton(
              context: context,
              onTap: () => _viewDetails(context),
              icon: Icons.visibility_rounded,
              label: 'Track',
              color: Colors.blue,
            ),
          ],
        );
      } else if (order.status == 'PENDING') {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildActionButton(
              context: context,
              onTap: () => _showCancelDialog(context),
              icon: Icons.cancel_rounded,
              label: 'Cancel',
              color: Colors.red,
            ),
            const SizedBox(width: 8),
            _buildActionButton(
              context: context,
              onTap: () => _makePayment(context),
              icon: Icons.payment_rounded,
              label: 'Pay',
              color: Colors.orange,
              backgroundColor: Colors.orange,
              textColor: Colors.white,
            ),
          ],
        );
      } else if (order.status == 'DELIVERED') {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildActionButton(
              context: context,
              onTap: () => _completeOrder(context),
              icon: Icons.done_all_rounded,
              label: 'Complete',
              color: Colors.green,
            ),
            const SizedBox(width: 8),
            _buildActionButton(
              context: context,
              onTap: () => _viewDetails(context),
              icon: Icons.visibility_rounded,
              label: 'View',
              color: Colors.blue,
            ),
          ],
        );
      } else if (order.status == 'COMPLETED') {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildActionButton(
              context: context,
              onTap: () => _viewDetails(context),
              icon: Icons.visibility_rounded,
              label: 'View',
              color: Colors.blue,
            ),
            const SizedBox(width: 8),
            _buildActionButton(
              context: context,
              onTap: () => _writeReview(context),
              icon: Icons.rate_review_rounded,
              label: 'Review',
              color: Colors.amber,
            ),
          ],
        );
      }
    }
    
    // Default: just view details
    return _buildActionButton(
      context: context,
      onTap: () => _viewDetails(context),
      icon: Icons.visibility_rounded,
      label: 'View',
      color: Colors.blue,
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required VoidCallback onTap,
    required IconData icon,
    required String label,
    required Color color,
    Color? backgroundColor,
    Color? textColor,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: backgroundColor ?? color.withOpacity(0.1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: textColor ?? color),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: textColor ?? color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= FARMER ACTIONS =================

  void _acceptOrder(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Accept Order'),
        content: const Text('Are you sure you want to accept this order?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<OrderBloc>().add(AcceptOrderEvent(orderId: order.id));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Order accepted successfully'),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 2),
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.green),
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(BuildContext context) {
    final TextEditingController reasonController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Reject Order'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Are you sure you want to reject this order?'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: InputDecoration(
                hintText: 'Reason (optional)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<OrderBloc>().add(
                RejectOrderEvent(
                  orderId: order.id,
                  reason: reasonController.text.isEmpty ? null : reasonController.text,
                ),
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Order rejected'),
                  backgroundColor: Colors.red,
                  duration: Duration(seconds: 2),
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Yes, Reject'),
          ),
        ],
      ),
    );
  }

  void _markAsDelivered(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Mark as Delivered'),
        content: const Text('Confirm that this order has been delivered to the customer?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<OrderBloc>().add(MarkAsDeliveredEvent(orderId: order.id));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Order marked as delivered'),
                  backgroundColor: Colors.teal,
                  duration: Duration(seconds: 2),
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.teal),
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }

  // ================= BUYER ACTIONS =================

  void _showCancelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Cancel Order'),
        content: const Text('Are you sure you want to cancel this order?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<OrderBloc>().add(CancelOrderEvent(orderId: order.id));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Order cancelled'),
                  backgroundColor: Colors.red,
                  duration: Duration(seconds: 2),
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }

  void _makePayment(BuildContext context) {
    // Navigate to payment screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Payment integration coming soon'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _completeOrder(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Complete Order'),
        content: const Text('Have you received your order? Confirm completion.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Not Yet'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<OrderBloc>().add(CompleteOrderEvent(orderId: order.id));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Order completed! Thank you'),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 2),
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.green),
            child: const Text('Yes, Complete'),
          ),
        ],
      ),
    );
  }

  void _writeReview(BuildContext context) {
    // Navigate to review screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Review feature coming soon'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _viewDetails(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderDetailsScreen(
          order: order,
          isFarmerView: isFarmerView,
        ),
      ),
    );
  }
}