import 'package:agrilink/features/my_product/domain/entities/farmer_order.dart';
import 'package:agrilink/features/my_product/presentation/bloc/farmer_order_bloc.dart';
import 'package:agrilink/features/my_product/presentation/bloc/farmer_order_event.dart';
import 'package:agrilink/features/my_product/presentation/bloc/farmer_order_state.dart';
import 'package:agrilink/features/my_product/presentation/farmer_order_card.dart';
import 'package:agrilink/features/my_product/presentation/farmer_order_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FarmerOrdersScreen extends StatefulWidget {
  const FarmerOrdersScreen({super.key});

  @override
  State<FarmerOrdersScreen> createState() => _FarmerOrdersScreenState();
}

class _FarmerOrdersScreenState extends State<FarmerOrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
    });
  }

  List<FarmerOrder> _filterOrders(List<FarmerOrder> orders) {
    if (_searchQuery.isEmpty) return orders;
    return orders.where((order) {
      return order.id.toLowerCase().contains(_searchQuery) ||
          order.buyer.displayName.toLowerCase().contains(_searchQuery) ||
          order.items.any(
            (item) => item.product.name.toLowerCase().contains(_searchQuery),
          );
    }).toList();
  }

  List<FarmerOrder> _getOrdersByTab(List<FarmerOrder> orders, int tabIndex) {
    switch (tabIndex) {
      case 0:
        return orders;
      case 1:
        return orders.where((o) => o.isPending).toList();
      case 2:
        return orders.where((o) => o.isPaid).toList();
      default:
        return orders;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Orders Received',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(120),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search by order ID, buyer, or product...',
                      prefixIcon: const Icon(Icons.search, color: Colors.green),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                _onSearchChanged();
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ),
              TabBar(
                controller: _tabController,
                indicatorColor: Colors.green,
                labelColor: Colors.green,
                unselectedLabelColor: Colors.grey,
                tabs: const [
                  Tab(text: 'All Orders'),
                  Tab(text: 'Pending'),
                  Tab(text: 'Completed'),
                ],
              ),
            ],
          ),
        ),
      ),
      body: BlocBuilder<FarmerOrderBloc, FarmerOrderState>(
        builder: (context, state) {
          if (state is FarmerOrderLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.green),
                  SizedBox(height: 16),
                  Text('Loading orders...'),
                ],
              ),
            );
          }

          if (state is FarmerOrderError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load orders',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.read<FarmerOrderBloc>().add(
                        RefreshFarmerOrders(),
                      );
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Try Again'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          if (state is FarmerOrderLoaded) {
            final filteredOrders = _filterOrders(state.orders);
            final displayOrders = _getOrdersByTab(
              filteredOrders,
              _tabController.index,
            );

            if (displayOrders.isEmpty) {
              return _buildEmptyState(_tabController.index);
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<FarmerOrderBloc>().add(RefreshFarmerOrders());
              },
              color: Colors.green,
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: displayOrders.length,
                itemBuilder: (context, index) {
                  final order = displayOrders[index];
                  return FarmerOrderCard(
                    order: order,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => FarmerOrderDetailScreen(order: order),
                        ),
                      );
                    },
                  );
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildEmptyState(int tabIndex) {
    String title;
    String message;
    IconData icon;

    switch (tabIndex) {
      case 0:
        title = 'No Orders Yet';
        message =
            'You haven\'t received any orders yet.\nWhen customers order your products, they\'ll appear here.';
        icon = Icons.inbox_outlined;
        break;
      case 1:
        title = 'No Pending Orders';
        message =
            'You don\'t have any pending orders.\nAll orders have been processed.';
        icon = Icons.pending_actions_outlined;
        break;
      case 2:
        title = 'No Completed Orders';
        message =
            'You haven\'t completed any orders yet.\nCompleted orders will appear here.';
        icon = Icons.check_circle_outline;
        break;
      default:
        title = 'No Orders';
        message = 'No orders found';
        icon = Icons.inbox_outlined;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[500]),
            ),
          ),
          const SizedBox(height: 24),
          if (tabIndex != 0)
            ElevatedButton.icon(
              onPressed: () {
                _tabController.animateTo(0);
              },
              icon: const Icon(Icons.arrow_back),
              label: const Text('View All Orders'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
