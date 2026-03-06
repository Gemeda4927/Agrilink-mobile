import 'package:agrilink/base_page.dart';
import 'package:agrilink/core/config/routes/route_name.dart';
import 'package:agrilink/features/SplashScreen/splash_page.dart';
import 'package:agrilink/features/auth/presentation/login_page.dart';
import 'package:agrilink/features/auth/presentation/signup_page.dart';
import 'package:agrilink/features/auth/presentation/forgot_password_page.dart';
import 'package:agrilink/features/auth/presentation/resetPassword.dart';
import 'package:agrilink/features/auth/presentation/otp_verify_page.dart';
import 'package:agrilink/features/home/homescreen.dart';
import 'package:agrilink/features/marketplace/marketplace.dart';
import 'package:agrilink/features/recommendation/aiRecommendation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PlaceholderScreen extends StatelessWidget {
  final String title;

  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text(title)),
    );
  }
}

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey =
    GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  debugLogDiagnostics: true,
  navigatorKey: _rootNavigatorKey,
  initialLocation: RouteName.splash,
  routes: [
    /// SPLASH
    GoRoute(
      path: RouteName.splash,
      name: RouteName.splash,
      builder: (context, state) => SplashScreen(),
    ),

    /// LOGIN
    GoRoute(
      path: RouteName.login,
      name: RouteName.login,
      builder: (context, state) => const LoginPage(),
    ),

    /// SIGNUP
    GoRoute(
      path: RouteName.signup,
      name: RouteName.signup,
      builder: (context, state) => const SignUpPage(),
    ),

    /// FORGOT PASSWORD
    GoRoute(
      path: RouteName.forgotPassword,
      name: RouteName.forgotPassword,
      builder: (context, state) => const ForgotPasswordPage(),
    ),

    /// VERIFY OTP
    GoRoute(
      path: RouteName.verifyOtp,
      name: RouteName.verifyOtp,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        final identifier = extra['identifier'] ?? '';
        final purpose = extra['purpose'] ?? 'SIGNUP';

        return VerifyOtpPage(identifier: identifier, purpose: purpose);
      },
    ),

    /// RESET PASSWORD
    GoRoute(
      path: RouteName.resetPassword,
      name: RouteName.resetPassword,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;

        return ResetPasswordPage(extra: extra);
      },
    ),

    /// SHELL ROUTE (BOTTOM NAVIGATION)
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return BasePage(child: child);
      },
      routes: [
        /// HOME
        GoRoute(
          path: RouteName.home,
          name: RouteName.home,
          builder: (context, state) => const HomeScreen(),
        ),

        GoRoute(
          path: RouteName.marketplace,
          name: RouteName.marketplace,
          builder: (context, state) => MarketplaceScreen(),
        ),

        /// CHAT
        GoRoute(
          path: RouteName.aiRecommendation,
          name: RouteName.aiRecommendation,
          builder: (context, state) => AIRecommendationScreen(),
        ),

        /// PROFILE
        GoRoute(
          path: RouteName.profile,
          name: RouteName.profile,
          builder: (context, state) =>
              const PlaceholderScreen(title: "Profile"),
        ),

        /// CART
        GoRoute(
          path: RouteName.cart,
          name: RouteName.cart,
          builder: (context, state) => const PlaceholderScreen(title: "Cart"),
        ),

        /// ITEM DETAILS
        GoRoute(
          path: RouteName.itemDetails,
          name: RouteName.itemDetails,
          builder: (context, state) =>
              const PlaceholderScreen(title: "Item Details"),
        ),

        /// CATEGORY DETAILS
        GoRoute(
          path: RouteName.categoryDetails,
          name: RouteName.categoryDetails,
          builder: (context, state) =>
              const PlaceholderScreen(title: "Category Details"),
        ),
      ],
    ),
  ],
);
