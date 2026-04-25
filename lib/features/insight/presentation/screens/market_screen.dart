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
import 'dart:math' as math;

class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> with TickerProviderStateMixin {
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
    'Trending',
  ];
  final ScrollController _scrollController = ScrollController();
  bool _isGridView = false;

  // Mock data for market stats (replace with real data)
  double _totalValueLocked = 1250000;
  int _volume24h = 347;
  int _activeProducts = 15;
  double _marketMomentum = 68.5;

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

    // Add scroll listener for parallax effects
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    setState(() {});
  }

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

  Map<String, dynamic> _calculatePriceTrend(
    List<MarketPriceResponse> prices,
    int currentIndex,
  ) {
    if (currentIndex >= prices.length - 1) {
      return {'trend': 'neutral', 'percentage': 0.0, 'change': 0.0};
    }

    final currentPrice = prices[currentIndex];
    MarketPriceResponse? previousPrice;
    for (int i = currentIndex + 1; i < prices.length; i++) {
      if (prices[i].product?.id == currentPrice.product?.id) {
        previousPrice = prices[i];
        break;
      }
    }

    if (previousPrice == null) {
      return {'trend': 'neutral', 'percentage': 0.0, 'change': 0.0};
    }

    final change = currentPrice.price - previousPrice.price;
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
        body: _buildBody(isAdminOrAgent, isContributor, isFarmerOrBuyer),
        floatingActionButton: isContributor ? _buildFloatingButton() : null,
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
        // Search button
        Container(
          margin: const EdgeInsets.only(right: 8),
          child: IconButton(
            icon: Icon(Icons.search, color: Colors.grey.shade700),
            onPressed: () => _showSearchDialog(),
          ),
        ),
        // Refresh button with animation
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
            child: TabBar(
              tabs: const [
                Tab(
                  icon: Icon(Icons.analytics_outlined),
                  text: 'Market Overview',
                ),
                Tab(
                  icon: Icon(Icons.pending_actions_outlined),
                  text: 'Moderation Queue',
                ),
              ],
              labelColor: const Color(0xFF2E7D32),
              unselectedLabelColor: Colors.grey,
              indicatorColor: const Color(0xFF2E7D32),
              indicatorWeight: 3,
              labelStyle: const TextStyle(fontWeight: FontWeight.w600),
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
          // Live Ticker
          SliverToBoxAdapter(child: _buildLiveTicker()),
          // Stats Dashboard
          SliverToBoxAdapter(child: _buildStatsDashboard()),
          // Filter Bar
          SliverToBoxAdapter(child: _buildFilterBar()),
          // View Toggle
          SliverToBoxAdapter(child: _buildViewToggle()),
          // Price List/Grid
          BlocBuilder<MarketBloc, MarketState>(
            builder: (context, state) {
              if (state is MarketLoading) {
                return SliverFillRemaining(child: _buildLoadingSkeleton());
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

  Widget _buildLiveTicker() {
    return Container(
      height: 40,
      margin: const EdgeInsets.only(top: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 20,
        itemBuilder: (context, index) {
          final products = ['Teff', 'Maize', 'Wheat', 'Coffee', 'Barley'];
          final changes = [2.3, -1.2, 0.8, 1.5, -0.5];
          final product = products[index % products.length];
          final change = changes[index % changes.length];
          final isUp = change > 0;

          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4),
              ],
            ),
            child: Row(
              children: [
                Text(
                  product,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: isUp
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
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
                        '${change.abs().toStringAsFixed(1)}%',
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

  Widget _buildStatsDashboard() {
    return AnimatedBuilder(
      animation: _statsController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [const Color(0xFF2E7D32), const Color(0xFF4CAF50)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
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
                    icon: Icons.lock_outline,
                    label: 'TVL',
                    value: '${(_totalValueLocked / 1000).toStringAsFixed(1)}K',
                    subtitle: 'ETB',
                  ),
                  Container(
                    height: 50,
                    width: 1,
                    color: Colors.white.withOpacity(0.3),
                  ),
                  _buildStatCard(
                    icon: Icons.trending_up,
                    label: '24h Vol',
                    value: _volume24h.toString(),
                    subtitle: 'updates',
                    trend: '+12%',
                    trendUp: true,
                  ),
                  Container(
                    height: 50,
                    width: 1,
                    color: Colors.white.withOpacity(0.3),
                  ),
                  _buildStatCard(
                    icon: Icons.agriculture,
                    label: 'Products',
                    value: _activeProducts.toString(),
                    subtitle: 'active',
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
        );
      },
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required String subtitle,
    String? trend,
    bool trendUp = true,
  }) {
    return Column(
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
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 11),
        ),
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
  }

  Widget _buildMomentumGauge() {
    return Column(
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
                valueColor: AlwaysStoppedAnimation<Color>(
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
  }

  Widget _buildFilterBar() {
    return Container(
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
              onSelected: (selected) {
                HapticFeedback.lightImpact();
                setState(() {
                  _selectedFilter = filter;
                });
              },
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
  }

  Widget _buildViewToggle() {
    return Padding(
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
                onPressed: () => _showSortDialog(),
                color: Colors.grey.shade700,
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(8),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceCard(
    MarketPriceResponse price,
    List<MarketPriceResponse> allPrices,
    int index,
  ) {
    final trendData = _calculatePriceTrend(allPrices, index);
    final trend = trendData['trend'] as String;
    final percentage = trendData['percentage'] as double;

    return Dismissible(
      key: Key(price.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.red.shade100,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.red),
      ),
      onDismissed: (_) {
        HapticFeedback.heavyImpact();
        // Handle delete for admin/agent
      },
      child: TweenAnimationBuilder(
        tween: Tween<double>(begin: 0.8, end: 1),
        duration: Duration(milliseconds: 300 + (index * 50)),
        builder: (context, value, child) {
          return Transform.scale(
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
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      _showPriceDetails(price);
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              // Animated product icon
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
                                child: TweenAnimationBuilder(
                                  tween: Tween<double>(begin: 0, end: 1),
                                  duration: const Duration(milliseconds: 500),
                                  builder: (context, value, child) {
                                    return Transform.scale(
                                      scale: value,
                                      child: child,
                                    );
                                  },
                                  child: Icon(
                                    _getProductIcon(price.product?.name ?? ''),
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              // Product info
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
                              // Price and trend
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
                                  if (trend != 'neutral')
                                    Container(
                                      margin: const EdgeInsets.only(top: 4),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: trend == 'up'
                                            ? Colors.green.withOpacity(0.1)
                                            : Colors.red.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            trend == 'up'
                                                ? Icons.trending_up
                                                : Icons.trending_down,
                                            size: 12,
                                            color: trend == 'up'
                                                ? Colors.green
                                                : Colors.red,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${percentage.toStringAsFixed(1)}%',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: trend == 'up'
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
                          // Extended info (appears on tap)
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
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGridPriceCard(
    MarketPriceResponse price,
    List<MarketPriceResponse> allPrices,
    int index,
  ) {
    final trendData = _calculatePriceTrend(allPrices, index);
    final trend = trendData['trend'] as String;
    final percentage = trendData['percentage'] as double;

    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 400 + (index * 50)),
      builder: (context, value, child) {
        return Transform.scale(
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
                  onTap: () => _showPriceDetails(price),
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
                            if (trend != 'neutral')
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: trend == 'up'
                                      ? Colors.green.withOpacity(0.1)
                                      : Colors.red.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      trend == 'up'
                                          ? Icons.arrow_upward
                                          : Icons.arrow_downward,
                                      size: 10,
                                      color: trend == 'up'
                                          ? Colors.green
                                          : Colors.red,
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      '${percentage.toStringAsFixed(1)}%',
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        color: trend == 'up'
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
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

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
            return _buildEmptyState(
              'All caught up!',
              'No pending approvals',
              Icons.check_circle_outline,
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: pendingPrices.length,
            itemBuilder: (context, index) => Dismissible(
              key: Key(pendingPrices[index].id),
              direction: DismissDirection.horizontal,
              background: Container(
                margin: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.only(left: 20),
                child: const Icon(Icons.check_circle, color: Colors.green),
              ),
              secondaryBackground: Container(
                margin: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                child: const Icon(Icons.cancel, color: Colors.red),
              ),
              onDismissed: (direction) {
                HapticFeedback.heavyImpact();
                if (direction == DismissDirection.startToEnd) {
                  _handleApprove(pendingPrices[index]);
                } else {
                  _handleReject(pendingPrices[index]);
                }
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.pending, color: Colors.orange.shade700),
                  ),
                  title: Text(
                    pendingPrices[index].product?.name ?? 'Unknown',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${pendingPrices[index].price} ETB - ${pendingPrices[index].woreda?.name ?? 'N/A'}',
                      ),
                      Text(
                        'Submitted by: ${pendingPrices[index].user?.email?.split('@')[0] ?? 'Unknown'}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'URGENT',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatTimeAgo(pendingPrices[index].date),
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                  onTap: () => _showPriceDetails(
                    pendingPrices[index],
                    showActions: true,
                  ),
                ),
              ),
            ),
          );
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildContributorView() {
    return BlocBuilder<MarketBloc, MarketState>(
      builder: (context, state) {
        if (state is MarketLoading) {
          return _buildLoadingSkeleton();
        } else if (state is MarketPricesLoaded) {
          final approvedCount = state.marketPrices
              .where((p) => p.status.toUpperCase() == 'APPROVED')
              .length;
          final pendingCount = state.marketPrices
              .where((p) => p.status.toUpperCase() == 'PENDING')
              .length;
          final rejectedCount = state.marketPrices
              .where((p) => p.status.toUpperCase() == 'REJECTED')
              .length;

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF2E7D32),
                        const Color(0xFF4CAF50),
                      ],
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
                            approvedCount,
                            'Approved',
                            Icons.check_circle,
                            Colors.green.shade300,
                          ),
                          _buildContributionStat(
                            pendingCount,
                            'Pending',
                            Icons.pending,
                            Colors.orange.shade300,
                          ),
                          _buildContributionStat(
                            rejectedCount,
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
                            : approvedCount / state.marketPrices.length,
                        backgroundColor: Colors.white.withOpacity(0.3),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${((approvedCount / math.max(1, state.marketPrices.length)) * 100).toStringAsFixed(0)}% Success Rate',
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
                    // showButton: true,
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
  }

  Widget _buildContributionStat(
    int count,
    String label,
    IconData icon,
    Color color,
  ) {
    return Column(
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
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildLoadingSkeleton() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        height: 100,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const ShimmerLoading(),
      ),
    );
  }

  Widget _buildEmptyState([
    String title = 'No market prices yet',
    String subtitle = 'Check back later',
    IconData icon = Icons.show_chart,
    bool showButton = false,
  ]) {
    return Center(
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
          if (showButton) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _navigateToSubmitPrice,
              icon: const Icon(Icons.add),
              label: const Text('Submit Price'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
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
  }

  void _showPriceDetails(
    MarketPriceResponse price, {
    bool showActions = false,
  }) {
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
          initialChildSize: 0.7,
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
                // Product header
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
                // Details section
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
                        price.date.split('T')[0],
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
                // Chart placeholder
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
                      const Text(
                        '7-Day Price Trend',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        height: 150,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Text(
                            '📊 Price chart would appear here',
                            style: TextStyle(color: Colors.grey),
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
                          child: ElevatedButton.icon(
                            onPressed: () => _handleReject(price),
                            icon: const Icon(Icons.close),
                            label: const Text('Reject'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade600,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _handleApprove(price),
                            icon: const Icon(Icons.check),
                            label: const Text('Approve'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2E7D32),
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

  Widget _buildDetailRow(String label, String value, {IconData? icon}) {
    return Row(
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
  }

  String _formatTimeAgo(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final diff = now.difference(date);

      if (diff.inDays > 7) return '${diff.inDays ~/ 7}w ago';
      if (diff.inDays > 0) return '${diff.inDays}d ago';
      if (diff.inHours > 0) return '${diff.inHours}h ago';
      if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
      return 'Just now';
    } catch (e) {
      return dateStr.split('T')[0];
    }
  }

  List<MarketPriceResponse> _filterAndSortPrices(
    List<MarketPriceResponse> prices,
  ) {
    var filtered = prices.where((p) {
      if (_selectedFilter == 'All') return true;
      if (_selectedFilter == 'Trending') return true; // Add trending logic
      return p.product?.name ==
          _selectedFilter.replaceAll(RegExp(r'[🌾🌽🌱☕]'), '').trim();
    }).toList();

    if (_selectedSort == 'Price (High-Low') {
      filtered.sort((a, b) => b.price.compareTo(a.price));
    } else if (_selectedSort == 'Price (Low-High') {
      filtered.sort((a, b) => a.price.compareTo(b.price));
    } else if (_selectedSort == 'Recently Added') {
      filtered.sort((a, b) => b.date.compareTo(a.date));
    }

    return filtered;
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => SearchBar(
        onSubmitted: (value) {
          setState(() => _selectedFilter = value);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showSortDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
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
                leading: Radio<String>(
                  value: sort,
                  groupValue: _selectedSort,
                  onChanged: (value) {
                    setState(() => _selectedSort = value!);
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
  }

  void _handleApprove(MarketPriceResponse price) async {
    Navigator.pop(context);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    context.read<MarketBloc>().add(ApproveMarketPriceEvent(price.id));
    await Future.delayed(const Duration(milliseconds: 500));
    if (context.mounted) Navigator.pop(context);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Price approved'),
          backgroundColor: Colors.green,
        ),
      );
    }
    _refreshData();
  }

  void _handleReject(MarketPriceResponse price) async {
    Navigator.pop(context);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    context.read<MarketBloc>().add(RejectMarketPriceEvent(price.id));
    await Future.delayed(const Duration(milliseconds: 500));
    if (context.mounted) Navigator.pop(context);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Price rejected'),
          backgroundColor: Colors.red,
        ),
      );
    }
    _refreshData();
  }

  void _navigateToSubmitPrice() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SubmitPriceScreen()),
    ).then((_) => _refreshData());
  }

  IconData _getProductIcon(String productName) {
    switch (productName.toLowerCase()) {
      case 'teff':
        return Icons.grass;
      case 'wheat':
        return Icons.agriculture;
      case 'coffee':
        return Icons.coffee;
      case 'maize':
        return Icons.earbuds;
      default:
        return Icons.production_quantity_limits;
    }
  }
}

class ShimmerLoading extends StatelessWidget {
  const ShimmerLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
}

class SearchBar extends StatelessWidget {
  final Function(String) onSubmitted;
  const SearchBar({super.key, required this.onSubmitted});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Search Products',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Type product name...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onSubmitted: onSubmitted,
            ),
          ],
        ),
      ),
    );
  }
}
