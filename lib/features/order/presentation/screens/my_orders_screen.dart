
import 'package:agrilink/core/config/routes/route_name.dart';
import 'package:agrilink/features/order/presentation/widgets/order_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/order.dart';
import '../bloc/order_bloc.dart';
import '../bloc/order_event.dart';
import '../bloc/order_state.dart';
import '../widgets/empty_orders_widget.dart';
import 'order_details_screen.dart';

class MyOrdersScreen extends StatefulWidget {
  final bool initialFarmerView;

  const MyOrdersScreen({Key? key, this.initialFarmerView = false})
      : super(key: key);

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  String _selectedFilter = 'All';
  String _selectedSort = 'Newest';
  bool _isFarmerView = false;

  // Pagination variables
  int _itemsPerPage = 5;
  int _currentPage = 1;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _isFarmerView = widget.initialFarmerView;
    _scrollController.addListener(_scrollListener);

    // Load appropriate orders based on view
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isFarmerView) {
        context.read<OrderBloc>().add(GetFarmerOrdersEvent());
      } else {
        context.read<OrderBloc>().add(GetMyOrdersEvent());
      }
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreItems();
    }
  }

  Future<void> _loadMoreItems() async {
    if (_isLoadingMore || !_hasMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      _currentPage++;
      _isLoadingMore = false;

      final state = context.read<OrderBloc>().state;
      if (state is OrdersLoaded || state is FarmerOrdersLoaded) {
        final orders = _getOrdersFromState(state);
        final allOrders = _getFilteredAndSortedOrders(orders);
        final maxItems = _currentPage * _itemsPerPage;
        _hasMore = maxItems < allOrders.length;
      }
    });
  }

  void _resetPagination() {
    setState(() {
      _currentPage = 1;
      _hasMore = true;
      _isLoadingMore = false;
    });
  }

  List<Order> _getOrdersFromState(OrderState state) {
    if (state is OrdersLoaded) {
      return state.orders;
    } else if (state is FarmerOrdersLoaded) {
      return state.orders;
    }
    return [];
  }

  List<Order> _getVisibleOrders(List<Order> filteredOrders) {
    final endIndex = _currentPage * _itemsPerPage;
    return filteredOrders.take(endIndex).toList();
  }

  void _toggleView() {
    setState(() {
      _isFarmerView = !_isFarmerView;
      _resetPagination();
      _selectedFilter = 'All';
      _selectedSort = 'Newest';
    });

    if (_isFarmerView) {
      context.read<OrderBloc>().add(GetFarmerOrdersEvent());
    } else {
      context.read<OrderBloc>().add(GetMyOrdersEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          _isFarmerView ? 'Orders Received' : 'My Orders',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.green),
          onPressed: () {
            context.goNamed(RouteName.home);
          },
        ),
        actions: [
          // Toggle view button
          IconButton(
            icon: Icon(
              _isFarmerView ? Icons.shopping_bag : Icons.store,
              color: Colors.green,
            ),
            tooltip: _isFarmerView
                ? 'Switch to My Orders'
                : 'Switch to Orders Received',
            onPressed: _toggleView,
          ),
          IconButton(
            icon: Badge(
              isLabelVisible: _selectedFilter != 'All',
              backgroundColor: Colors.green,
              child: const Icon(Icons.filter_list_rounded, color: Colors.green),
            ),
            onPressed: () => _showFilterBottomSheet(context),
          ),
          IconButton(
            icon: const Icon(Icons.sort_rounded, color: Colors.green),
            onPressed: () => _showSortBottomSheet(context),
          ),
        ],
      ),
      body: BlocBuilder<OrderBloc, OrderState>(
        builder: (context, state) {
          if (state is OrderInitial) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
              ),
            );
          }

          if (state is OrderLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
              ),
            );
          }

          if (state is OrdersLoaded && !_isFarmerView) {
            return _buildOrderList(state.orders);
          }

          if (state is FarmerOrdersLoaded && _isFarmerView) {
            return _buildOrderList(state.orders);
          }

          if (state is EmptyOrders) {
            return EmptyOrdersWidget(
              isFarmerView: _isFarmerView,
              onSwitchView: _toggleView,
            );
          }

          if (state is OrderError) {
            return _buildErrorWidget(context, state.message);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildOrderList(List<Order> orders) {
    final filtered = _getFilteredAndSortedOrders(orders);
    final visibleOrders = _getVisibleOrders(filtered);

    if (filtered.isEmpty) {
      return const _EmptyFilterState();
    }

    return RefreshIndicator(
      onRefresh: () async {
        _resetPagination();
        if (_isFarmerView) {
          context.read<OrderBloc>().add(
                const RefreshOrdersEvent(orderType: 'farmer'),
              );
        } else {
          context.read<OrderBloc>().add(
                const RefreshOrdersEvent(orderType: 'buyer'),
              );
        }
      },
      color: Colors.green,
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverToBoxAdapter(child: _buildFilterChips()),
          SliverToBoxAdapter(child: _buildStatisticsSection(context, filtered)),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (index < visibleOrders.length) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: OrderCard(
                        order: visibleOrders[index],
                        isFarmerView: _isFarmerView,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OrderDetailsScreen(
                                order: visibleOrders[index],
                                isFarmerView: _isFarmerView,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }
                  return null;
                },
                childCount: visibleOrders.length,
              ),
            ),
          ),
          if (filtered.length > _itemsPerPage && _hasMore && !_isLoadingMore)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: TextButton.icon(
                    onPressed: _loadMoreItems,
                    icon: const Icon(Icons.expand_more),
                    label: const Text('Load More'),
                    style: TextButton.styleFrom(foregroundColor: Colors.green),
                  ),
                ),
              ),
            ),
          if (_isLoadingMore)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                  ),
                ),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }

  List<Order> _getFilteredAndSortedOrders(List<Order> orders) {
    List<Order> filtered = List.from(orders);

    // For farmer view, show different statuses
    if (_isFarmerView) {
      switch (_selectedFilter) {
        case 'Paid':
          filtered = filtered.where((o) => o.status == 'PAID').toList();
          break;
        case 'Approved':
          filtered = filtered.where((o) => o.status == 'APPROVED').toList();
          break;
        case 'Delivered':
          filtered = filtered.where((o) => o.status == 'DELIVERED').toList();
          break;
        case 'Completed':
          filtered = filtered.where((o) => o.status == 'COMPLETED').toList();
          break;
        case 'Rejected':
          filtered = filtered.where((o) => o.status == 'REJECTED').toList();
          break;
        default:
          break;
      }
    } else {
      switch (_selectedFilter) {
        case 'Paid':
          filtered = filtered.where((o) => o.status == 'PAID').toList();
          break;
        case 'Pending':
          filtered = filtered.where((o) => o.status == 'PENDING').toList();
          break;
        case 'Delivered':
          filtered = filtered.where((o) => o.status == 'DELIVERED').toList();
          break;
        case 'Completed':
          filtered = filtered.where((o) => o.status == 'COMPLETED').toList();
          break;
        case 'Cancelled':
          filtered = filtered.where((o) => o.status == 'CANCELLED').toList();
          break;
        default:
          break;
      }
    }

    switch (_selectedSort) {
      case 'Newest':
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'Oldest':
        filtered.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case 'Highest Amount':
        filtered.sort((a, b) => b.totalAmount.compareTo(a.totalAmount));
        break;
      case 'Lowest Amount':
        filtered.sort((a, b) => a.totalAmount.compareTo(b.totalAmount));
        break;
    }

    return filtered;
  }

  void _updateFilter(String filter) {
    setState(() {
      _selectedFilter = filter;
      _resetPagination();
    });
  }

  void _updateSort(String sort) {
    setState(() {
      _selectedSort = sort;
      _resetPagination();
    });
  }

  Widget _buildFilterChips() {
    final filters = _isFarmerView
        ? ['All', 'Paid', 'Approved', 'Delivered', 'Completed', 'Rejected']
        : ['All', 'Paid', 'Pending', 'Delivered', 'Completed', 'Cancelled'];

    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = _selectedFilter == filter;

          return FilterChip(
            label: Text(filter),
            selected: isSelected,
            onSelected: (selected) => _updateFilter(filter),
            backgroundColor: Colors.white,
            selectedColor: Colors.green.shade50,
            checkmarkColor: Colors.green,
            labelStyle: TextStyle(
              color: isSelected ? Colors.green : Colors.grey.shade700,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
            side: BorderSide(
              color: isSelected ? Colors.green : Colors.grey.shade300,
              width: 1,
            ),
            shape: const StadiumBorder(),
          );
        },
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    final filters = _isFarmerView
        ? [
            {'title': 'All Orders', 'icon': Icons.list_rounded, 'color': Colors.grey, 'value': 'All'},
            {'title': 'Paid Orders', 'icon': Icons.payment, 'color': Colors.blue, 'value': 'Paid'},
            {'title': 'Approved Orders', 'icon': Icons.check_circle, 'color': Colors.green, 'value': 'Approved'},
            {'title': 'Delivered Orders', 'icon': Icons.local_shipping, 'color': Colors.teal, 'value': 'Delivered'},
            {'title': 'Completed Orders', 'icon': Icons.done_all, 'color': Colors.green, 'value': 'Completed'},
            {'title': 'Rejected Orders', 'icon': Icons.block, 'color': Colors.red, 'value': 'Rejected'},
          ]
        : [
            {'title': 'All Orders', 'icon': Icons.list_rounded, 'color': Colors.grey, 'value': 'All'},
            {'title': 'Paid Orders', 'icon': Icons.payment, 'color': Colors.blue, 'value': 'Paid'},
            {'title': 'Pending Orders', 'icon': Icons.pending, 'color': Colors.orange, 'value': 'Pending'},
            {'title': 'Delivered Orders', 'icon': Icons.local_shipping, 'color': Colors.teal, 'value': 'Delivered'},
            {'title': 'Completed Orders', 'icon': Icons.done_all, 'color': Colors.green, 'value': 'Completed'},
            {'title': 'Cancelled Orders', 'icon': Icons.cancel, 'color': Colors.red, 'value': 'Cancelled'},
          ];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateBottomSheet) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Filter Orders',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ...filters.map((filter) => _buildFilterOption(
                        context,
                        filter['title'] as String,
                        filter['icon'] as IconData,
                        filter['color'] as Color,
                        _selectedFilter == filter['value'],
                        () {
                          setStateBottomSheet(() => _selectedFilter = filter['value'] as String);
                          Navigator.pop(context);
                          _updateFilter(filter['value'] as String);
                        },
                      )),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showSortBottomSheet(BuildContext context) {
    final sorts = [
      {'title': 'Newest First', 'icon': Icons.fiber_new_rounded, 'color': Colors.blue, 'value': 'Newest'},
      {'title': 'Oldest First', 'icon': Icons.history_rounded, 'color': Colors.purple, 'value': 'Oldest'},
      {'title': 'Highest Amount', 'icon': Icons.trending_up_rounded, 'color': Colors.green, 'value': 'Highest Amount'},
      {'title': 'Lowest Amount', 'icon': Icons.trending_down_rounded, 'color': Colors.orange, 'value': 'Lowest Amount'},
    ];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateBottomSheet) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Sort Orders', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  ...sorts.map((sort) => _buildSortOption(
                        context,
                        sort['title'] as String,
                        sort['icon'] as IconData,
                        sort['color'] as Color,
                        _selectedSort == sort['value'],
                        () {
                          setStateBottomSheet(() => _selectedSort = sort['value'] as String);
                          Navigator.pop(context);
                          _updateSort(sort['value'] as String);
                        },
                      )),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFilterOption(BuildContext context, String title, IconData icon, Color color, bool isSelected, VoidCallback onTap) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
        child: Icon(icon, color: color),
      ),
      title: Text(title, style: TextStyle(fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal, color: isSelected ? color : Colors.grey.shade800)),
      trailing: isSelected ? Icon(Icons.check_circle_rounded, color: color) : null,
      onTap: onTap,
    );
  }

  Widget _buildSortOption(BuildContext context, String title, IconData icon, Color color, bool isSelected, VoidCallback onTap) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
        child: Icon(icon, color: color),
      ),
      title: Text(title, style: TextStyle(fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal, color: isSelected ? color : Colors.grey.shade800)),
      trailing: isSelected ? Icon(Icons.check_circle_rounded, color: color) : null,
      onTap: onTap,
    );
  }

  Widget _buildStatisticsSection(BuildContext context, List<Order> orders) {
    final totalOrders = orders.length;
    final completedOrders = _isFarmerView
        ? orders.where((o) => o.status == 'DELIVERED' || o.status == 'COMPLETED').length
        : orders.where((o) => o.status == 'PAID' || o.status == 'COMPLETED').length;
    final pendingOrders = orders.where((o) => o.status == 'PENDING').length;
    final totalEarnedOrSpent = _isFarmerView
        ? orders.where((o) => o.status == 'PAID' || o.status == 'COMPLETED').fold<double>(0, (sum, o) => sum + o.totalAmount)
        : orders.where((o) => o.status == 'PAID').fold<double>(0, (sum, o) => sum + o.totalAmount);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.grey.shade100, blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildStatItem(icon: Icons.shopping_bag_rounded, label: 'Total', value: totalOrders.toString(), color: Colors.blue)),
              Container(width: 1, height: 50, color: Colors.grey.shade200),
              Expanded(child: _buildStatItem(icon: Icons.check_circle_rounded, label: _isFarmerView ? 'Completed' : 'Paid', value: completedOrders.toString(), color: Colors.green)),
              Container(width: 1, height: 50, color: Colors.grey.shade200),
              Expanded(child: _buildStatItem(icon: Icons.pending_rounded, label: 'Pending', value: pendingOrders.toString(), color: Colors.orange)),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(10)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(_isFarmerView ? Icons.east_rounded : Icons.money_rounded, color: Colors.green.shade700, size: 16),
                const SizedBox(width: 6),
                Text(_isFarmerView ? 'Total Earned: ' : 'Total Spent: ', style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
                Text('${totalEarnedOrSpent.toStringAsFixed(0)} ETB', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.green.shade700)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({required IconData icon, required String label, required String value, required Color color}) {
    return Column(
      children: [
        Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle), child: Icon(icon, size: 20, color: color)),
        const SizedBox(height: 8),
        Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildErrorWidget(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline_rounded, size: 60, color: Colors.red.shade300),
          const SizedBox(height: 16),
          Text('Something went wrong', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey.shade800)),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(message, style: TextStyle(color: Colors.grey.shade600), textAlign: TextAlign.center),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              _resetPagination();
              if (_isFarmerView) {
                context.read<OrderBloc>().add(GetFarmerOrdersEvent());
              } else {
                context.read<OrderBloc>().add(GetMyOrdersEvent());
              }
            },
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _EmptyFilterState extends StatelessWidget {
  const _EmptyFilterState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(Icons.filter_alt_off_rounded, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text('No orders match', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
            const SizedBox(height: 8),
            Text('Try changing your filter or sort options', style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
          ],
        ),
      ),
    );
  }
}