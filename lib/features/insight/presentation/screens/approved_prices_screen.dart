// features/insight/presentation/screens/approved_prices_screen.dart
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
            onPressed: () {
              context.read<MarketBloc>().add(GetApprovedMarketPricesEvent());
            },
          ),
        ],
      ),
      body: BlocBuilder<MarketBloc, MarketState>(
        builder: (context, state) {
          if (state is MarketLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is MarketPricesLoaded) {
            if (state.marketPrices.isEmpty) {
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
            return ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: state.marketPrices.length,
              itemBuilder: (context, index) {
                final price = state.marketPrices[index];
                return MarketPriceCard(
                  marketPrice: price,
                  showStatus: true,
                  onTap: () {
                    _showPriceDetails(price);
                  },
                );
              },
            );
          } else if (state is MarketError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${state.message}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<MarketBloc>().add(
                        GetApprovedMarketPricesEvent(),
                      );
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          return const Center(child: Text('No data available'));
        },
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
            Text('Product: ${price.product?.name ?? 'N/A'}'),
            const SizedBox(height: 8),
            Text('Price: ${price.price} ETB'),
            const SizedBox(height: 8),
            Text('Woreda: ${price.woreda?.name ?? 'N/A'}'),
            const SizedBox(height: 8),
            Text('Date: ${price.date.split('T')[0]}'),
            const SizedBox(height: 8),
            Text('Status: ${price.status}'),
            const SizedBox(height: 8),
            Text('Location: ${price.latitude}, ${price.longitude}'),
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
}
