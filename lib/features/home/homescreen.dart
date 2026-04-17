import 'package:agrilink/core/config/routes/route_name.dart';
import 'package:agrilink/core/localization/generated/app_localizations.dart';
import 'package:agrilink/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:agrilink/features/auth/presentation/bloc/auth_state.dart';
import 'package:agrilink/features/category/presentation/bloc/categories_bloc.dart';
import 'package:agrilink/features/category/presentation/bloc/categories_event.dart';
import 'package:agrilink/features/category/presentation/bloc/categories_state.dart';
import 'package:agrilink/features/role_request/presentation/bloc/role_request_bloc.dart';
import 'package:agrilink/features/role_request/presentation/bloc/role_request_event.dart';
import 'package:agrilink/features/role_request/presentation/bloc/role_request_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  String? _getTimeBasedGreeting(BuildContext context) {
    final hour = DateTime.now().hour;
    final t = AppLocalizations.of(context);

    if (hour < 12) {
      return t?.goodMorning;
    } else if (hour < 17) {
      return t?.goodAfternoon;
    } else {
      return t?.goodEvening;
    }
  }

  String _getGreetingEmoji() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return '🌅';
    } else if (hour < 17) {
      return '☀️';
    } else {
      return '🌙';
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    return Scaffold(
      drawer: _buildDrawer(context),
      appBar: AppBar(
        title: Text(
          t!.appTitle,
          style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          // Notification Icon
          Container(
            margin: const EdgeInsets.only(right: 4),
            child: IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () {
                // Navigate to notifications
              },
              tooltip: 'Notifications',
            ),
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
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          if (authState is! AuthSuccess) {
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
                    const Icon(
                      Icons.agriculture,
                      size: 80,
                      color: Colors.green,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      t!.noUserDataFound,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            );
          }

          final user = authState.authResponse.user;
          final greeting = _getTimeBasedGreeting(context);
          final emoji = _getGreetingEmoji();

          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.green.shade50,
                  Colors.white,
                  Colors.green.shade50,
                ],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.green.shade700,
                            Colors.green.shade500,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.shade200,
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(emoji, style: const TextStyle(fontSize: 32)),
                              const SizedBox(width: 12),
                              Text(
                                greeting!,
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            user.email,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              user.role,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Quick Actions Section
                    _buildQuickActions(context, t, user.role),

                    const SizedBox(height: 24),

                    // Categories Section Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.category,
                            color: Colors.green.shade800,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          t.exploreCategories,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 2,
                      width: 60,
                      color: Colors.green.shade300,
                    ),
                    const SizedBox(height: 20),

                    // Categories List
                    Expanded(
                      child: BlocBuilder<CategoryBloc, CategoryState>(
                        builder: (context, state) {
                          if (state is CategoryLoading) {
                            return const Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.green,
                                ),
                              ),
                            );
                          }

                          if (state is CategoryLoaded) {
                            return _buildCategoryList(context, state);
                          }

                          if (state is SubCategoryLoaded) {
                            return _buildSubCategoryList(context, state);
                          }

                          if (state is CategoryError) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    size: 60,
                                    color: Colors.orange.shade700,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    state.message,
                                    style: TextStyle(
                                      color: Colors.grey.shade700,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          return Center(child: Text(t.noCategoriesAvailable));
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Quick Actions Section with Product Management
  Widget _buildQuickActions(
    BuildContext context,
    AppLocalizations t,
    String role,
  ) {
    final isFarmer = role == 'FARMER' || role == 'AGENT' || role == 'ADMIN';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.flash_on,
                color: Colors.orange.shade800,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              // My Products (For Farmers - View their products)
              if (isFarmer)
                _buildQuickActionCard(
                  context: context,
                  icon: Icons.inventory_2_rounded,
                  label: 'My Products',
                  color: Colors.blue,
                  onTap: () => context.pushNamed(RouteName.myProducts),
                ),
              if (isFarmer) const SizedBox(width: 12),

              // Post Product (Create new product)
              if (isFarmer)
                _buildQuickActionCard(
                  context: context,
                  icon: Icons.add_box_outlined,
                  label: 'Post Product',
                  color: Colors.green,
                  onTap: () => context.pushNamed(RouteName.createProduct),
                ),
              if (isFarmer) const SizedBox(width: 12),

              // My Orders (Buyer)
              _buildQuickActionCard(
                context: context,
                icon: Icons.shopping_bag_outlined,
                label: 'My Orders',
                color: Colors.deepOrange,
                onTap: () => context.pushNamed(RouteName.myOrders),
              ),
              const SizedBox(width: 12),

              // Farmer Orders (For Farmers - Orders received)
              if (isFarmer)
                _buildQuickActionCard(
                  context: context,
                  icon: Icons.receipt_long_outlined,
                  label: 'Orders Received',
                  color: Colors.teal,
                  onTap: () => context.pushNamed(RouteName.farmerOrders),
                ),
              if (isFarmer) const SizedBox(width: 12),

              // Marketplace (Browse products)
              _buildQuickActionCard(
                context: context,
                icon: Icons.store_outlined,
                label: 'Marketplace',
                color: Colors.purple,
                onTap: () => context.pushNamed(RouteName.product),
              ),
              const SizedBox(width: 12),

              // AI Advisor
              _buildQuickActionCard(
                context: context,
                icon: Icons.psychology_outlined,
                label: 'AI Advisor',
                color: Colors.orange,
                onTap: () => context.pushNamed(RouteName.aiRecommendation),
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
        width: 80,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Drawer with Product Management
  Drawer _buildDrawer(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final t = AppLocalizations.of(context);

    String role = "";
    if (authState is AuthSuccess) {
      role = authState.authResponse.user.role;
    }

    final isFarmer = role == 'FARMER' || role == 'AGENT' || role == 'ADMIN';

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
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green.shade700, Colors.green.shade500],
                ),
              ),
              child: DrawerHeader(
                decoration: const BoxDecoration(color: Colors.green),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Icon(
                      Icons.agriculture,
                      color: Colors.white,
                      size: 40,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      t!.appTitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      t.farmingCompanion,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _buildDrawerItem(
              context: context,
              icon: Icons.home,
              title: t!.home,
              route: RouteName.home,
              color: Colors.green,
            ),
            _buildDrawerItem(
              context: context,
              icon: Icons.store,
              title: t.products,
              route: RouteName.product,
              color: Colors.orange,
            ),
            // My Products - Only show for farmers/agents/admins
            if (isFarmer)
              _buildDrawerItem(
                context: context,
                icon: Icons.inventory_2,
                title: t.myProducts,
                route: RouteName.myProducts,
                color: Colors.blue.shade700,
              ),
            // Post Product - Only show for farmers/agents/admins
            if (isFarmer)
              _buildDrawerItem(
                context: context,
                icon: Icons.add_box,
                title: t.postProduct,
                route: RouteName.createProduct,
                color: Colors.green.shade700,
              ),
            _buildDrawerItem(
              context: context,
              icon: Icons.shopping_cart,
              title: 'My Orders',
              route: RouteName.myOrders,
              color: Colors.deepOrange.shade700,
            ),
            // Farmer Orders - Only show for farmers/agents/admins
            if (isFarmer)
              _buildDrawerItem(
                context: context,
                icon: Icons.receipt_long,
                title: 'Orders Received',
                route: RouteName.farmerOrders,
                color: Colors.teal,
              ),
            _buildDrawerItem(
              context: context,
              icon: Icons.psychology,
              title: t.aiAdvisory,
              route: RouteName.aiRecommendation,
              color: Colors.purple.shade700,
            ),
            const Divider(),

            // Show role status / request only for non-AGENT & non-ADMIN
            if (role == 'AGENT')
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.handshake, color: Colors.green),
                    const SizedBox(width: 12),
                    Text(
                      t.roleAgentActive,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        t.activeStatus,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else if (role != 'ADMIN')
              BlocConsumer<RoleRequestBloc, RoleRequestState>(
                listener: (context, state) {
                  if (state is RoleRequestError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: Colors.red,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                  if (state is RoleRequestSuccess) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${t.requestStatus}: ${state.status}'),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  String title = t.joinAsAgent;
                  bool isLoading = false;

                  if (state is RoleRequestLoading) {
                    title = t.sendingRequest;
                    isLoading = true;
                  } else if (state is RoleRequestSuccess) {
                    title = '${t.statusLabel}: ${state.status}';
                  }

                  return Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    child: ListTile(
                      leading: Icon(
                        Icons.handshake,
                        color: Colors.green.shade700,
                      ),
                      title: Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: isLoading ? Colors.grey : Colors.black87,
                        ),
                      ),
                      trailing: isLoading
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.green.shade700,
                                ),
                              ),
                            )
                          : Icon(
                              Icons.arrow_forward,
                              color: Colors.green.shade700,
                            ),
                      onTap: isLoading
                          ? null
                          : () {
                              context.read<RoleRequestBloc>().add(
                                CreateRoleRequestEvent(),
                              );
                            },
                    ),
                  );
                },
              ),
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
      onTap: () => context.pushNamed(route),
    );
  }

  /// Category List
  Widget _buildCategoryList(BuildContext context, CategoryLoaded state) {
    return ListView.builder(
      itemCount: state.categories.length,
      itemBuilder: (context, index) {
        final category = state.categories[index];
        final colors = [Colors.green.shade100, Colors.green.shade50];

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [colors[index % colors.length], Colors.white],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.green.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.category, color: Colors.green.shade800),
                ),
                title: Text(
                  category.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                trailing: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.shade200,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.green.shade800,
                  ),
                ),
                onTap: () {
                  context.read<CategoryBloc>().add(
                    LoadSubCategories(category.id),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  /// SubCategory List
  Widget _buildSubCategoryList(BuildContext context, SubCategoryLoaded state) {
    final t = AppLocalizations.of(context);
    final subs = state.subCategories;

    if (subs.isEmpty) {
      return Column(
        children: [
          _buildBackButton(context),
          const SizedBox(height: 20),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox, size: 80, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    t!.noSubcategories,
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        _buildBackButton(context),
        const SizedBox(height: 20),
        Expanded(
          child: ListView.builder(
            itemCount: subs.length,
            itemBuilder: (context, index) {
              final sub = subs[index];

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  color: Colors.green.shade50,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.green.shade200,
                        width: 1,
                      ),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.green.shade200,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.grass, color: Colors.green.shade800),
                      ),
                      title: Text(
                        sub.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      onTap: () {
                        // Navigate to products by subcategory
                        context.pushNamed(RouteName.product, extra: sub.id);
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBackButton(BuildContext context) {
    final t = AppLocalizations.of(context);

    return ElevatedButton.icon(
      onPressed: () {
        context.read<CategoryBloc>().add(LoadCategories());
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        elevation: 0,
      ),
      icon: const Icon(Icons.arrow_back, size: 20),
      label: Text(
        t!.backToCategories,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    );
  }
}
