// features/insight/presentation/screens/market_screen.dart
import 'package:agrilink/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:agrilink/features/auth/presentation/bloc/auth_state.dart';
import 'package:agrilink/features/insight/presentation/bloc/market_event.dart';
import 'package:agrilink/features/insight/presentation/bloc/market_state.dart';
import 'package:agrilink/features/insight/presentation/screens/submit_price_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agrilink/features/insight/presentation/bloc/market_bloc.dart';
import '../../data/model/market_insight.dart';
import 'market_price_card.dart';

class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _loadInitialData() {
    final authState = context.read<AuthBloc>().state;

    if (authState is AuthSuccess) {
      final userRole = authState.authResponse.user.role;

      // For ADMIN, AGENT - show all market prices
      if (userRole == 'ADMIN' || userRole == 'AGENT') {
        context.read<MarketBloc>().add(GetAllMarketPricesEvent());
      }
      // For DATA_CONTRIBUTOR - show their own submissions
      else if (userRole == 'DATA_CONTRIBUTOR') {
        context.read<MarketBloc>().add(GetMyMarketPricesEvent());
      }
      // For BUYER/FARMER - show only approved market prices
      else {
        context.read<MarketBloc>().add(GetApprovedMarketPricesEvent());
      }
    } else {
      // Not logged in - show only approved prices
      context.read<MarketBloc>().add(GetApprovedMarketPricesEvent());
    }
  }

  void _refreshData() {
    final authState = context.read<AuthBloc>().state;

    if (authState is AuthSuccess) {
      final userRole = authState.authResponse.user.role;
      if (userRole == 'ADMIN' || userRole == 'AGENT') {
        context.read<MarketBloc>().add(GetAllMarketPricesEvent());
      } else if (userRole == 'DATA_CONTRIBUTOR') {
        context.read<MarketBloc>().add(GetMyMarketPricesEvent());
      } else {
        context.read<MarketBloc>().add(GetApprovedMarketPricesEvent());
      }
    } else {
      context.read<MarketBloc>().add(GetApprovedMarketPricesEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final userRole = authState is AuthSuccess
        ? authState.authResponse.user.role
        : 'GUEST';

    final isAdminOrAgent = userRole == 'ADMIN' || userRole == 'AGENT';
    final isContributor = userRole == 'DATA_CONTRIBUTOR';
    final isFarmerOrBuyer =
        userRole == 'FARMER' || userRole == 'BUYER' || userRole == 'GUEST';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Market Prices'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _refreshData),
        ],
      ),
      body: _buildBody(isAdminOrAgent, isContributor, isFarmerOrBuyer),
      floatingActionButton: isContributor
          ? FloatingActionButton(
              onPressed: _navigateToSubmitPrice,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildBody(
    bool isAdminOrAgent,
    bool isContributor,
    bool isFarmerOrBuyer,
  ) {
    // For FARMER/BUYER/GUEST - Show only approved market prices (no tabs)
    if (isFarmerOrBuyer) {
      return _buildApprovedPricesView();
    }

    // For DATA_CONTRIBUTOR - Show only their submissions (no tabs, just one view)
    if (isContributor) {
      return _buildMySubmissionsView();
    }

    // For ADMIN/AGENT - Show tabbed view
    if (isAdminOrAgent) {
      return DefaultTabController(
        length: 2,
        child: Column(
          children: [
            const TabBar(
              tabs: [
                Tab(text: 'All Prices'),
                Tab(text: 'Pending Approvals'),
              ],
              isScrollable: true,
              labelColor: Colors.green,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.green,
            ),
            Expanded(
              child: TabBarView(
                children: [_buildAllPricesTab(), _buildPendingApprovalsTab()],
              ),
            ),
          ],
        ),
      );
    }

    return _buildApprovedPricesView();
  }

  Widget _buildApprovedPricesView() {
    return BlocBuilder<MarketBloc, MarketState>(
      builder: (context, state) {
        if (state is MarketLoading) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading market prices...'),
              ],
            ),
          );
        } else if (state is MarketPricesLoaded) {
          if (state.marketPrices.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.attach_money, size: 64, color: Colors.green),
                  SizedBox(height: 16),
                  Text('No approved market prices yet'),
                  SizedBox(height: 8),
                  Text('Check back later for market prices'),
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
                showStatus: false,
                onTap: () => _showPriceDetails(price, showStatus: false),
              );
            },
          );
        } else if (state is MarketError) {
          return _buildErrorState(
            state.message,
            GetApprovedMarketPricesEvent(),
          );
        }
        return const Center(child: Text('No data available'));
      },
    );
  }

  Widget _buildAllPricesTab() {
    return BlocBuilder<MarketBloc, MarketState>(
      builder: (context, state) {
        if (state is MarketLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is MarketPricesLoaded) {
          if (state.marketPrices.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.attach_money, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No market prices available'),
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
                onTap: () => _showPriceDetails(price, showStatus: true),
              );
            },
          );
        } else if (state is MarketError) {
          return _buildErrorState(state.message, GetAllMarketPricesEvent());
        }
        return const Center(child: Text('No data available'));
      },
    );
  }

  Widget _buildPendingApprovalsTab() {
    return BlocBuilder<MarketBloc, MarketState>(
      builder: (context, state) {
        if (state is MarketLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is MarketPricesLoaded) {
          final pendingPrices = state.marketPrices
              .where((price) => price.status.toUpperCase() == 'PENDING')
              .toList();

          if (pendingPrices.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, size: 64, color: Colors.green),
                  SizedBox(height: 16),
                  Text('No pending approvals'),
                  SizedBox(height: 8),
                  Text('All market prices have been reviewed'),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: pendingPrices.length,
            itemBuilder: (context, index) {
              final price = pendingPrices[index];
              return MarketPriceCard(
                marketPrice: price,
                showStatus: true,
                onTap: () => _showPriceDetails(
                  price,
                  showStatus: true,
                  showActions: true,
                ),
              );
            },
          );
        } else if (state is MarketError) {
          return _buildErrorState(state.message, GetAllMarketPricesEvent());
        }
        return const Center(child: Text('No data available'));
      },
    );
  }

  Widget _buildMySubmissionsView() {
    return BlocBuilder<MarketBloc, MarketState>(
      builder: (context, state) {
        if (state is MarketLoading) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading your submissions...'),
              ],
            ),
          );
        } else if (state is MarketPricesLoaded) {
          if (state.marketPrices.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No submissions yet'),
                  SizedBox(height: 8),
                  Text('Submit your first market price using the + button'),
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
                onTap: () => _showPriceDetails(price, showStatus: true),
              );
            },
          );
        } else if (state is MarketError) {
          return _buildErrorState(state.message, GetMyMarketPricesEvent());
        }
        return const Center(child: Text('No data available'));
      },
    );
  }

  Widget _buildErrorState(String message, dynamic event) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
          const SizedBox(height: 16),
          Text('Error: $message', textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.read<MarketBloc>().add(event),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _navigateToSubmitPrice() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SubmitPriceScreen()),
    ).then((_) => _refreshData());
  }

  void _showPriceDetails(
    MarketPriceResponse price, {
    required bool showStatus,
    bool showActions = false,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Price Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Product', price.product?.name ?? 'N/A'),
            _buildDetailRow('Price', '${price.price} ETB'),
            _buildDetailRow('Woreda', price.woreda?.name ?? 'N/A'),
            _buildDetailRow('Date', price.date.split('T')[0]),
            if (showStatus) _buildDetailRow('Status', price.status),
            _buildDetailRow('Submitted By', price.user?.email ?? 'N/A'),
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
          if (showActions && price.status.toUpperCase() == 'PENDING') ...[
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: () async {
                Navigator.pop(context);
                // Show loading indicator
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) =>
                      const Center(child: CircularProgressIndicator()),
                );

                // Call approve event
                context.read<MarketBloc>().add(
                  ApproveMarketPriceEvent(price.id),
                );

                // Wait for state change
                await Future.delayed(const Duration(milliseconds: 500));

                // Close loading dialog
                if (context.mounted) Navigator.pop(context);

                // Show success message
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Price approved successfully!'),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }

                // Refresh data
                _refreshData();
              },
              child: const Text('Approve'),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                Navigator.pop(context);
                // Show loading indicator
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) =>
                      const Center(child: CircularProgressIndicator()),
                );

                // Call reject event
                context.read<MarketBloc>().add(
                  RejectMarketPriceEvent(price.id),
                );

                // Wait for state change
                await Future.delayed(const Duration(milliseconds: 500));

                // Close loading dialog
                if (context.mounted) Navigator.pop(context);

                // Show success message
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Price rejected successfully!'),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }

                // Refresh data
                _refreshData();
              },
              child: const Text('Reject'),
            ),
          ],
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
