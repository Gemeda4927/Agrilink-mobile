// features/insight/presentation/widgets/market_price_card.dart
import 'package:flutter/material.dart';
import 'package:agrilink/features/insight/data/model/market_insight.dart';

class MarketPriceCard extends StatelessWidget {
  final MarketPriceResponse marketPrice;
  final bool showStatus;
  final VoidCallback onTap;

  const MarketPriceCard({
    super.key,
    required this.marketPrice,
    this.showStatus = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        onTap: onTap,
        leading: _buildLeadingIcon(),
        title: Text(
          marketPrice.product?.name ?? 'Unknown Product',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: _buildSubtitle(),
        trailing: _buildTrailing(),
      ),
    );
  }

  Widget _buildLeadingIcon() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.currency_bitcoin, color: Colors.green),
    );
  }

  Widget _buildSubtitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Price: ${marketPrice.price} ETB'),
        if (showStatus) ...[
          const SizedBox(height: 4),
          _buildStatusChip(),
        ],
      ],
    );
  }

  Widget _buildStatusChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: _getStatusColor(marketPrice.status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        marketPrice.status,
        style: TextStyle(
          color: _getStatusColor(marketPrice.status),
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildTrailing() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          marketPrice.date.split('T')[0],
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        if (marketPrice.woreda != null) ...[
          const SizedBox(height: 4),
          Text(
            marketPrice.woreda!.name,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'APPROVED':
        return Colors.green;
      case 'PENDING':
        return Colors.orange;
      case 'REJECTED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}