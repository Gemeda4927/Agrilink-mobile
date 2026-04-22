import 'package:agrilink/features/insight/presentation/bloc/market_event.dart';
import 'package:agrilink/features/insight/presentation/bloc/market_state.dart';
import 'package:agrilink/features/insight/presentation/screens/market_price_card.dart';
import 'package:agrilink/features/insight/presentation/screens/submit_price_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agrilink/features/insight/presentation/bloc/market_bloc.dart';

import '../../data/model/market_insight.dart';
import 'product_card.dart';

class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadInitialData();
  }

  void _loadInitialData() {
    context.read<MarketBloc>().add(GetAllProductsEvent());
    context.read<MarketBloc>().add(GetAllMarketPricesEvent());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Market Insights'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Products'),
            Tab(text: 'Market Prices'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadInitialData,
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildProductsTab(), _buildMarketPricesTab()],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SubmitPriceScreen()),
          ).then((_) => _loadInitialData());
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildProductsTab() {
    return BlocBuilder<MarketBloc, MarketState>(
      builder: (context, state) {
        if (state is MarketLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is ProductsLoaded) {
          if (state.productsResponse.products.isEmpty) {
            return const Center(child: Text('No products found'));
          }
          return GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.8,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: state.productsResponse.products.length,
            itemBuilder: (context, index) {
              final product = state.productsResponse.products[index];
              return ProductCard(
                product: product,
                onTap: () {
                  _showProductDetails(product);
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
                    context.read<MarketBloc>().add(GetAllProductsEvent());
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }
        return const Center(child: Text('No data available'));
      },
    );
  }

  Widget _buildMarketPricesTab() {
    return BlocBuilder<MarketBloc, MarketState>(
      builder: (context, state) {
        if (state is MarketLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is MarketPricesLoaded) {
          if (state.marketPrices.isEmpty) {
            return const Center(child: Text('No market prices available'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: state.marketPrices.length,
            itemBuilder: (context, index) {
              final price = state.marketPrices[index];
              return MarketPriceCard(
                marketPrice: price,
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
                    context.read<MarketBloc>().add(GetAllMarketPricesEvent());
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }
        return const Center(child: Text('No data available'));
      },
    );
  }

  void _showProductDetails(Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(product.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ID: ${product.id}'),
            const SizedBox(height: 8),
            const Text('Want to submit price for this product?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      SubmitPriceScreen(preSelectedProduct: product),
                ),
              ).then((_) => _loadInitialData());
            },
            child: const Text('Submit Price'),
          ),
        ],
      ),
    );
  }

  void _showPriceDetails(MarketPriceResponse price) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Price Details'),
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
