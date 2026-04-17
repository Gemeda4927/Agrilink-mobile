// lib/features/order/presentation/widgets/farmer_order_card.dart

import 'package:agrilink/features/my_product/domain/entities/farmer_order.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class FarmerOrderCard extends StatelessWidget {
  final FarmerOrder order;
  final VoidCallback? onTap;

  const FarmerOrderCard({super.key, required this.order, this.onTap});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with gradient background
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      order.statusColor.withOpacity(0.08),
                      Colors.white,
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    // Order Icon with gradient background
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            order.statusColor,
                            order.statusColor.withOpacity(0.7),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        Icons.receipt_long_rounded,
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Order #${order.id.substring(0, order.id.length > 8 ? 8 : order.id.length).toUpperCase()}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.access_time_rounded,
                                  size: 12, color: Colors.grey[500]),
                              const SizedBox(width: 4),
                              Text(
                                order.formattedDate,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: order.statusColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: order.statusColor.withOpacity(0.3),
                          width: 0.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            order.statusIcon,
                            size: 14,
                            color: order.statusColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            order.statusText,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: order.statusColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Buyer Info Card
              Padding(
                padding: const EdgeInsets.all(12),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.grey.shade50,
                        Colors.grey.shade100.withOpacity(0.5),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.grey.shade200,
                      width: 0.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      // Buyer Avatar with border
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: order.statusColor,
                            width: 2,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                          child: order.buyer.hasImage
                              ? CachedNetworkImage(
                                  imageUrl: order.buyer.imageUrl!,
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(
                                    width: 50,
                                    height: 50,
                                    color: Colors.grey[200],
                                    child: const Icon(Icons.person,
                                        size: 25, color: Colors.grey),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      Container(
                                        width: 50,
                                        height: 50,
                                        color: Colors.grey[200],
                                        child: const Icon(Icons.person,
                                            size: 25, color: Colors.grey),
                                      ),
                                )
                              : Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.person,
                                      size: 25, color: Colors.grey),
                                ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              order.buyer.displayName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.email_outlined,
                                    size: 12, color: Colors.grey[500]),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    order.buyer.email,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey[600],
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            if (order.buyer.location != null) ...[
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Icon(Icons.location_on_outlined,
                                      size: 12, color: Colors.grey[500]),
                                  const SizedBox(width: 4),
                                  Text(
                                    order.buyer.location!,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey[500],
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
              ),

              // Products Section Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    Icon(Icons.shopping_bag_outlined,
                        size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 6),
                    Text(
                      'Order Items',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${order.items.length} ${order.items.length == 1 ? 'item' : 'items'}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Products Preview
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  children: order.items.take(2).map((item) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          // Product Image with shadow
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: item.product.hasImage
                                  ? CachedNetworkImage(
                                      imageUrl: item.product.imageUrl,
                                      width: 48,
                                      height: 48,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => Container(
                                        width: 48,
                                        height: 48,
                                        color: Colors.grey[200],
                                        child: const Icon(Icons.image,
                                            size: 24, color: Colors.grey),
                                      ),
                                      errorWidget: (context, url, error) =>
                                          Container(
                                            width: 48,
                                            height: 48,
                                            color: Colors.grey[200],
                                            child: const Icon(Icons.image,
                                                size: 24, color: Colors.grey),
                                          ),
                                    )
                                  : Container(
                                      width: 48,
                                      height: 48,
                                      color: Colors.grey[200],
                                      child: const Icon(Icons.image,
                                          size: 24, color: Colors.grey),
                                    ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.product.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.orange.shade100,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        '${item.amount} x ${item.priceAtOrder} ETB',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.orange.shade800,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${item.subtotal} ETB',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: Colors.green.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),

              if (order.items.length > 2)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: Row(
                    children: [
                      Icon(Icons.more_horiz, size: 16, color: Colors.grey[500]),
                      const SizedBox(width: 4),
                      Text(
                        '+${order.items.length - 2} more item${order.items.length - 2 > 1 ? 's' : ''}',
                        style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ),

              const Divider(height: 24, thickness: 1),

              // Footer with Total Amount
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.green.shade50,
                        Colors.green.shade100.withOpacity(0.3),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.attach_money_rounded,
                              size: 20, color: Colors.green.shade700),
                          const SizedBox(width: 4),
                          Text(
                            'Total Amount',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                      Text(
                        order.formattedTotalAmount,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}