import 'package:agrilink/core/config/routes/route_name.dart';
import 'package:agrilink/features/auth/domain/entities/auth_user.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BasePage extends StatefulWidget {
  const BasePage({super.key, required this.child, required this.user});

  final Widget child;
  final AuthUserEntity user;

  @override
  State<BasePage> createState() => _BasePageState();
}

class _BasePageState extends State<BasePage> {
  // Build bottom navigation items dynamically based on user role
  List<BottomNavigationBarItem> _buildNavItems() {
    final items = <BottomNavigationBarItem>[
      const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
      const BottomNavigationBarItem(
        icon: Icon(Icons.store),
        label: 'Product', // Changed from 'Marketplace' to 'Product'
      ),
    ];

    // Agent-only tab
    if (widget.user.role == "AGENT") {
      items.add(
        const BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
      );
    }

    items.add(
      const BottomNavigationBarItem(
        icon: Icon(Icons.auto_awesome),
        label: 'Recommendation',
      ),
    );

    // ===== PROFILE TAB UNCOMMENTED =====
    items.add(
      const BottomNavigationBarItem(
        icon: Icon(Icons.person),
        label: 'Profile',
      ),
    );

    return items;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const Drawer(),
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        items: _buildNavItems(),
        currentIndex: _getCurrentIndex(context),
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          final routeName = _convertIndexToRouteName(index);
          context.go(routeName);
        },
      ),
    );
  }

  int _getCurrentIndex(BuildContext context) {
    final route = GoRouterState.of(context).uri.toString();

    if (route.startsWith(RouteName.home)) return 0;
    if (route.startsWith(RouteName.product)) return 1;

    if (widget.user.role == "AGENT") {
      // Agent role indices
      if (route.startsWith(RouteName.dashboard)) return 2;
      if (route.startsWith(RouteName.aiRecommendation)) return 3;
      // Profile tab at index 4
      if (route.startsWith(RouteName.viewProfile) || 
          route.startsWith(RouteName.profile)) return 4;
    } else {
      // Regular user indices
      if (route.startsWith(RouteName.aiRecommendation)) return 2;
      // Profile tab at index 3
      if (route.startsWith(RouteName.viewProfile) || 
          route.startsWith(RouteName.profile)) return 3;
    }

    return 0;
  }

  String _convertIndexToRouteName(int index) {
    if (widget.user.role == "AGENT") {
      switch (index) {
        case 0:
          return RouteName.home;
        case 1:
          return RouteName.product; // Updated here as well
        case 2:
          return RouteName.dashboard;
        case 3:
          return RouteName.aiRecommendation;
        case 4:
          // Navigate to viewProfile instead of profile creation
          return RouteName.viewProfile;
        default:
          return RouteName.home;
      }
    } else {
      switch (index) {
        case 0:
          return RouteName.home;
        case 1:
          return RouteName.product; // Updated here
        case 2:
          return RouteName.aiRecommendation;
        case 3:
          // Navigate to viewProfile instead of profile creation
          return RouteName.viewProfile;
        default:
          return RouteName.home;
      }
    }
  }
}