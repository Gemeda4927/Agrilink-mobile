import 'package:flutter/material.dart';
import 'package:agrilink/features/insight/data/model/market_insight.dart';

class ProductCard extends StatelessWidget {
  final MarketPriceResponse marketPrice;
  final bool showApprovedBadge;
  final VoidCallback onTap;
  final bool showTrend;
  final bool isGridView;

  const ProductCard({
    super.key,
    required this.marketPrice,
    this.showApprovedBadge = false,
    required this.onTap,
    this.showTrend = true,
    this.isGridView = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Stack(
        children: [
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: isGridView ? _buildGridContent() : _buildListContent(),
          ),
          // Status Badge (Approved/Pending/Rejected)
          if (showApprovedBadge)
            Positioned(top: 8, right: 8, child: _buildStatusBadge()),
        ],
      ),
    );
  }

  Widget _buildListContent() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          _buildProductIcon(),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProductName(),
                const SizedBox(height: 4),
                _buildLocationAndDate(),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildProductPrice(),
              if (showTrend) const SizedBox(height: 4),
              if (showTrend) _buildTrendIndicator(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGridContent() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildProductIcon(size: 40),
          const SizedBox(height: 12),
          _buildProductName(fontSize: 14),
          const SizedBox(height: 4),
          _buildLocationText(fontSize: 10),
          const SizedBox(height: 8),
          _buildProductPrice(fontSize: 16),
          if (showTrend) ...[const SizedBox(height: 4), _buildTrendIndicator()],
        ],
      ),
    );
  }

  Widget _buildProductIcon({double size = 48}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade400, Colors.green.shade700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(
        _getProductIcon(marketPrice.product?.name ?? ''),
        color: Colors.white,
        size: size * 0.6,
      ),
    );
  }

  Widget _buildProductName({double fontSize = 16}) {
    return Text(
      marketPrice.product?.name ?? 'Unknown Product',
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
      textAlign: TextAlign.center,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildProductPrice({double fontSize = 14}) {
    return Text(
      '${marketPrice.price.toStringAsFixed(0)} ETB',
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF2E7D32),
      ),
    );
  }

  Widget _buildLocationAndDate() {
    return Row(
      children: [
        Icon(Icons.location_on, size: 12, color: Colors.grey.shade500),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            marketPrice.woreda?.name ?? 'N/A',
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
          ),
        ),
        const SizedBox(width: 8),
        Icon(Icons.access_time, size: 12, color: Colors.grey.shade500),
        const SizedBox(width: 4),
        Text(
          _formatTimeAgo(marketPrice.date),
          style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
        ),
      ],
    );
  }

  Widget _buildLocationText({double fontSize = 10}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.location_on, size: fontSize, color: Colors.grey.shade500),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            marketPrice.woreda?.name ?? 'N/A',
            style: TextStyle(fontSize: fontSize, color: Colors.grey.shade600),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge() {
    final status = marketPrice.status.toUpperCase();
    Color bgColor;
    Color textColor;
    IconData icon;
    String label;

    switch (status) {
      case 'APPROVED':
        bgColor = Colors.green;
        textColor = Colors.white;
        icon = Icons.verified;
        label = 'Approved';
        break;
      case 'PENDING':
        bgColor = Colors.orange;
        textColor = Colors.white;
        icon = Icons.pending;
        label = 'Pending';
        break;
      case 'REJECTED':
        bgColor = Colors.red;
        textColor = Colors.white;
        icon = Icons.cancel;
        label = 'Rejected';
        break;
      default:
        bgColor = Colors.grey;
        textColor = Colors.white;
        icon = Icons.info;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: bgColor.withOpacity(0.3), blurRadius: 4)],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: textColor, size: 12),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendIndicator() {
    // For demo - you'll need to calculate actual trend from your data
    // This is a placeholder that shows random trend for visual effect

    // In real implementation, you'd calculate this from historical prices
    // For now, let's show a positive trend for approved items
    final isApproved = marketPrice.isApproved;
    final trend = isApproved ? 'up' : 'neutral';
    final percentage = isApproved ? 2.5 : 0.0;

    if (trend == 'neutral') return const SizedBox();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: trend == 'up'
            ? Colors.green.withOpacity(0.1)
            : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            trend == 'up' ? Icons.trending_up : Icons.trending_down,
            size: 12,
            color: trend == 'up' ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 4),
          Text(
            '${percentage.toStringAsFixed(1)}%',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: trend == 'up' ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimeAgo(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays > 7) return '${diff.inDays ~/ 7}w ago';
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }

  IconData _getProductIcon(String productName) {
    switch (productName.toLowerCase()) {
      case 'teff':
        return Icons.grass;
      case 'wheat':
        return Icons.agriculture;
      case 'coffee':
        return Icons.coffee;
      case 'maize':
        return Icons.earbuds;
      case 'banana':
        return Icons.emoji_food_beverage;
      case 'orange':
        return Icons.circle;
      case 'tomato':
        return Icons.circle;
      case 'onion':
        return Icons.circle;
      case 'potato':
        return Icons.circle;
      default:
        return Icons.production_quantity_limits;
    }
  }
}
