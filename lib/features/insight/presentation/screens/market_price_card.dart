// features/insight/presentation/screens/market_price_card.dart
import 'package:flutter/material.dart';
import '../../data/model/market_insight.dart';

class MarketPriceCard extends StatelessWidget {
  final MarketPriceResponse marketPrice;
  final bool showStatus;
  final VoidCallback? onTap;
  final Map<String, dynamic>? trendData;

  const MarketPriceCard({
    super.key,
    required this.marketPrice,
    this.showStatus = false,
    this.onTap,
    this.trendData,
  });

  @override
  Widget build(BuildContext context) {
    // Extract trend data if available
    final trend = trendData?['trend'] as String? ?? 'neutral';
    final percentage = trendData?['percentage'] as double? ?? 0.0;
    final change = trendData?['change'] as double? ?? 0.0;

    Color trendColor = Colors.grey;
    IconData trendIcon = Icons.remove;

    if (trend == 'up') {
      trendColor = Colors.green;
      trendIcon = Icons.trending_up_rounded;
    } else if (trend == 'down') {
      trendColor = Colors.red;
      trendIcon = Icons.trending_down_rounded;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: trend == 'up'
              ? Colors.green.withOpacity(0.2)
              : trend == 'down'
              ? Colors.red.withOpacity(0.2)
              : Colors.transparent,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Product Icon with gradient
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.green.shade400, Colors.green.shade600],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.grass_outlined,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),

                // Product Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        marketPrice.product?.name ?? 'Unknown Product',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Location and Date Row
                      Wrap(
                        spacing: 12,
                        runSpacing: 4,
                        children: [
                          _buildInfoChip(
                            icon: Icons.location_on_outlined,
                            label: marketPrice.woreda?.name ?? 'N/A',
                          ),
                          _buildInfoChip(
                            icon: Icons.calendar_today_outlined,
                            label: _formatDate(marketPrice.date as String),
                          ),
                        ],
                      ),

                      // Status Badge
                      if (showStatus) ...[
                        const SizedBox(height: 8),
                        _buildStatusChip(marketPrice.status),
                      ],
                    ],
                  ),
                ),

                // Price and Trend Column
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Current Price
                    Text(
                      '${marketPrice.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'ETB',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade600,
                      ),
                    ),

                    // Trend Indicator
                    if (trend != 'neutral') ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: trendColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: trendColor.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(trendIcon, size: 16, color: trendColor),
                            const SizedBox(width: 4),
                            Text(
                              '${percentage.toStringAsFixed(1)}%',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: trendColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip({required IconData icon, required String label}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey.shade600),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(String status) {
    Color bgColor;
    Color textColor;
    IconData icon;

    switch (status.toUpperCase()) {
      case 'APPROVED':
        bgColor = Colors.green.shade50;
        textColor = Colors.green.shade700;
        icon = Icons.check_circle_outline;
        break;
      case 'PENDING':
        bgColor = Colors.orange.shade50;
        textColor = Colors.orange.shade700;
        icon = Icons.pending_outlined;
        break;
      case 'REJECTED':
        bgColor = Colors.red.shade50;
        textColor = Colors.red.shade700;
        icon = Icons.cancel_outlined;
        break;
      default:
        bgColor = Colors.grey.shade50;
        textColor = Colors.grey.shade700;
        icon = Icons.help_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: textColor.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 6),
          Text(
            status.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: textColor,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        return 'Today';
      } else if (difference.inDays == 1) {
        return 'Yesterday';
      } else if (difference.inDays < 7) {
        return '${difference.inDays}d ago';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      return dateStr.split('T')[0];
    }
  }
}
