// features/insight/presentation/screens/market_screen.dart
import 'package:agrilink/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:agrilink/features/auth/presentation/bloc/auth_state.dart';
import 'package:agrilink/features/insight/presentation/bloc/market_event.dart';
import 'package:agrilink/features/insight/presentation/bloc/market_state.dart';
import 'package:agrilink/features/insight/presentation/screens/submit_price_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:agrilink/features/insight/presentation/bloc/market_bloc.dart';
import '../../data/model/market_insight.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'dart:math' as math;

class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen>
    with TickerProviderStateMixin {
  late AnimationController _refreshController;
  late AnimationController _statsController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  String _selectedFilter = 'All';
  String _selectedSort = 'Trending';
  final List<String> _filters = [
    'All',
    '🌾 Teff',
    '🌽 Maize',
    '🌱 Wheat',
    '☕ Coffee',
    '🍌 Banana',
    '🍊 Orange',
    'Trending',
  ];
  final ScrollController _scrollController = ScrollController();
  bool _isGridView = false;

  // Real stats
  double _totalValueLocked = 0;
  int _volume24h = 0;
  int _activeProducts = 0;
  double _marketMomentum = 0;

  // Chart data
  List<MarketPriceResponse> _allPrices = [];
  String _selectedProductForChart = '';
  String _chartTimeRange = '1M';

  @override
  void initState() {
    super.initState();
    _refreshController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _statsController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..forward();

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _statsController, curve: Curves.easeOut));
    _scaleAnimation = Tween<double>(begin: 0.9, end: 1).animate(
      CurvedAnimation(parent: _statsController, curve: Curves.elasticOut),
    );

    _loadInitialData();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() => setState(() {});

  @override
  void dispose() {
    _refreshController.dispose();
    _statsController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadInitialData() {
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

  void _refreshData() {
    HapticFeedback.mediumImpact();
    _refreshController.forward(from: 0);
    _loadInitialData();
  }

  void _updateStats(List<MarketPriceResponse> prices) {
    setState(() {
      _allPrices = prices;
      final approvedPrices = prices.where((p) => p.isApproved).toList();
      final uniqueProducts = approvedPrices.map((p) => p.product?.name).toSet();
      _activeProducts = uniqueProducts.length;
      _totalValueLocked = approvedPrices.fold(0, (sum, p) => sum + p.price);

      final now = DateTime.now();
      _volume24h = approvedPrices
          .where((p) => now.difference(p.date).inHours <= 24)
          .length;

      if (approvedPrices.isNotEmpty) {
        final recentPrices = approvedPrices.take(10).toList();
        double avgChange = 0;
        int changeCount = 0;
        for (int i = 0; i < recentPrices.length - 1; i++) {
          if (recentPrices[i + 1].price > 0) {
            final change =
                ((recentPrices[i].price - recentPrices[i + 1].price) /
                    recentPrices[i + 1].price) *
                100;
            avgChange += change;
            changeCount++;
          }
        }
        _marketMomentum = changeCount > 0
            ? (50 + avgChange / changeCount).clamp(0, 100)
            : 50;
      } else {
        _marketMomentum = 50;
      }
    });
  }

  List<MarketPriceResponse> _getFilteredPricesForProduct(String productName) {
    final prices =
        _allPrices
            .where((p) => p.product?.name == productName && p.isApproved)
            .toList()
          ..sort((a, b) => a.date.compareTo(b.date));

    final now = DateTime.now();
    switch (_chartTimeRange) {
      case '1W':
        return prices.where((p) => now.difference(p.date).inDays <= 7).toList();
      case '1M':
        return prices
            .where((p) => now.difference(p.date).inDays <= 30)
            .toList();
      case '3M':
        return prices
            .where((p) => now.difference(p.date).inDays <= 90)
            .toList();
      default:
        return prices;
    }
  }

  List<FlSpot> _getPriceSpotsForProduct(String productName) {
    final productPrices = _getFilteredPricesForProduct(productName);
    if (productPrices.length < 2) return [];
    return List.generate(
      productPrices.length,
      (index) => FlSpot(index.toDouble(), productPrices[index].price),
    );
  }

  Map<String, dynamic> _calculatePriceTrend(
    List<MarketPriceResponse> prices,
    int currentIndex,
  ) {
    if (currentIndex >= prices.length - 1) {
      return {'trend': 'neutral', 'percentage': 0.0, 'change': 0.0};
    }

    final currentProductId = prices[currentIndex].productId;
    MarketPriceResponse? previousPrice;
    for (int i = currentIndex + 1; i < prices.length; i++) {
      if (prices[i].productId == currentProductId) {
        previousPrice = prices[i];
        break;
      }
    }

    if (previousPrice == null || previousPrice.price == 0) {
      return {'trend': 'neutral', 'percentage': 0.0, 'change': 0.0};
    }

    final change = prices[currentIndex].price - previousPrice.price;
    final percentage = (change / previousPrice.price) * 100;
    return {
      'trend': change > 0 ? 'up' : (change < 0 ? 'down' : 'neutral'),
      'percentage': percentage.abs(),
      'change': change,
    };
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

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: const Color(0xFFFAFAFA),
        appBar: _buildGlassAppBar(),
        body: BlocListener<MarketBloc, MarketState>(
          listener: (context, state) {
            if (state is MarketPriceApproved) {
              _showApprovalSuccessModal(state.response, 'Approved');
            } else if (state is MarketPriceRejected) {
              _showApprovalSuccessModal(state.response, 'Rejected');
            } else if (state is MarketPriceUpdated) {
              _showEditSuccessModal(state.response);
            } else if (state is MarketPricesLoaded) {
              _updateStats(state.marketPrices);
            }
          },
          child: _buildBody(isAdminOrAgent, isContributor, isFarmerOrBuyer),
        ),
        floatingActionButton: isContributor ? _buildFloatingButton() : null,
      ),
    );
  }

  // ================= EDIT SUCCESS MODAL =================
  void _showEditSuccessModal(MarketPriceResponse price) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.edit_note,
                  color: Colors.blue,
                  size: 64,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Updated!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${price.product?.name ?? 'Price'} has been updated',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Text(
                'Awaiting moderator approval',
                style: TextStyle(fontSize: 12, color: Colors.orange.shade700),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _refreshData();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Done'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= SUCCESS MODAL FOR APPROVE/REJECT =================
  void _showApprovalSuccessModal(MarketPriceResponse price, String action) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: action == 'Approved'
                      ? Colors.green.shade50
                      : Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  action == 'Approved' ? Icons.check_circle : Icons.cancel,
                  color: action == 'Approved' ? Colors.green : Colors.red,
                  size: 64,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                '$action!',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${price.product?.name ?? 'Price'} has been $action',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _refreshData();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Done'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildGlassAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white.withOpacity(0.95),
      flexibleSpace: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade100, width: 1),
          ),
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.green.shade600, Colors.green.shade800],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.trending_up,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Market Insights',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.5),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              Text(
                'Live Prices',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.search, color: Colors.grey.shade700),
          onPressed: () => _showSearchDialog(),
        ),
        RotationTransition(
          turns: _refreshController,
          child: IconButton(
            icon: Icon(Icons.refresh_rounded, color: Colors.grey.shade700),
            onPressed: _refreshData,
          ),
        ),
      ],
    );
  }

  Widget _buildFloatingButton() {
    return FloatingActionButton.extended(
      onPressed: () {
        HapticFeedback.lightImpact();
        _navigateToSubmitPrice();
      },
      backgroundColor: const Color(0xFF2E7D32),
      icon: const Icon(Icons.add_chart_rounded),
      label: const Text('Submit Price'),
      elevation: 4,
    );
  }

  Widget _buildBody(
    bool isAdminOrAgent,
    bool isContributor,
    bool isFarmerOrBuyer,
  ) {
    if (isFarmerOrBuyer) return _buildMarketView();
    if (isContributor) return _buildContributorView();
    if (isAdminOrAgent) return _buildAdminView();
    return _buildMarketView();
  }

  Widget _buildAdminView() {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Container(
            color: Colors.white,
            child: const TabBar(
              tabs: [
                Tab(
                  icon: Icon(Icons.analytics_outlined),
                  text: 'Market Overview',
                ),
                Tab(
                  icon: Icon(Icons.pending_actions_outlined),
                  text: 'Moderation Queue',
                ),
              ],
              labelColor: Color(0xFF2E7D32),
              unselectedLabelColor: Colors.grey,
              indicatorColor: Color(0xFF2E7D32),
              indicatorWeight: 3,
              labelStyle: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [_buildMarketView(), _buildModerationQueue()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarketView() {
    return RefreshIndicator(
      onRefresh: () async => _refreshData(),
      color: const Color(0xFF2E7D32),
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverToBoxAdapter(child: _buildLiveTicker()),
          SliverToBoxAdapter(child: _buildStatsDashboard()),
          SliverToBoxAdapter(child: _buildEnhancedChartSection()),
          SliverToBoxAdapter(child: _buildFilterBar()),
          SliverToBoxAdapter(child: _buildViewToggle()),
          BlocBuilder<MarketBloc, MarketState>(
            builder: (context, state) {
              if (state is MarketLoading) {
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                );
              } else if (state is MarketPricesLoaded) {
                if (state.marketPrices.isEmpty) {
                  return SliverFillRemaining(child: _buildEmptyState());
                }
                final filteredPrices = _filterAndSortPrices(state.marketPrices);
                if (_isGridView) {
                  return SliverPadding(
                    padding: const EdgeInsets.all(12),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.85,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => _buildGridPriceCard(
                          filteredPrices[index],
                          state.marketPrices,
                          index,
                        ),
                        childCount: filteredPrices.length,
                      ),
                    ),
                  );
                } else {
                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildPriceCard(
                        filteredPrices[index],
                        state.marketPrices,
                        index,
                      ),
                      childCount: filteredPrices.length,
                    ),
                  );
                }
              } else if (state is MarketError) {
                return SliverFillRemaining(
                  child: _buildErrorState(state.message),
                );
              }
              return const SliverFillRemaining(child: SizedBox());
            },
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }

  // ================= MODERATION QUEUE (CLEAN VERSION) =================
  Widget _buildModerationQueue() {
    return BlocBuilder<MarketBloc, MarketState>(
      builder: (context, state) {
        if (state is MarketLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is MarketPricesLoaded) {
          final pendingPrices = state.marketPrices
              .where((p) => p.status.toUpperCase() == 'PENDING')
              .toList();

          if (pendingPrices.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 80,
                    color: Colors.green.shade300,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'All caught up!',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No pending approvals',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: pendingPrices.length,
            itemBuilder: (context, index) {
              final price = pendingPrices[index];
              return _buildModerationCard(price);
            },
          );
        }
        return const SizedBox();
      },
    );
  }

  // Clean Moderation Card
  Widget _buildModerationCard(MarketPriceResponse price) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.orange.shade100, width: 1),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.pending,
                    color: Colors.orange.shade700,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        price.product?.name ?? 'Unknown Product',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${price.price.toStringAsFixed(0)} ETB',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.green.shade700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 14,
                            color: Colors.grey.shade500,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            price.woreda?.name ?? 'N/A',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Submitted by: ${price.user?.email?.split('@')[0] ?? 'Unknown'}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'PENDING',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange.shade700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatTimeAgo(price.date),
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        _showApprovalDialog(price, isApprove: false),
                    icon: const Icon(Icons.close, size: 18),
                    label: const Text('Reject'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () =>
                        _showApprovalDialog(price, isApprove: true),
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('Approve'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================= APPROVAL CONFIRMATION DIALOG =================
  void _showApprovalDialog(
    MarketPriceResponse price, {
    required bool isApprove,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(
              isApprove ? Icons.check_circle : Icons.cancel,
              color: isApprove ? Colors.green : Colors.red,
            ),
            const SizedBox(width: 12),
            Text(isApprove ? 'Approve Price' : 'Reject Price'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Product: ${price.product?.name ?? 'Unknown'}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text('Price: ${price.price.toStringAsFixed(0)} ETB'),
            const SizedBox(height: 4),
            Text('Location: ${price.woreda?.name ?? 'N/A'}'),
            const SizedBox(height: 16),
            Text(
              isApprove
                  ? 'Are you sure you want to approve this price? It will be visible to all users.'
                  : 'Are you sure you want to reject this price? This action cannot be undone.',
              style: TextStyle(color: Colors.grey.shade600),
            ),
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
              if (isApprove) {
                _handleApprove(price);
              } else {
                _handleReject(price);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isApprove ? Colors.green : Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(isApprove ? 'Approve' : 'Reject'),
          ),
        ],
      ),
    );
  }

  // ================= ENHANCED CHART SECTION =================
  Widget _buildEnhancedChartSection() {
    if (_allPrices.isEmpty) return const SizedBox();

    final uniqueProducts = _allPrices
        .where((p) => p.isApproved)
        .map((p) => p.product?.name)
        .where((name) => name != null)
        .toSet()
        .toList();

    if (uniqueProducts.isEmpty) return const SizedBox();

    if (_selectedProductForChart.isEmpty && uniqueProducts.isNotEmpty) {
      _selectedProductForChart = uniqueProducts.first!;
    }

    final filteredPrices = _getFilteredPricesForProduct(
      _selectedProductForChart,
    );
    final spots = _getPriceSpotsForProduct(_selectedProductForChart);
    final currentPrice = _getCurrentPriceForProduct(_selectedProductForChart);
    final previousPrice = _getPreviousPriceForProduct(_selectedProductForChart);
    final avgPrice = _getAveragePriceForProduct(_selectedProductForChart);
    final minPrice = _getMinPriceForProduct(_selectedProductForChart);
    final maxPrice = _getMaxPriceForProduct(_selectedProductForChart);
    final priceChange = currentPrice - previousPrice;
    final priceChangePercent = previousPrice > 0
        ? ((priceChange / previousPrice) * 100).toDouble()
        : 0.0;
    final isPriceUp = priceChange > 0;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '📈 Price Trends',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: DropdownButton<String>(
                  value: _selectedProductForChart,
                  underline: const SizedBox(),
                  icon: Icon(
                    Icons.arrow_drop_down,
                    color: Colors.green.shade700,
                  ),
                  style: TextStyle(
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                  items: uniqueProducts.map((product) {
                    return DropdownMenuItem(
                      value: product,
                      child: Row(
                        children: [
                          Icon(
                            _getProductIcon(product!),
                            size: 16,
                            color: Colors.green.shade700,
                          ),
                          const SizedBox(width: 8),
                          Text(product),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) =>
                      setState(() => _selectedProductForChart = value ?? ''),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isPriceUp
                    ? [Colors.green.shade50, Colors.green.shade100]
                    : [Colors.red.shade50, Colors.red.shade100],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Price',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${currentPrice.toStringAsFixed(0)} ETB',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isPriceUp ? Colors.green : Colors.red,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isPriceUp ? Icons.trending_up : Icons.trending_down,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${priceChangePercent > 0 ? '+' : ''}${priceChangePercent.toStringAsFixed(1)}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatChip(
                'Min',
                minPrice,
                Colors.blue,
                Icons.arrow_downward,
              ),
              const SizedBox(width: 12),
              _buildStatChip('Avg', avgPrice, Colors.orange, Icons.show_chart),
              const SizedBox(width: 12),
              _buildStatChip('Max', maxPrice, Colors.red, Icons.arrow_upward),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildTimeRangeChip('1W', '1W'),
              _buildTimeRangeChip('1M', '1M'),
              _buildTimeRangeChip('3M', '3M'),
              _buildTimeRangeChip('ALL', 'ALL'),
            ],
          ),
          const SizedBox(height: 16),
          if (spots.isNotEmpty && filteredPrices.length >= 2) ...[
            SizedBox(
              height: 260,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 45,
                        getTitlesWidget: (value, meta) => Text(
                          '${value.toInt()}',
                          style: const TextStyle(fontSize: 10),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 35,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < filteredPrices.length) {
                            return Transform.rotate(
                              angle: -0.5,
                              child: Text(
                                DateFormat(
                                  'MM/dd',
                                ).format(filteredPrices[index].date),
                                style: const TextStyle(fontSize: 9),
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  minX: 0,
                  maxX: (spots.length - 1).toDouble(),
                  minY: (minPrice - 10).clamp(0, double.infinity).toDouble(),
                  maxY: (maxPrice + 20).toDouble(),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      curveSmoothness: 0.3,
                      color: const Color(0xFF2E7D32),
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          final isHighest = spot.y == maxPrice;
                          final isLowest = spot.y == minPrice;
                          return FlDotCirclePainter(
                            radius: (isHighest || isLowest ? 6 : 4).toDouble(),
                            color: isHighest
                                ? Colors.red
                                : (isLowest ? Colors.blue : Colors.white),
                            strokeWidth: 2,
                            strokeColor: const Color(0xFF2E7D32),
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF2E7D32).withOpacity(0.3),
                            const Color(0xFF2E7D32).withOpacity(0.0),
                          ],
                        ),
                      ),
                    ),
                  ],
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (spots) => spots.map((spot) {
                        final index = spot.x.toInt();
                        return LineTooltipItem(
                          '${DateFormat('MMM dd').format(filteredPrices[index].date)}\n${spot.y.toStringAsFixed(0)} ETB',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem('Price Trend', const Color(0xFF2E7D32)),
                const SizedBox(width: 16),
                _buildLegendItem('Highest Price', Colors.red),
                const SizedBox(width: 16),
                _buildLegendItem('Lowest Price', Colors.blue),
              ],
            ),
            const SizedBox(height: 12),
            _buildInsightCard(
              priceChangePercent,
              isPriceUp,
              minPrice,
              maxPrice,
              currentPrice,
            ),
          ] else if (filteredPrices.length < 2) ...[
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.show_chart, size: 50, color: Colors.grey),
                    SizedBox(height: 12),
                    Text(
                      'Need at least 2 price points\nto show trend',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Helper methods for stats and chart
  Widget _buildStatChip(
    String label,
    double value,
    Color color,
    IconData icon,
  ) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 10, color: color)),
          Text(
            '${value.toStringAsFixed(0)} ETB',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    ),
  );

  Widget _buildTimeRangeChip(String label, String value) {
    final isSelected = _chartTimeRange == value;
    return GestureDetector(
      onTap: () => setState(() => _chartTimeRange = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2E7D32) : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade700,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) => Row(
    children: [
      Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
      const SizedBox(width: 4),
      Text(label, style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
    ],
  );

  Widget _buildInsightCard(
    double changePercent,
    bool isUp,
    double minPrice,
    double maxPrice,
    double currentPrice,
  ) {
    String msg, icon;
    Color color;
    if (changePercent.abs() > 20) {
      msg = isUp
          ? 'Rapid price increase! Consider selling.'
          : 'Sharp price drop! Good for buyers.';
      icon = isUp ? '🚀' : '⚠️';
      color = isUp ? Colors.orange : Colors.red;
    } else if (changePercent.abs() > 10) {
      msg = isUp ? 'Strong upward trend.' : 'Significant downward trend.';
      icon = isUp ? '📈' : '📉';
      color = isUp ? Colors.green : Colors.red;
    } else if (changePercent.abs() > 5) {
      msg = isUp ? 'Moderate price increase.' : 'Moderate price decrease.';
      icon = isUp ? '↗️' : '↙️';
      color = isUp ? Colors.lightGreen : Colors.deepOrange;
    } else {
      msg = maxPrice - minPrice < 20
          ? 'Prices are very stable.'
          : 'Prices are relatively stable.';
      icon = '➡️';
      color = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text(icon),
          const SizedBox(width: 12),
          Expanded(
            child: Text(msg, style: TextStyle(color: color, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  double _getYAxisInterval(double minPrice, double maxPrice) {
    final range = maxPrice - minPrice;
    if (range <= 50) return 10;
    if (range <= 100) return 20;
    if (range <= 200) return 50;
    return 100;
  }

  double _getXAxisInterval(int dataPoints) {
    if (dataPoints <= 7) return 1;
    if (dataPoints <= 14) return 2;
    if (dataPoints <= 30) return 5;
    return 10;
  }

  double _getCurrentPriceForProduct(String productName) {
    final prices = _getFilteredPricesForProduct(productName);
    return prices.isEmpty ? 0 : prices.last.price;
  }

  double _getPreviousPriceForProduct(String productName) {
    final prices = _getFilteredPricesForProduct(productName);
    return prices.length < 2 ? 0 : prices[prices.length - 2].price;
  }

  double _getAveragePriceForProduct(String productName) {
    final prices = _getFilteredPricesForProduct(productName);
    if (prices.isEmpty) return 0;
    return prices.fold(0.0, (s, p) => s + p.price) / prices.length;
  }

  double _getMinPriceForProduct(String productName) {
    final prices = _getFilteredPricesForProduct(productName);
    return prices.isEmpty ? 0 : prices.map((p) => p.price).reduce(math.min);
  }

  double _getMaxPriceForProduct(String productName) {
    final prices = _getFilteredPricesForProduct(productName);
    return prices.isEmpty ? 0 : prices.map((p) => p.price).reduce(math.max);
  }

  Widget _buildLiveTicker() => BlocBuilder<MarketBloc, MarketState>(
    builder: (context, state) {
      if (state is MarketPricesLoaded && state.marketPrices.isNotEmpty) {
        final approvedPrices = state.marketPrices
            .where((p) => p.isApproved)
            .toList();
        final unique = approvedPrices
            .map((p) => p.product?.name)
            .where((n) => n != null)
            .toSet()
            .toList();
        return Container(
          height: 40,
          margin: const EdgeInsets.only(top: 8),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: unique.length * 3,
            itemBuilder: (context, index) {
              final name = unique[index % unique.length];
              final prices =
                  approvedPrices.where((p) => p.product?.name == name).toList()
                    ..sort((a, b) => b.date.compareTo(a.date));
              if (prices.isEmpty) return const SizedBox();
              final latest = prices.first;
              final older = prices.length > 1 ? prices[1] : null;
              double change = 0;
              bool isUp = true;
              if (older != null && older.price > 0) {
                change = ((latest.price - older.price) / older.price) * 100;
                isUp = change > 0;
                change = change.abs();
              }
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Text(
                      name ?? 'Unknown',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${latest.price.toStringAsFixed(0)} ETB',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: (isUp ? Colors.green : Colors.red).withOpacity(
                          0.1,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isUp ? Icons.trending_up : Icons.trending_down,
                            size: 12,
                            color: isUp ? Colors.green : Colors.red,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '${change.toStringAsFixed(1)}%',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: isUp ? Colors.green : Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      }
      return const SizedBox(height: 40);
    },
  );

  Widget _buildStatsDashboard() => AnimatedBuilder(
    animation: _statsController,
    builder: (context, child) => FadeTransition(
      opacity: _fadeAnimation,
      child: Transform.scale(
        scale: _scaleAnimation.value,
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [const Color(0xFF2E7D32), const Color(0xFF4CAF50)],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2E7D32).withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatCard(
                Icons.lock_outline,
                'TVL',
                '${(_totalValueLocked / 1000).toStringAsFixed(1)}K',
                'ETB',
              ),
              Container(
                height: 50,
                width: 1,
                color: Colors.white.withOpacity(0.3),
              ),
              _buildStatCard(
                Icons.trending_up,
                '24h Vol',
                _volume24h.toString(),
                'updates',
                trend: _volume24h > 0
                    ? '+${((_volume24h / math.max(1, _activeProducts)) * 10).toStringAsFixed(0)}%'
                    : null,
              ),
              Container(
                height: 50,
                width: 1,
                color: Colors.white.withOpacity(0.3),
              ),
              _buildStatCard(
                Icons.agriculture,
                'Products',
                _activeProducts.toString(),
                'active',
              ),
              Container(
                height: 50,
                width: 1,
                color: Colors.white.withOpacity(0.3),
              ),
              _buildMomentumGauge(),
            ],
          ),
        ),
      ),
    ),
  );

  Widget _buildStatCard(
    IconData icon,
    String label,
    String value,
    String subtitle, {
    String? trend,
    bool trendUp = true,
  }) => Column(
    children: [
      Icon(icon, color: Colors.white, size: 24),
      const SizedBox(height: 8),
      Text(
        value,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
      if (trend != null)
        Row(
          children: [
            Icon(
              trendUp ? Icons.arrow_upward : Icons.arrow_downward,
              size: 10,
              color: trendUp ? Colors.green.shade300 : Colors.red.shade300,
            ),
            const SizedBox(width: 2),
            Text(
              trend,
              style: TextStyle(
                fontSize: 9,
                color: trendUp ? Colors.green.shade300 : Colors.red.shade300,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
    ],
  );

  Widget _buildMomentumGauge() => Column(
    children: [
      Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 50,
            height: 50,
            child: CircularProgressIndicator(
              value: _marketMomentum / 100,
              strokeWidth: 4,
              backgroundColor: Colors.white.withOpacity(0.3),
              valueColor: AlwaysStoppedAnimation(
                _marketMomentum > 60
                    ? Colors.green.shade300
                    : _marketMomentum > 40
                    ? Colors.orange
                    : Colors.red.shade300,
              ),
            ),
          ),
          Text(
            '${_marketMomentum.toStringAsFixed(0)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      const SizedBox(height: 4),
      const Text(
        'Momentum',
        style: TextStyle(color: Colors.white70, fontSize: 10),
      ),
    ],
  );

  Widget _buildFilterBar() => Container(
    height: 50,
    margin: const EdgeInsets.only(bottom: 8),
    child: ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      itemCount: _filters.length,
      itemBuilder: (context, index) {
        final filter = _filters[index];
        final isSelected = _selectedFilter == filter;
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: FilterChip(
            label: Text(filter),
            selected: isSelected,
            onSelected: (_) => setState(() => _selectedFilter = filter),
            backgroundColor: Colors.white,
            selectedColor: const Color(0xFF2E7D32).withOpacity(0.1),
            labelStyle: TextStyle(
              color: isSelected
                  ? const Color(0xFF2E7D32)
                  : Colors.grey.shade700,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
            avatar: isSelected
                ? Icon(
                    Icons.check_circle,
                    color: const Color(0xFF2E7D32),
                    size: 16,
                  )
                : null,
            shape: StadiumBorder(
              side: BorderSide(
                color: isSelected
                    ? const Color(0xFF2E7D32)
                    : Colors.grey.shade300,
              ),
            ),
          ),
        );
      },
    ),
  );

  Widget _buildViewToggle() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '${_selectedFilter == 'All' ? 'All Products' : _selectedFilter}',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        Row(
          children: [
            IconButton(
              icon: Icon(
                Icons.view_list_rounded,
                color: !_isGridView ? const Color(0xFF2E7D32) : Colors.grey,
              ),
              onPressed: () => setState(() => _isGridView = false),
              constraints: const BoxConstraints(),
              padding: const EdgeInsets.all(8),
            ),
            IconButton(
              icon: Icon(
                Icons.grid_view_rounded,
                color: _isGridView ? const Color(0xFF2E7D32) : Colors.grey,
              ),
              onPressed: () => setState(() => _isGridView = true),
              constraints: const BoxConstraints(),
              padding: const EdgeInsets.all(8),
            ),
            const SizedBox(width: 8),
            Container(height: 30, width: 1, color: Colors.grey.shade300),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.sort_rounded),
              onPressed: _showSortDialog,
              color: Colors.grey.shade700,
              constraints: const BoxConstraints(),
              padding: const EdgeInsets.all(8),
            ),
          ],
        ),
      ],
    ),
  );

  Widget _buildPriceCard(
    MarketPriceResponse price,
    List<MarketPriceResponse> allPrices,
    int index,
  ) {
    final authState = context.read<AuthBloc>().state;
    final userRole = authState is AuthSuccess
        ? authState.authResponse.user.role
        : 'GUEST';
    final isContributor = userRole == 'DATA_CONTRIBUTOR';
    final canEdit = isContributor && !price.isApproved;
    
    final trend = _calculatePriceTrend(allPrices, index);
    final isUp = trend['trend'] == 'up';
    final percent = trend['percentage'] as double;
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0.8, end: 1),
      duration: Duration(milliseconds: 300 + (index * 50)),
      builder: (context, value, child) => Transform.scale(
        scale: value,
        child: Opacity(
          opacity: value,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _showPriceDetails(price, allPrices, showActions: canEdit),
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.green.shade400,
                                  Colors.green.shade700,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(
                              _getProductIcon(price.product?.name ?? ''),
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  price.product?.name ?? 'Unknown',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.location_on,
                                      size: 12,
                                      color: Colors.grey.shade500,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      price.woreda?.name ?? 'N/A',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Icon(
                                      Icons.access_time,
                                      size: 12,
                                      color: Colors.grey.shade500,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      _formatTimeAgo(price.date),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${price.price.toStringAsFixed(0)} ETB',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              if (trend['trend'] != 'neutral')
                                Container(
                                  margin: const EdgeInsets.only(top: 4),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: (isUp ? Colors.green : Colors.red)
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        isUp
                                            ? Icons.trending_up
                                            : Icons.trending_down,
                                        size: 12,
                                        color: isUp ? Colors.green : Colors.red,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${percent.toStringAsFixed(1)}%',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: isUp
                                              ? Colors.green
                                              : Colors.red,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                      if (price.status.toUpperCase() == 'PENDING')
                        Container(
                          margin: const EdgeInsets.only(top: 12),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.pending,
                                size: 14,
                                color: Colors.orange.shade700,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Pending Approval',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.orange.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (canEdit && price.status.toUpperCase() == 'PENDING')
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: TextButton.icon(
                              onPressed: () => _navigateToEditPrice(price),
                              icon: Icon(Icons.edit, size: 16, color: Colors.blue.shade700),
                              label: Text(
                                'Edit',
                                style: TextStyle(fontSize: 12, color: Colors.blue.shade700),
                              ),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGridPriceCard(
    MarketPriceResponse price,
    List<MarketPriceResponse> allPrices,
    int index,
  ) {
    final authState = context.read<AuthBloc>().state;
    final userRole = authState is AuthSuccess
        ? authState.authResponse.user.role
        : 'GUEST';
    final isContributor = userRole == 'DATA_CONTRIBUTOR';
    final canEdit = isContributor && !price.isApproved;
    
    final trend = _calculatePriceTrend(allPrices, index);
    final isUp = trend['trend'] == 'up';
    final percent = trend['percentage'] as double;
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 400 + (index * 50)),
      builder: (context, value, child) => Transform.scale(
        scale: value,
        child: Opacity(
          opacity: value,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _showPriceDetails(price, allPrices, showActions: canEdit),
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.green.shade400,
                                Colors.green.shade700,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            _getProductIcon(price.product?.name ?? ''),
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        price.product?.name ?? 'Unknown',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        price.woreda?.name ?? 'N/A',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Divider(color: Colors.grey.shade200),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${price.price.toStringAsFixed(0)} ETB',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2E7D32),
                            ),
                          ),
                          if (trend['trend'] != 'neutral')
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: (isUp ? Colors.green : Colors.red)
                                    .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    isUp
                                        ? Icons.arrow_upward
                                        : Icons.arrow_downward,
                                    size: 10,
                                    color: isUp ? Colors.green : Colors.red,
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    '${percent.toStringAsFixed(1)}%',
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      color: isUp ? Colors.green : Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      if (canEdit && price.status.toUpperCase() == 'PENDING')
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: TextButton.icon(
                              onPressed: () => _navigateToEditPrice(price),
                              icon: Icon(Icons.edit, size: 14, color: Colors.blue.shade700),
                              label: Text(
                                'Edit',
                                style: TextStyle(fontSize: 11, color: Colors.blue.shade700),
                              ),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContributorView() => BlocBuilder<MarketBloc, MarketState>(
    builder: (context, state) {
      if (state is MarketLoading) return _buildLoadingSkeleton();
      if (state is MarketPricesLoaded) {
        final approved = state.marketPrices.where((p) => p.isApproved).length;
        final pending = state.marketPrices.where((p) => p.isPending).length;
        final rejected = state.marketPrices.where((p) => p.isRejected).length;
        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [const Color(0xFF2E7D32), const Color(0xFF4CAF50)],
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    const Text(
                      'My Contributions',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildContributionStat(
                          approved,
                          'Approved',
                          Icons.check_circle,
                          Colors.green.shade300,
                        ),
                        _buildContributionStat(
                          pending,
                          'Pending',
                          Icons.pending,
                          Colors.orange.shade300,
                        ),
                        _buildContributionStat(
                          rejected,
                          'Rejected',
                          Icons.cancel,
                          Colors.red.shade300,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    LinearProgressIndicator(
                      value: state.marketPrices.isEmpty
                          ? 0
                          : approved / state.marketPrices.length,
                      backgroundColor: Colors.white.withOpacity(0.3),
                      valueColor: const AlwaysStoppedAnimation(Colors.white),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${((approved / math.max(1, state.marketPrices.length)) * 100).toStringAsFixed(0)}% Success Rate',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (state.marketPrices.isEmpty)
              SliverFillRemaining(
                child: _buildEmptyState(
                  'No submissions yet',
                  'Tap + to submit your first price',
                  Icons.add_chart,
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildPriceCard(
                    state.marketPrices[index],
                    state.marketPrices,
                    index,
                  ),
                  childCount: state.marketPrices.length,
                ),
              ),
          ],
        );
      }
      return const SizedBox();
    },
  );

  Widget _buildContributionStat(
    int count,
    String label,
    IconData icon,
    Color color,
  ) => Column(
    children: [
      Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      const SizedBox(height: 6),
      Text(
        count.toString(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
    ],
  );

  Widget _buildLoadingSkeleton() => Shimmer.fromColors(
    baseColor: Colors.grey.shade300,
    highlightColor: Colors.grey.shade100,
    child: ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (_, __) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        height: 100,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    ),
  );

  Widget _buildEmptyState([
    String title = 'No market prices yet',
    String subtitle = 'Check back later',
    IconData icon = Icons.show_chart,
  ]) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 80, color: Colors.green.shade300),
        ),
        const SizedBox(height: 24),
        Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(subtitle, style: TextStyle(color: Colors.grey.shade600)),
      ],
    ),
  );

  Widget _buildErrorState(String message) => Center(
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
            color: Colors.red.shade300,
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Oops! Something went wrong',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          message,
          style: TextStyle(color: Colors.grey.shade600),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: _refreshData,
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

  void _showPriceDetails(
    MarketPriceResponse price,
    List<MarketPriceResponse> allPrices, {
    bool showActions = false,
  }) {
    final productPrices =
        allPrices
            .where((p) => p.productId == price.productId && p.isApproved)
            .toList()
          ..sort((a, b) => a.date.compareTo(b.date));
    final spots = List.generate(
      productPrices.length,
      (i) => FlSpot(i.toDouble(), productPrices[i].price),
    );
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
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
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
                Container(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.green.shade600,
                              Colors.green.shade800,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          _getProductIcon(price.product?.name ?? ''),
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              price.product?.name ?? 'Product',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  size: 14,
                                  color: Colors.grey.shade600,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  price.woreda?.name ?? 'N/A',
                                  style: TextStyle(color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${price.price.toStringAsFixed(0)} ETB',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2E7D32),
                            ),
                          ),
                          Text(
                            _formatTimeAgo(price.date),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      _buildDetailRow(
                        'Status',
                        price.status,
                        icon: Icons.info_outline,
                      ),
                      const SizedBox(height: 12),
                      _buildDetailRow(
                        'Submitted By',
                        price.user?.email?.split('@')[0] ?? 'Unknown',
                        icon: Icons.person_outline,
                      ),
                      const SizedBox(height: 12),
                      _buildDetailRow(
                        'Date',
                        DateFormat('MMM dd, yyyy').format(price.date),
                        icon: Icons.calendar_today,
                      ),
                      const SizedBox(height: 12),
                      _buildDetailRow(
                        'Coordinates',
                        '${price.latitude}, ${price.longitude}',
                        icon: Icons.map,
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Price History',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (productPrices.length >= 2)
                            Text(
                              '${productPrices.length} records',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade500,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 250,
                        child: spots.length >= 2
                            ? LineChart(
                                LineChartData(
                                  gridData: FlGridData(show: true),
                                  titlesData: FlTitlesData(
                                    leftTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        reservedSize: 40,
                                        getTitlesWidget: (v, _) => Text(
                                          '${v.toInt()}',
                                          style: const TextStyle(fontSize: 10),
                                        ),
                                      ),
                                    ),
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        reservedSize: 30,
                                        getTitlesWidget: (v, _) {
                                          final i = v.toInt();
                                          if (i >= 0 && i < spots.length)
                                            return Text(
                                              DateFormat(
                                                'MM/dd',
                                              ).format(productPrices[i].date),
                                              style: const TextStyle(
                                                fontSize: 9,
                                              ),
                                            );
                                          return const Text('');
                                        },
                                      ),
                                    ),
                                    rightTitles: const AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                    topTitles: const AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                  ),
                                  borderData: FlBorderData(show: true),
                                  minX: 0,
                                  maxX: (spots.length - 1).toDouble(),
                                  minY:
                                      (spots.map((s) => s.y).reduce(math.min) -
                                              10)
                                          .clamp(0, double.infinity),
                                  maxY:
                                      spots.map((s) => s.y).reduce(math.max) +
                                      20,
                                  lineBarsData: [
                                    LineChartBarData(
                                      spots: spots,
                                      isCurved: true,
                                      color: const Color(0xFF2E7D32),
                                      barWidth: 3,
                                      isStrokeCapRound: true,
                                      dotData: FlDotData(show: true),
                                      belowBarData: BarAreaData(
                                        show: true,
                                        color: const Color(
                                          0xFF2E7D32,
                                        ).withOpacity(0.1),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.show_chart,
                                      size: 50,
                                      color: Colors.grey.shade400,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'More price data needed\nto show trend',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.grey.shade500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
                if (showActions && price.status.toUpperCase() == 'PENDING')
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              _navigateToEditPrice(price);
                            },
                            icon: const Icon(Icons.edit),
                            label: const Text('Edit'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.blue,
                              side: const BorderSide(color: Colors.blue),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {IconData? icon}) => Row(
    children: [
      if (icon != null) ...[
        Icon(icon, size: 18, color: Colors.grey.shade600),
        const SizedBox(width: 12),
      ],
      Expanded(
        child: Text(
          label,
          style: const TextStyle(color: Colors.grey, fontSize: 13),
        ),
      ),
      Text(
        value,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
      ),
    ],
  );

  String _formatTimeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 7) return '${diff.inDays ~/ 7}w ago';
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }

  List<MarketPriceResponse> _filterAndSortPrices(
    List<MarketPriceResponse> prices,
  ) {
    var filtered = prices.where((p) {
      if (_selectedFilter == 'All' || _selectedFilter == 'Trending')
        return true;
      final name = _selectedFilter
          .replaceAll(RegExp(r'[🌾🌽🌱☕🍌🍊]'), '')
          .trim();
      return p.product?.name?.toLowerCase() == name.toLowerCase();
    }).toList();
    if (_selectedSort == 'Price (High-Low)')
      filtered.sort((a, b) => b.price.compareTo(a.price));
    else if (_selectedSort == 'Price (Low-High)')
      filtered.sort((a, b) => a.price.compareTo(b.price));
    else if (_selectedSort == 'Recently Added')
      filtered.sort((a, b) => b.date.compareTo(a.date));
    return filtered;
  }

  void _showSearchDialog() => showDialog(
    context: context,
    builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Search Products'),
      content: TextField(
        autofocus: true,
        decoration: InputDecoration(
          hintText: 'Type product name...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onSubmitted: (v) {
          setState(() => _selectedFilter = v);
          Navigator.pop(context);
        },
      ),
    ),
  );

  void _showSortDialog() => showModalBottomSheet(
    context: context,
    builder: (_) => Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Sort by',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...[
            'Trending',
            'Price (High-Low)',
            'Price (Low-High)',
            'Recently Added',
          ].map(
            (sort) => ListTile(
              title: Text(sort),
              leading: Radio(
                value: sort,
                groupValue: _selectedSort,
                onChanged: (v) {
                  setState(() => _selectedSort = v!);
                  Navigator.pop(context);
                },
                activeColor: const Color(0xFF2E7D32),
              ),
            ),
          ),
        ],
      ),
    ),
  );

  void _handleApprove(MarketPriceResponse price) async {
    context.read<MarketBloc>().add(ApproveMarketPriceEvent(price.id));
  }

  void _handleReject(MarketPriceResponse price) async {
    context.read<MarketBloc>().add(RejectMarketPriceEvent(price.id));
  }

  void _navigateToSubmitPrice() => Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const SubmitPriceScreen()),
  ).then((_) => _refreshData());

  void _navigateToEditPrice(MarketPriceResponse price) => Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => SubmitPriceScreen(existingPrice: price),
    ),
  ).then((_) => _refreshData());

  IconData _getProductIcon(String name) {
    switch (name.toLowerCase()) {
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
      default:
        return Icons.production_quantity_limits;
    }
  }
}