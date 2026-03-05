import 'package:agrilink/features/SplashScreen/splash_page.dart';
import 'package:agrilink/features/auth/presentation/login_page.dart';
import 'package:agrilink/features/home/homescreen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'route_name.dart';

// Placeholder screens
class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text('Screen: $title')),
    );
  }
}

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  debugLogDiagnostics: true,
  navigatorKey: _rootNavigatorKey,
  initialLocation: RouteName.splash,
  routes: [
    GoRoute(
      path: RouteName.splash,
      name: RouteName.splash,
      builder: (context, state) => SplashScreen(),
    ),
    GoRoute(
      path: RouteName.login,
      name: RouteName.login,
      builder: (context, state) => LoginPage(),
    ),
    GoRoute(
      path: RouteName.signup,
      name: RouteName.signup,
      builder: (context, state) => const PlaceholderScreen(title: 'Signup'),
    ),
    GoRoute(
      path: RouteName.todo,
      name: RouteName.todo,
      builder: (context, state) => const PlaceholderScreen(title: 'Todo'),
    ),
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) => Scaffold(body: child),
      routes: [
        GoRoute(
          path: RouteName.home,
          name: RouteName.home,
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: RouteName.wishlist,
          name: RouteName.wishlist,
          builder: (context, state) => const PlaceholderScreen(title: 'Wishlist'),
        ),
        GoRoute(
          path: RouteName.chat,
          name: RouteName.chat,
          builder: (context, state) => const PlaceholderScreen(title: 'Chat'),
        ),
        GoRoute(
          path: RouteName.cart,
          name: RouteName.cart,
          builder: (context, state) => const PlaceholderScreen(title: 'Cart'),
        ),
        GoRoute(
          path: RouteName.profile,
          name: RouteName.profile,
          builder: (context, state) => const PlaceholderScreen(title: 'Profile'),
        ),
        GoRoute(
          path: RouteName.itemDetails,
          name: RouteName.itemDetails,
          builder: (context, state) => const PlaceholderScreen(title: 'Item Details'),
        ),
        GoRoute(
          path: RouteName.categoryDetails,
          name: RouteName.categoryDetails,
          builder: (context, state) => const PlaceholderScreen(title: 'Category Details'),
        ),
      ],
    ),
  ],
);