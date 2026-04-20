import 'package:agrilink/core/config/routes/route_name.dart';
import 'package:agrilink/features/auth/domain/entities/auth_user.dart';
import 'package:agrilink/features/recommendation/presentation/ai_chatbot_floating_button.dart';
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
  List<BottomNavigationBarItem> _buildNavItems() {
    final items = <BottomNavigationBarItem>[
      const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
      const BottomNavigationBarItem(icon: Icon(Icons.store), label: 'Store'),
    ];

    if (widget.user.role == "AGENT") {
      items.add(const BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'));
    }

    items.add(const BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'));
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
        type: BottomNavigationBarType.fixed,
        onTap: (index) => context.go(_convertIndexToRouteName(index)),
      ),
      // No floatingActionButton here - the premium FAB is handled by HomeScreen
    );
  }

  int _getCurrentIndex(BuildContext context) {
    final route = GoRouterState.of(context).uri.toString();

    if (route.startsWith(RouteName.home)) return 0;
    if (route.startsWith(RouteName.product)) return 1;

    if (widget.user.role == "AGENT") {
      if (route.startsWith(RouteName.dashboard)) return 2;
      if (route.startsWith(RouteName.viewProfile) || route.startsWith(RouteName.profile)) return 3;
    } else {
      if (route.startsWith(RouteName.viewProfile) || route.startsWith(RouteName.profile)) return 2;
    }
    return 0;
  }

  String _convertIndexToRouteName(int index) {
    if (widget.user.role == "AGENT") {
      switch (index) {
        case 0: return RouteName.home;
        case 1: return RouteName.product;
        case 2: return RouteName.dashboard;
        case 3: return RouteName.viewProfile;
        default: return RouteName.home;
      }
    } else {
      switch (index) {
        case 0: return RouteName.home;
        case 1: return RouteName.product;
        case 2: return RouteName.viewProfile;
        default: return RouteName.home;
      }
    }
  }
}