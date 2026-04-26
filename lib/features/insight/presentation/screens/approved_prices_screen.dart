import 'package:agrilink/features/insight/data/model/market_insight.dart';
import 'package:agrilink/features/insight/presentation/bloc/market_event.dart';
import 'package:agrilink/features/insight/presentation/bloc/market_state.dart';
import 'package:agrilink/features/insight/presentation/screens/market_price_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agrilink/features/insight/presentation/bloc/market_bloc.dart';
import 'package:intl/intl.dart';

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
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 2,
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
            final approvedPrices = state.marketPrices
                .where((price) => price.isApproved)
                .toList();

            if (approvedPrices.isEmpty) {
              return _buildEmptyState();
            }
            return ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: approvedPrices.length,
              itemBuilder: (context, index) {
                final price = approvedPrices[index];
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_circle,
              size: 64,
              color: Colors.green.shade400,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No approved prices yet',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Submitted prices will appear here once approved',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.shade400,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Error loading prices',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadApprovedPrices,
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPriceDetails(MarketPriceResponse price) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) => SingleChildScrollView(
            controller: scrollController,
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),
                const Center(
                  child: Text(
                    'Approved Price Details',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailCard(
                        icon: Icons.production_quantity_limits,
                        label: 'Product',
                        value: price.product?.name ?? 'N/A',
                        color: Colors.green,
                      ),
                      const SizedBox(height: 12),
                      _buildDetailCard(
                        icon: Icons.attach_money,
                        label: 'Price',
                        value: '${price.price.toStringAsFixed(0)} ETB',
                        color: Colors.blue,
                      ),
                      const SizedBox(height: 12),
                      _buildDetailCard(
                        icon: Icons.location_city,
                        label: 'Woreda',
                        value: price.woreda?.name ?? 'N/A',
                        color: Colors.orange,
                      ),
                      const SizedBox(height: 12),
                      _buildDetailCard(
                        icon: Icons.calendar_today,
                        label: 'Date',
                        value: _formatDate(price.date),
                        color: Colors.purple,
                      ),
                      const SizedBox(height: 12),
                      _buildDetailCard(
                        icon: Icons.verified,
                        label: 'Status',
                        value: price.status,
                        color: Colors.green,
                      ),
                      const SizedBox(height: 12),
                      _buildDetailCard(
                        icon: Icons.map,
                        label: 'Location',
                        value: '${price.latitude}, ${price.longitude}',
                        color: Colors.teal,
                      ),
                      const SizedBox(height: 12),
                      if (price.user != null)
                        _buildDetailCard(
                          icon: Icons.person,
                          label: 'Submitted By',
                          value: price.user?.email?.split('@')[0] ?? 'Unknown',
                          color: Colors.indigo,
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Close',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }
}
