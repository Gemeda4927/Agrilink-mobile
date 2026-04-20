import 'package:agrilink/core/config/routes/route_name.dart';
import 'package:agrilink/core/localization/generated/app_localizations.dart';
import 'package:agrilink/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:agrilink/features/auth/presentation/bloc/auth_state.dart';
import 'package:agrilink/features/category/presentation/bloc/categories_bloc.dart';
import 'package:agrilink/features/category/presentation/bloc/categories_event.dart';
import 'package:agrilink/features/category/presentation/bloc/categories_state.dart';
import 'package:agrilink/features/recommendation/presentation/ai_chatbot_floating_button.dart';
import 'package:agrilink/features/role_request/presentation/bloc/role_request_bloc.dart';
import 'package:agrilink/features/role_request/presentation/bloc/role_request_event.dart';
import 'package:agrilink/features/role_request/presentation/bloc/role_request_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const double _cardPadding = 20.0;
  static const double _standardSpacing = 12.0;
  static const double _largeSpacing = 24.0;
  static const double _borderRadius = 16.0;
  static const double _iconSize = 24.0;

  bool _hasInitializedRoleRequest = false;
  String _cachedRequestStatus = 'NONE';
  int _notificationCount = 0;
  List<Map<String, String>> _notifications = [];

  @override
  void initState() {
    super.initState();
    _loadCachedRequestStatus();
    _loadSampleNotifications();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasInitializedRoleRequest) {
      final authState = context.read<AuthBloc>().state;
      if (authState is AuthSuccess) {
        _hasInitializedRoleRequest = true;
      }
    }
  }

  Future<void> _loadCachedRequestStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _cachedRequestStatus = prefs.getString('role_request_status') ?? 'NONE';
    });
  }

  void _loadSampleNotifications() {
    _notifications = [
      {
        'title': 'New Product Available!',
        'body': 'Fresh organic vegetables just added to the marketplace',
        'time': 'Just now',
        'icon': '🆕',
      },
      {
        'title': 'Special Discount',
        'body': 'Get 20% off on all grains this week only!',
        'time': '2 hours ago',
        'icon': '🎉',
      },
      {
        'title': 'Weather Alert',
        'body': 'Rain expected in your area tomorrow. Plan your farming activities.',
        'time': '5 hours ago',
        'icon': '⛈️',
      },
      {
        'title': 'Order Update',
        'body': 'Your order #12345 has been shipped successfully',
        'time': 'Yesterday',
        'icon': '📦',
      },
    ];
    _notificationCount = _notifications.length;
  }

  void _showNotificationDrawer() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildNotificationDrawer(),
    );
  }

  Widget _buildNotificationDrawer() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.notifications_active, color: Colors.green.shade700),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Notifications',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade800,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close, color: Colors.green.shade700),
                ),
              ],
            ),
          ),
          if (_notifications.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.notifications_off, size: 80, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    Text('No notifications yet', style: TextStyle(fontSize: 18, color: Colors.grey.shade600)),
                    const SizedBox(height: 8),
                    Text('We\'ll notify you when something important happens', style: TextStyle(fontSize: 14, color: Colors.grey.shade500)),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _notifications.length,
                itemBuilder: (context, index) {
                  return _buildNotificationCard(_notifications[index]);
                },
              ),
            ),
          if (_notifications.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.grey.shade200))),
              child: TextButton(
                onPressed: () {
                  setState(() {
                    _notifications.clear();
                    _notificationCount = 0;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('All notifications cleared'), behavior: SnackBarBehavior.floating),
                  );
                  Navigator.pop(context);
                },
                child: Text('Clear All', style: TextStyle(color: Colors.red.shade400)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, String> notification) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(notification['icon'] ?? '📢', style: const TextStyle(fontSize: 24)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(notification['title']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                Text(notification['body']!, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                const SizedBox(height: 4),
                Text(notification['time']!, style: TextStyle(fontSize: 10, color: Colors.grey.shade400)),
              ],
            ),
          ),
          Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
        ],
      ),
    );
  }

  String? _getTimeBasedGreeting(BuildContext context) {
    final hour = DateTime.now().hour;
    final t = AppLocalizations.of(context);
    if (hour < 12) return t?.goodMorning;
    if (hour < 17) return t?.goodAfternoon;
    return t?.goodEvening;
  }

  String _getGreetingEmoji() {
    final hour = DateTime.now().hour;
    if (hour < 12) return '🌅';
    if (hour < 17) return '☀️';
    return '🌙';
  }

  bool _isPrivilegedRole(String role) {
    return role == 'FARMER' || role == 'AGENT' || role == 'ADMIN';
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Stack(
      children: [
        Scaffold(
          resizeToAvoidBottomInset: true,
          drawer: _buildDrawer(context, t),
          appBar: _buildAppBar(context, t),
          body: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, authState) {
              if (authState is! AuthSuccess) {
                return _buildNoUserState(t);
              }
              return _buildMainContent(context, authState, t);
            },
          ),
        ),
        // AI Chatbot Floating Button - Positioned above bottom navigation
        const Positioned(
          bottom: 80, // Adjusted to sit above bottom nav bar
          right: 20,
          child: AIChatbotFAB(),
        ),
      ],
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, AppLocalizations t) {
    return AppBar(
      title: Text(t.appTitle, style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
      centerTitle: true,
      elevation: 0,
      actions: [
        Stack(
          children: [
            Container(
              margin: const EdgeInsets.only(right: 4),
              child: IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: _showNotificationDrawer,
                tooltip: t.notifications ?? 'Notifications',
              ),
            ),
            if (_notificationCount > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(10)),
                  constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                  child: Text(
                    '$_notificationCount',
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
        Container(
          margin: const EdgeInsets.only(right: 8),
          child: IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => context.goNamed(RouteName.login),
            tooltip: t.logout,
          ),
        ),
      ],
    );
  }

  Widget _buildNoUserState(AppLocalizations t) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.green.shade50, Colors.green.shade100],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.agriculture, size: 80, color: Colors.green),
            const SizedBox(height: 16),
            Text(t.noUserDataFound, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent(BuildContext context, AuthSuccess authState, AppLocalizations t) {
    final user = authState.authResponse.user;
    final greeting = _getTimeBasedGreeting(context);
    final emoji = _getGreetingEmoji();

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.green.shade50, Colors.white, Colors.green.shade50],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(_cardPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeCard(greeting!, emoji, user),
              const SizedBox(height: 30),
              _buildQuickActions(context, t, user.role),
              const SizedBox(height: _largeSpacing),
              _buildCategoriesHeader(t),
              const SizedBox(height: 20),
              Expanded(child: _buildCategoriesSection(context, t)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(String greeting, String emoji, dynamic user) {
    return Container(
      padding: const EdgeInsets.all(_cardPadding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade700, Colors.green.shade500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.green.shade200, blurRadius: 10, offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 32)),
              const SizedBox(width: _standardSpacing),
              Flexible(
                child: Text(
                  greeting,
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(user.email, style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.9)), overflow: TextOverflow.ellipsis),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
            child: Text(user.role, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, AppLocalizations t, String role) {
    final isFarmer = _isPrivilegedRole(role);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.orange.shade100, borderRadius: BorderRadius.circular(12)),
              child: Icon(Icons.flash_on, color: Colors.orange.shade800, size: _iconSize),
            ),
            const SizedBox(width: _standardSpacing),
            Text(
              t.quickActions ?? 'Quick Actions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[800]),
            ),
          ],
        ),
        const SizedBox(height: _standardSpacing),
        SizedBox(
          height: 95,
          child: ListView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            children: [
              if (isFarmer) ...[
                _buildQuickActionCard(
                  context: context,
                  icon: Icons.inventory_2_rounded,
                  label: t.myProducts,
                  color: Colors.blue,
                  onTap: () => context.pushNamed(RouteName.myProducts),
                ),
                const SizedBox(width: _standardSpacing),
                _buildQuickActionCard(
                  context: context,
                  icon: Icons.add_box_outlined,
                  label: t.postProduct,
                  color: Colors.green,
                  onTap: () => context.pushNamed(RouteName.createProduct),
                ),
                const SizedBox(width: _standardSpacing),
              ],
              _buildQuickActionCard(
                context: context,
                icon: Icons.shopping_bag_outlined,
                label: t.myOrders ?? 'My Orders',
                color: Colors.deepOrange,
                onTap: () => context.pushNamed(RouteName.myOrders),
              ),
              const SizedBox(width: _standardSpacing),
              if (isFarmer) ...[
                _buildQuickActionCard(
                  context: context,
                  icon: Icons.receipt_long_outlined,
                  label: t.ordersReceived ?? 'Orders Received',
                  color: Colors.teal,
                  onTap: () => context.pushNamed(RouteName.farmerOrders),
                ),
                const SizedBox(width: _standardSpacing),
              ],
              _buildQuickActionCard(
                context: context,
                icon: Icons.store_outlined,
                label: t.marketplace ?? 'Marketplace',
                color: Colors.purple,
                onTap: () => context.pushNamed(RouteName.product),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionCard({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 70,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(_borderRadius),
          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 4),
            Flexible(
              child: Text(
                label,
                style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesHeader(AppLocalizations t) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.green.shade100, borderRadius: BorderRadius.circular(12)),
          child: Icon(Icons.category, color: Colors.green.shade800, size: _iconSize),
        ),
        const SizedBox(width: _standardSpacing),
        Text(t.exploreCategories, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)),
      ],
    );
  }

  Widget _buildCategoriesSection(BuildContext context, AppLocalizations t) {
    return BlocBuilder<CategoryBloc, CategoryState>(
      builder: (context, state) {
        if (state is CategoryLoading) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.green)),
                SizedBox(height: 16),
                Text('Loading amazing categories...'),
              ],
            ),
          );
        }
        if (state is CategoryLoaded) return _buildModernCategoryGrid(context, state);
        if (state is SubCategoryLoaded) return _buildModernSubCategoryList(context, state);
        if (state is CategoryError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 60, color: Colors.orange.shade700),
                const SizedBox(height: 16),
                Text(state.message, style: TextStyle(color: Colors.grey.shade700, fontSize: 16)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.read<CategoryBloc>().add(LoadCategories()),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }
        return Center(child: Text(t.noCategoriesAvailable));
      },
    );
  }

  Widget _buildModernCategoryGrid(BuildContext context, CategoryLoaded state) {
    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.75,
      ),
      itemCount: state.categories.length,
      itemBuilder: (context, index) {
        final category = state.categories[index];
        final colors = [
          [Colors.green.shade600, Colors.lightGreen.shade400],
          [Colors.orange.shade600, Colors.deepOrange.shade400],
          [Colors.blue.shade600, Colors.lightBlue.shade400],
          [Colors.purple.shade600, Colors.deepPurple.shade400],
          [Colors.teal.shade600, Colors.cyan.shade400],
          [Colors.pink.shade600, Colors.pinkAccent],
        ];
        final gradientColors = colors[index % colors.length];
        return _buildCategoryCard(context: context, category: category, gradientColors: gradientColors);
      },
    );
  }

  Widget _buildCategoryCard({
    required BuildContext context,
    required dynamic category,
    required List<Color> gradientColors,
  }) {
    return GestureDetector(
      onTap: () => context.read<CategoryBloc>().add(LoadSubCategories(category.id)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [gradientColors[0], gradientColors[1]],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: gradientColors[0].withOpacity(0.2), blurRadius: 6, offset: const Offset(0, 3))],
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                  child: Icon(_getCategoryIcon(category.name), color: Colors.white, size: 28),
                ),
                const SizedBox(height: 8),
                Text(
                  category.name,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernSubCategoryList(BuildContext context, SubCategoryLoaded state) {
    final t = AppLocalizations.of(context)!;
    final subs = state.subCategories;

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 20),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => context.read<CategoryBloc>().add(LoadCategories()),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [Colors.green.shade600, Colors.green.shade800]),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.green.shade200, blurRadius: 8, offset: const Offset(0, 4))],
                  ),
                  child: const Icon(Icons.arrow_back, color: Colors.white),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(t.backToCategories, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87)),
              ),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.orange.shade100, borderRadius: BorderRadius.circular(12)),
                child: Icon(Icons.grid_view, color: Colors.orange.shade700),
              ),
              const SizedBox(width: 12),
              Text('Available Subcategories', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey.shade800)),
            ],
          ),
        ),
        Expanded(
          child: subs.isEmpty
              ? _buildEmptySubcategoriesState(t)
              : GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.1,
                  ),
                  itemCount: subs.length,
                  itemBuilder: (context, index) {
                    final sub = subs[index];
                    final colors = [
                      [Colors.blue, Colors.lightBlue],
                      [Colors.purple, Colors.deepPurple],
                      [Colors.teal, Colors.cyan],
                      [Colors.pink, Colors.pinkAccent],
                    ];
                    final gradientColors = colors[index % colors.length];
                    return _buildSubCategoryCard(context: context, subCategory: sub, gradientColors: gradientColors);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildSubCategoryCard({
    required BuildContext context,
    required dynamic subCategory,
    required List<Color> gradientColors,
  }) {
    return GestureDetector(
      onTap: () => context.pushNamed(RouteName.product, extra: subCategory.id),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [gradientColors[0], gradientColors[1]],
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: gradientColors[0].withOpacity(0.2), blurRadius: 4, offset: const Offset(0, 2))],
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
                  child: Icon(_getSubCategoryIcon(subCategory.name), color: Colors.white, size: 22),
                ),
                const SizedBox(height: 6),
                Text(
                  subCategory.name,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.white),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'grains & cereals':
        return Icons.grass;
      case 'fresh produce':
        return Icons.eco;
      case 'specialty crops & cash crops':
        return Icons.local_florist;
      default:
        return Icons.category;
    }
  }

  IconData _getSubCategoryIcon(String subCategoryName) {
    final name = subCategoryName.toLowerCase();
    if (name.contains('vegetable')) return Icons.energy_savings_leaf_outlined;
    if (name.contains('fruit')) return Icons.apple;
    if (name.contains('grain')) return Icons.grass;
    if (name.contains('coffee')) return Icons.coffee;
    if (name.contains('spice')) return Icons.restaurant;
    return Icons.category;
  }

  Widget _buildEmptySubcategoriesState(AppLocalizations t) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.category_outlined, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text('No subcategories available', style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
          const SizedBox(height: 8),
          Text('Check back later for more options', style: TextStyle(fontSize: 14, color: Colors.grey.shade500)),
        ],
      ),
    );
  }

  Drawer _buildDrawer(BuildContext context, AppLocalizations t) {
    final authState = context.read<AuthBloc>().state;
    String role = "";
    String userId = "";

    if (authState is AuthSuccess) {
      role = authState.authResponse.user.role;
      userId = authState.authResponse.user.id;
    }

    final isFarmer = _isPrivilegedRole(role);

    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.green.shade50, Colors.white],
          ),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            _buildDrawerHeader(t),
            _buildDrawerItem(context: context, icon: Icons.home, title: t.home, route: RouteName.home, color: Colors.green),
            _buildDrawerItem(context: context, icon: Icons.store, title: t.products, route: RouteName.product, color: Colors.orange),
            if (isFarmer) ...[
              _buildDrawerItem(context: context, icon: Icons.inventory_2, title: t.myProducts, route: RouteName.myProducts, color: Colors.blue.shade700),
              _buildDrawerItem(context: context, icon: Icons.add_box, title: t.postProduct, route: RouteName.createProduct, color: Colors.green.shade700),
            ],
            _buildDrawerItem(context: context, icon: Icons.shopping_cart, title: t.myOrders ?? 'My Orders', route: RouteName.myOrders, color: Colors.deepOrange.shade700),
            if (isFarmer)
              _buildDrawerItem(context: context, icon: Icons.receipt_long, title: t.ordersReceived ?? 'Orders Received', route: RouteName.farmerOrders, color: Colors.teal),
            _buildDrawerItem(context: context, icon: Icons.chat_bubble_outline, title: 'AI Chatbot', route: RouteName.aiRecommendation, color: Colors.green.shade600),
            const Divider(),
            _buildRoleRequestSection(context, t, role, userId),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerHeader(AppLocalizations t) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.green.shade700, Colors.green.shade500]),
      ),
      child: DrawerHeader(
        decoration: const BoxDecoration(color: Colors.transparent),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const Icon(Icons.agriculture, color: Colors.white, size: 40),
            const SizedBox(height: 8),
            Text(t.appTitle, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(t.farmingCompanion, style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String route,
    required Color color,
  }) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: Icon(Icons.chevron_right, color: color),
      onTap: () {
        Navigator.pop(context);
        context.pushNamed(route);
      },
    );
  }

  Widget _buildRoleRequestSection(BuildContext context, AppLocalizations t, String role, String userId) {
    if (role == 'AGENT') {
      return _buildStatusCard(
        icon: Icons.handshake,
        title: t.roleAgentActive,
        statusLabel: t.activeStatus,
        backgroundColor: Colors.green.shade100,
        iconColor: Colors.green,
        statusColor: Colors.green,
      );
    }
    if (role == 'ADMIN') {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(color: Colors.blue.shade100, borderRadius: BorderRadius.circular(12)),
        child: const Row(
          children: [
            Icon(Icons.admin_panel_settings, color: Colors.blue),
            SizedBox(width: 12),
            Expanded(child: Text('Administrator Access', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14))),
            Icon(Icons.verified, color: Colors.blue, size: 20),
          ],
        ),
      );
    }
    if (_cachedRequestStatus == 'PENDING') return _buildPendingStatusCard(context, t);
    if (_cachedRequestStatus == 'APPROVED') {
      return _buildStatusCard(
        icon: Icons.check_circle,
        title: t.roleRequestApproved ?? 'Role Request Approved!',
        statusLabel: t.activeStatus,
        backgroundColor: Colors.green.shade100,
        iconColor: Colors.green,
        statusColor: Colors.green,
      );
    }
    if (_cachedRequestStatus == 'REJECTED') return _buildRejectedStatusCard(context, t);
    return _buildRequestButton(context, t, userId);
  }

  Widget _buildStatusCard({
    required IconData icon,
    required String title,
    required String statusLabel,
    required Color backgroundColor,
    required Color iconColor,
    required Color statusColor,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: backgroundColor, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Icon(icon, color: iconColor),
          const SizedBox(width: 12),
          Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(color: statusColor, borderRadius: BorderRadius.circular(12)),
            child: Text(statusLabel, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingStatusCard(BuildContext context, AppLocalizations t) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: Colors.orange.shade100, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          const Icon(Icons.pending, color: Colors.orange),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t.roleRequestPending ?? 'Role Request Pending', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                Text('${t.statusLabel ?? 'Status'}: PENDING', style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(12)),
            child: const Text('PENDING', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildRejectedStatusCard(BuildContext context, AppLocalizations t) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.cancel, color: Colors.red, size: 20),
              const SizedBox(width: 12),
              Expanded(child: Text(t.roleRequestRejected ?? 'Request Rejected', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14))),
            ],
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 32),
            child: TextButton(
              onPressed: () {
                final authState = context.read<AuthBloc>().state;
                if (authState is AuthSuccess) {
                  final user = authState.authResponse.user;
                  Navigator.pop(context);
                  context.pushNamed(RouteName.roleRequest, extra: user);
                }
              },
              style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(0, 30)),
              child: Text(t.reapply ?? 'Reapply', style: TextStyle(fontSize: 12, color: Colors.green.shade700, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestButton(BuildContext context, AppLocalizations t, String userId) {
    if (userId.isEmpty) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: Icon(Icons.handshake, color: Colors.green.shade700),
        title: Text(t.requestAgentRole ?? 'Request Agent Role', style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.black87)),
        trailing: Icon(Icons.arrow_forward, color: Colors.green.shade700),
        onTap: () {
          final authState = context.read<AuthBloc>().state;
          if (authState is AuthSuccess) {
            final user = authState.authResponse.user;
            Navigator.pop(context);
            context.pushNamed(RouteName.roleRequest, extra: user);
          }
        },
      ),
    );
  }
}