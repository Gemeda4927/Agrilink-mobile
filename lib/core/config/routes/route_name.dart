
class RouteName {
  // Auth & Onboarding
  static const String splash = '/splash';
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String verifyOtp = '/verify-otp';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';
  static const String cart = '/cart';
  static const String dashboard = '/dashboard';

  // Checkout & Payment
  static const String checkout = '/checkout';
  static const String payment = '/payment';
  static const String orderConfirmation = '/order-confirmation';

  // Main tabs
  static const String home = '/home';
  static const String product = '/product';
  static const String myProducts = '/my-products';

  // Orders
  static const String myOrders = '/my-orders';
  static const String farmerOrders = '/farmer-orders';

  // Product Management (UI Routes)
  static const String createProduct = '/create-product';
  static const String productDetails = '/product-details/:id'; 
  static const String editProduct = '/edit-product/:id'; 
  static const String productList = '/product-list';

  // AI & Profile
  static const String aiRecommendation = '/recommendation';
  static const String profile = '/profile';
  static const String viewProfile = '/view-profile';
  static const String updateProfile = '/update-profile';
  static const String farmerProfile = '/farmerProfile';

  // Other screens
  static const String todo = '/todo';
  static const String itemDetails = '/itemDetails';
  static const String categoryDetails = '/categoryDetails';
  static const String chat = '/chat';

  // Role Request
  static const String roleRequest = "/role-request";
}
