import 'package:agrilink/features/insight/data/model/market_insight.dart';
import 'package:agrilink/features/insight/presentation/bloc/market_event.dart';
import 'package:agrilink/features/insight/presentation/bloc/market_state.dart';
import 'package:agrilink/features/insight/presentation/screens/market_price_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agrilink/features/insight/presentation/bloc/market_bloc.dart';

class ApprovedPricesScreen extends StatefulWidget {
  const ApprovedPricesScreen({super.key});

  @override
  State<ApprovedPricesScreen> createState() => _ApprovedPricesScreenState();
}

class _ApprovedPricesScreenState extends State<ApprovedPricesScreen> {
  @override
  void initState() {
    super.initState();
    _loadApprovedPrices();
  }

  void _loadApprovedPrices() {
    context.read<MarketBloc>().add(GetApprovedMarketPricesEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Approved Market Prices'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadApprovedPrices,
          ),
        ],
      ),
      body: BlocBuilder<MarketBloc, MarketState>(
        builder: (context, state) {
          if (state is MarketLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is MarketPricesLoaded) {
            if (state.marketPrices.isEmpty) {
              return _buildEmptyState();
            }
            return ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: state.marketPrices.length,
              itemBuilder: (context, index) {
                final price = state.marketPrices[index];
                return MarketPriceCard(
                  marketPrice: price,
                  showStatus: true,
                  onTap: () => _showPriceDetails(price),
                );
              },
            );
          } else if (state is MarketError) {
            return _buildErrorState(state.message);
          }
          return const Center(child: Text('No data available'));
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle, size: 64, color: Colors.green),
          SizedBox(height: 16),
          Text('No approved prices yet'),
          SizedBox(height: 8),
          Text('Submitted prices will appear here once approved'),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Error: $message'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadApprovedPrices,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _showPriceDetails(MarketPriceResponse price) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Approved Price Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Product', price.product?.name ?? 'N/A'),
            _buildDetailRow('Price', '${price.price} ETB'),
            _buildDetailRow('Woreda', price.woreda?.name ?? 'N/A'),
            _buildDetailRow('Date', price.date.split('T')[0]),
            _buildDetailRow('Status', price.status),
            _buildDetailRow(
              'Location',
              '${price.latitude}, ${price.longitude}',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(value),
        ],
      ),
    );
  }
}
