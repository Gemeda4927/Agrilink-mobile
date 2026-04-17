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
import 'package:agrilink/features/cart/presentation/cart.dart';
import 'package:agrilink/features/cart/presentation/checkout_screen.dart';
import 'package:agrilink/features/cart/presentation/order_confirmation_screen.dart';
import 'package:agrilink/features/chat/presentation/chat.dart';
import 'package:agrilink/features/home/homescreen.dart';
import 'package:agrilink/features/order/presentation/screens/my_orders_screen.dart';
import 'package:agrilink/features/product/FarmerProfilePage.dart';
import 'package:agrilink/features/product/presentation/create_product_page.dart';
import 'package:agrilink/features/product/presentation/product_details_page.dart';
import 'package:agrilink/features/product/product.dart';
import 'package:agrilink/features/profile/presentation/profile.dart';
import 'package:agrilink/features/profile/presentation/view_profile.dart';
import 'package:agrilink/features/profile/presentation/update_profile_screen.dart';
import 'package:agrilink/features/profile/data/model/ProfileModel.dart';
import 'package:agrilink/features/recommendation/presentation/ai_recommendation_screen.dart';
import 'package:agrilink/features/registration/presentation/screen/register_page.dart';
import 'package:agrilink/injector.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// ================= PLACEHOLDER SCREEN =================
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

// ================= NAVIGATION KEYS =================
final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey =
    GlobalKey<NavigatorState>();

// ================= ROUTER CONFIGURATION =================
final GoRouter appRouter = GoRouter(
  debugLogDiagnostics: true,
  navigatorKey: _rootNavigatorKey,
  initialLocation: RouteName.splash,
  routes: [
    // ================= PUBLIC ROUTES (Outside Shell) =================

    GoRoute(
      path: RouteName.splash,
      name: RouteName.splash,
      builder: (context, state) => const SplashScreen(),
    ),

    // Authentication Routes
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

    GoRoute(
      path: RouteName.createProduct,
      name: RouteName.createProduct,
      builder: (context, state) => const CreateProductPage(),
    ),

    // Chat Route
    GoRoute(
      path: RouteName.chat,
      name: RouteName.chat,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;

        if (extra == null || extra['receiverId'] == null) {
          return const Scaffold(
            body: Center(child: Text("Receiver ID not provided")),
          );
        }

        final receiverId = extra['receiverId'].toString();
        final receiverName = extra['receiverName']?.toString();
        final conversationId = extra['conversationId']?.toString();

        return ChatScreen(
          receiverId: receiverId,
          receiverName: receiverName,
          conversationId: conversationId,
        );
      },
    ),

    // Farmer Profile Route
    GoRoute(
      path: RouteName.farmerProfile,
      name: RouteName.farmerProfile,
      builder: (context, state) {
        final farmerId = state.extra as String?;

        if (farmerId == null || farmerId.isEmpty) {
          return const Scaffold(
            body: Center(child: Text("Farmer ID not provided")),
          );
        }

        return FarmerProfilePage(farmerId: farmerId);
      },
    ),

    // My Orders Route (Public - Can be accessed after auth)
    GoRoute(
      path: RouteName.myOrders,
      name: RouteName.myOrders,
      builder: (context, state) => const MyOrdersScreen(),
    ),

    // ================= MAIN APP SHELL (Authenticated Routes) =================
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

            // Redirect to login if not authenticated
            if (user == null) {
              // Use a delayed microtask to avoid navigation during build
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (context.mounted) {
                  context.go(RouteName.login);
                }
              });
              return const SizedBox.shrink();
            }

            // Return BasePage with authenticated child
            return BasePage(user: user, child: child);
          },
        );
      },
      routes: [
        // Home Route
        GoRoute(
          path: RouteName.home,
          name: RouteName.home,
          builder: (context, state) => const HomeScreen(),
        ),

        // Marketplace Route
        GoRoute(
          path: RouteName.product,
          name: RouteName.product,
          builder: (context, state) => const ProductPage(),
        ),

        // ================= PRODUCT DETAILS ROUTE =================
        GoRoute(
          path: RouteName.productDetails,
          name: RouteName.productDetails,
          builder: (context, state) {
            final product = state.extra;
            if (product == null) {
              return const Scaffold(
                body: Center(child: Text("Product data not provided")),
              );
            }
            return ProductDetailsPage(product: product);
          },
        ),

        // Dashboard/Registration Route
        GoRoute(
          path: RouteName.dashboard,
          name: RouteName.dashboard,
          builder: (context, state) => const RegisterPage(),
        ),

        // AI Recommendation Route
        GoRoute(
          path: RouteName.aiRecommendation,
          name: RouteName.aiRecommendation,
          builder: (context, state) => AIRecommendationScreen(),
        ),

        // Profile Creation Route
        GoRoute(
          path: RouteName.profile,
          name: RouteName.profile,
          builder: (context, state) => const CreateProfileScreen(),
        ),

        // View Profile Route
        GoRoute(
          path: RouteName.viewProfile,
          name: RouteName.viewProfile,
          builder: (context, state) => const ViewProfileScreen(),
        ),

        // Update Profile Route
        GoRoute(
          path: RouteName.updateProfile,
          name: RouteName.updateProfile,
          builder: (context, state) {
            final profile = state.extra as GetProfileModel;
            return UpdateProfileScreen(existingProfile: profile);
          },
        ),

        // Cart Route
        GoRoute(
          path: RouteName.cart,
          name: RouteName.cart,
          builder: (context, state) => const CartScreen(),
        ),

        // Checkout Route
        GoRoute(
          path: RouteName.checkout,
          name: RouteName.checkout,
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>?;
            return CheckoutScreen(
              cartItems: extra?['cartItems'] ?? [],
              totalPrice: extra?['totalPrice'] ?? 0.0,
              totalItems: extra?['totalItems'] ?? 0,
            );
          },
        ),

        // Order Confirmation Route
        GoRoute(
          path: RouteName.orderConfirmation,
          name: RouteName.orderConfirmation,
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>?;
            return OrderConfirmationScreen(
              orderId: extra?['orderId'] ?? '',
              amount: extra?['amount'] ?? 0.0,
              paymentMethod: extra?['paymentMethod'] ?? '',
            );
          },
        ),

        // Item Details Route
        GoRoute(
          path: RouteName.itemDetails,
          name: RouteName.itemDetails,
          builder: (context, state) =>
              const PlaceholderScreen(title: "Item Details"),
        ),

        // Category Details Route
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