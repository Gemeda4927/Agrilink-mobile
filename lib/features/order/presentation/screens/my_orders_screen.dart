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

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({Key? key}) : super(key: key);

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  String _selectedFilter = 'All';
  String _selectedSort = 'Newest';

  // Pagination variables
  int _itemsPerPage = 5;
  int _currentPage = 1;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
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
    
    // Simulate network delay for smooth UX
    await Future.delayed(const Duration(milliseconds: 500));
    
    setState(() {
      _currentPage++;
      _isLoadingMore = false;
      
      // Check if we have more items to load
      final state = context.read<OrderBloc>().state;
      if (state is OrdersLoaded) {
        final allOrders = _getFilteredAndSortedOrders(state.orders);
        final maxItems = _currentPage * _itemsPerPage;
        _hasMore = maxItems < allOrders.length;
      }
    });
  }

  void _showAllItems() {
    setState(() {
      final state = context.read<OrderBloc>().state;
      if (state is OrdersLoaded) {
        final allOrders = _getFilteredAndSortedOrders(state.orders);
        _currentPage = (allOrders.length / _itemsPerPage).ceil();
        _hasMore = false;
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

  List<Order> _getVisibleOrders(List<Order> filteredOrders) {
    final endIndex = _currentPage * _itemsPerPage;
    return filteredOrders.take(endIndex).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: BlocBuilder<OrderBloc, OrderState>(
        builder: (context, state) {
          if (state is OrderInitial) {
            context.read<OrderBloc>().add(GetMyOrdersEvent());
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

          if (state is OrdersLoaded) {
            final allOrders = state.orders;
            final filtered = _getFilteredAndSortedOrders(allOrders);
            final visibleOrders = _getVisibleOrders(filtered);
            final hasMore = visibleOrders.length < filtered.length;
            
            // Update _hasMore to match current state
            if (_hasMore != hasMore) {
              _hasMore = hasMore;
            }

            return RefreshIndicator(
              onRefresh: () async {
                _resetPagination();
                context.read<OrderBloc>().add(RefreshOrdersEvent());
              },
              color: Colors.green,
              child: CustomScrollView(
                controller: _scrollController,
                slivers: [
                  SliverAppBar(
                    title: const Text(
                      'My Orders',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    backgroundColor: Colors.white,
                    elevation: 0,
                    centerTitle: false,
                    leading: IconButton(
                      icon: const Icon(
                        Icons.arrow_back_rounded,
                        color: Colors.green,
                      ),
                      onPressed: () {
                        context.goNamed(RouteName.home);
                      },
                    ),
                    actions: [
                      // See All button
                      if (filtered.length > _itemsPerPage && hasMore)
                        TextButton(
                          onPressed: _showAllItems,
                          child: const Text(
                            'See All',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      IconButton(
                        icon: Badge(
                          isLabelVisible: _selectedFilter != 'All',
                          backgroundColor: Colors.green,
                          child: const Icon(
                            Icons.filter_list_rounded,
                            color: Colors.green,
                          ),
                        ),
                        onPressed: () => _showFilterBottomSheet(context),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.sort_rounded,
                          color: Colors.green,
                        ),
                        onPressed: () => _showSortBottomSheet(context),
                      ),
                    ],
                  ),
                  SliverToBoxAdapter(child: _buildFilterChips()),
                  SliverToBoxAdapter(
                    child: _buildStatisticsSection(context, filtered),
                  ),
                  if (filtered.isEmpty)
                    const SliverToBoxAdapter(child: _EmptyFilterState())
                  else
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            if (index < visibleOrders.length) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: OrderCard(order: visibleOrders[index]),
                              );
                            }
                            return null;
                          },
                          childCount: visibleOrders.length,
                        ),
                      ),
                    ),
                  // Load more indicator
                  if (hasMore && !_isLoadingMore)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                          child: TextButton.icon(
                            onPressed: _loadMoreItems,
                            icon: const Icon(Icons.expand_more),
                            label: const Text('Load More'),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.green,
                            ),
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
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.green,
                            ),
                          ),
                        ),
                      ),
                    ),
                  const SliverToBoxAdapter(child: SizedBox(height: 80)),
                ],
              ),
            );
          }

          if (state is EmptyOrders) {
            return const EmptyOrdersWidget();
          }

          if (state is OrderError) {
            return _buildErrorWidget(context, state.message);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  List<Order> _getFilteredAndSortedOrders(List<Order> orders) {
    List<Order> filtered = List.from(orders);

    switch (_selectedFilter) {
      case 'Paid':
        filtered = filtered.where((o) => o.status == 'PAID').toList();
        break;
      case 'Pending':
        filtered = filtered.where((o) => o.status == 'PENDING').toList();
        break;
      case 'Failed':
        filtered = filtered.where((o) => o.status == 'FAILED').toList();
        break;
      case 'Cancelled':
        filtered = filtered.where((o) => o.status == 'CANCELLED').toList();
        break;
      default:
        break;
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
    final filters = ['All', 'Paid', 'Pending', 'Failed', 'Cancelled'];

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
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildFilterOption(
                    context,
                    'All Orders',
                    Icons.list_rounded,
                    Colors.grey,
                    _selectedFilter == 'All',
                    () {
                      setStateBottomSheet(() => _selectedFilter = 'All');
                      Navigator.pop(context);
                      _updateFilter('All');
                    },
                  ),
                  _buildFilterOption(
                    context,
                    'Paid Orders',
                    Icons.check_circle_rounded,
                    Colors.green,
                    _selectedFilter == 'Paid',
                    () {
                      setStateBottomSheet(() => _selectedFilter = 'Paid');
                      Navigator.pop(context);
                      _updateFilter('Paid');
                    },
                  ),
                  _buildFilterOption(
                    context,
                    'Pending Orders',
                    Icons.pending_rounded,
                    Colors.orange,
                    _selectedFilter == 'Pending',
                    () {
                      setStateBottomSheet(() => _selectedFilter = 'Pending');
                      Navigator.pop(context);
                      _updateFilter('Pending');
                    },
                  ),
                  _buildFilterOption(
                    context,
                    'Failed Orders',
                    Icons.error_rounded,
                    Colors.red,
                    _selectedFilter == 'Failed',
                    () {
                      setStateBottomSheet(() => _selectedFilter = 'Failed');
                      Navigator.pop(context);
                      _updateFilter('Failed');
                    },
                  ),
                  _buildFilterOption(
                    context,
                    'Cancelled Orders',
                    Icons.cancel_rounded,
                    Colors.grey,
                    _selectedFilter == 'Cancelled',
                    () {
                      setStateBottomSheet(() => _selectedFilter = 'Cancelled');
                      Navigator.pop(context);
                      _updateFilter('Cancelled');
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showSortBottomSheet(BuildContext context) {
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
                    'Sort Orders',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSortOption(
                    context,
                    'Newest First',
                    Icons.fiber_new_rounded,
                    Colors.blue,
                    _selectedSort == 'Newest',
                    () {
                      setStateBottomSheet(() => _selectedSort = 'Newest');
                      Navigator.pop(context);
                      _updateSort('Newest');
                    },
                  ),
                  _buildSortOption(
                    context,
                    'Oldest First',
                    Icons.history_rounded,
                    Colors.purple,
                    _selectedSort == 'Oldest',
                    () {
                      setStateBottomSheet(() => _selectedSort = 'Oldest');
                      Navigator.pop(context);
                      _updateSort('Oldest');
                    },
                  ),
                  _buildSortOption(
                    context,
                    'Highest Amount',
                    Icons.trending_up_rounded,
                    Colors.green,
                    _selectedSort == 'Highest Amount',
                    () {
                      setStateBottomSheet(
                        () => _selectedSort = 'Highest Amount',
                      );
                      Navigator.pop(context);
                      _updateSort('Highest Amount');
                    },
                  ),
                  _buildSortOption(
                    context,
                    'Lowest Amount',
                    Icons.trending_down_rounded,
                    Colors.orange,
                    _selectedSort == 'Lowest Amount',
                    () {
                      setStateBottomSheet(
                        () => _selectedSort = 'Lowest Amount',
                      );
                      Navigator.pop(context);
                      _updateSort('Lowest Amount');
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFilterOption(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          color: isSelected ? color : Colors.grey.shade800,
        ),
      ),
      trailing: isSelected
          ? Icon(Icons.check_circle_rounded, color: color)
          : null,
      onTap: onTap,
    );
  }

  Widget _buildSortOption(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          color: isSelected ? color : Colors.grey.shade800,
        ),
      ),
      trailing: isSelected
          ? Icon(Icons.check_circle_rounded, color: color)
          : null,
      onTap: onTap,
    );
  }

  Widget _buildStatisticsSection(BuildContext context, List<Order> orders) {
    final totalOrders = orders.length;
    final completedOrders = orders.where((o) => o.status == 'PAID').length;
    final pendingOrders = orders.where((o) => o.status == 'PENDING').length;
    final totalSpent = orders
        .where((o) => o.status == 'PAID')
        .fold<double>(0, (sum, o) => sum + o.totalAmount);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  icon: Icons.shopping_bag_rounded,
                  label: 'Total',
                  value: totalOrders.toString(),
                  color: Colors.blue,
                ),
              ),
              Container(width: 1, height: 50, color: Colors.grey.shade200),
              Expanded(
                child: _buildStatItem(
                  icon: Icons.check_circle_rounded,
                  label: 'Completed',
                  value: completedOrders.toString(),
                  color: Colors.green,
                ),
              ),
              Container(width: 1, height: 50, color: Colors.grey.shade200),
              Expanded(
                child: _buildStatItem(
                  icon: Icons.pending_rounded,
                  label: 'Pending',
                  value: pendingOrders.toString(),
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.money_rounded,
                  color: Colors.green.shade700,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  'Total Spent: ',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                ),
                Text(
                  '${totalSpent.toStringAsFixed(0)} ETB',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 20, color: color),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorWidget(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 60,
            color: Colors.red.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'Something went wrong',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              message,
              style: TextStyle(color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              _resetPagination();
              context.read<OrderBloc>().add(GetMyOrdersEvent());
            },
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
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
            Icon(
              Icons.filter_alt_off_rounded,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No orders match',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try changing your filter or sort options',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}