import 'package:agrilink/core/config/routes/route_name.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BasePage extends StatefulWidget {
  const BasePage({super.key, required this.child});
  final Widget child;

  @override
  State<BasePage> createState() => _BasePageState();
}

class _BasePageState extends State<BasePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const Drawer(),
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _getCurrentIndex(context),
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          final routeName = _convertIndexToRouteName(index);
          context.goNamed(routeName);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.store), label: 'Marketplace'),
          BottomNavigationBarItem(icon: Icon(Icons.auto_awesome), label: 'Recommendation'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  int _getCurrentIndex(BuildContext context) {
    final route = GoRouterState.of(context).uri.toString();
    if (route.startsWith(RouteName.home)) return 0;
    if (route.startsWith(RouteName.marketplace)) return 1;
    if (route.startsWith(RouteName.aiRecommendation)) return 2;
    if (route.startsWith(RouteName.profile)) return 3;
    return 0;
  }

  String _convertIndexToRouteName(int index) {
    switch (index) {
      case 0:
        return RouteName.home;
      case 1:
        return RouteName.marketplace;
      case 2:
        return RouteName.aiRecommendation;
      case 3:
        return RouteName.profile;
      default:
        return RouteName.home;
    }
  }
}