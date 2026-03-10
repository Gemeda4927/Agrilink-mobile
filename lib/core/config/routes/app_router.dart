import 'package:agrilink/base_page.dart';
import 'package:agrilink/core/config/routes/route_name.dart';
import 'package:agrilink/features/SplashScreen/splash_page.dart';
import 'package:agrilink/features/auth/data/service/auth_service.dart';
import 'package:agrilink/features/auth/domain/entities/auth_user.dart';
import 'package:agrilink/features/auth/presentation/login_page.dart';
import 'package:agrilink/features/auth/presentation/signup_page.dart';
import 'package:agrilink/features/auth/presentation/forgot_password_page.dart';
import 'package:agrilink/features/auth/presentation/resetPassword.dart';
import 'package:agrilink/features/auth/presentation/otp_verify_page.dart';
import 'package:agrilink/features/home/homescreen.dart';
import 'package:agrilink/features/marketplace/marketplace.dart';
import 'package:agrilink/features/recommendation/aiRecommendation.dart';
import 'package:agrilink/injector.dart';
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
    GoRoute(
      path: RouteName.splash,
      name: RouteName.splash,
      builder: (context, state) => SplashScreen(),
    ),

    GoRoute(
      path: RouteName.login,
      name: RouteName.login,
      builder: (context, state) => const LoginPage(),
    ),

    GoRoute(
      path: RouteName.signup,
      name: RouteName.signup,
      builder: (context, state) => const SignUpPage(),
    ),

    GoRoute(
      path: RouteName.forgotPassword,
      name: RouteName.forgotPassword,
      builder: (context, state) => const ForgotPasswordPage(),
    ),

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

    GoRoute(
      path: RouteName.resetPassword,
      name: RouteName.resetPassword,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return ResetPasswordPage(extra: extra);
      },
    ),

    /// MAIN APP SHELL
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return FutureBuilder<AuthUserEntity?>(
          future: sl<AuthService>().getLoggedInUser(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final user = snapshot.data;

            /// if user not logged in redirect to login
            if (user == null) {
              return const LoginPage();
            }

            return BasePage(child: child, user: user);
          },
        );
      },
      routes: [
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

        GoRoute(
          path: RouteName.dashboard,
          name: RouteName.dashboard,
          builder: (context, state) =>
              const PlaceholderScreen(title: "Agent Dashboard"),
        ),

        GoRoute(
          path: RouteName.aiRecommendation,
          name: RouteName.aiRecommendation,
          builder: (context, state) => AIRecommendationScreen(),
        ),

        GoRoute(
          path: RouteName.profile,
          name: RouteName.profile,
          builder: (context, state) =>
              const PlaceholderScreen(title: "Profile"),
        ),

        GoRoute(
          path: RouteName.cart,
          name: RouteName.cart,
          builder: (context, state) => const PlaceholderScreen(title: "Cart"),
        ),

        GoRoute(
          path: RouteName.itemDetails,
          name: RouteName.itemDetails,
          builder: (context, state) =>
              const PlaceholderScreen(title: "Item Details"),
        ),

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
