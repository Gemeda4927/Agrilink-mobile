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
  static const String ordersReceived = '/farmer-orders';

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

  // ================= MARKET INSIGHT ROUTES =================
  static const String market = '/market';
  static const String submitMarketPrice = '/submit-market-price';
  static const String approvedPrices = '/approved-prices';
  static const String myPriceSubmissions = '/my-price-submissions';
  static const String priceVerification = '/price-verification';
  static const String marketAnalytics = '/market-analytics';
  static const String priceDetails = '/price-details/:id';

  // ================= ADMIN ROUTES =================
  static const String adminPanel = '/admin-panel';
  static const String roleRequests = '/role-requests';
  static const String userManagement = '/user-management';
  static const String systemSettings = '/system-settings';
  static const String reports = '/reports';

  // ================= AGENT ROUTES =================
  static const String agentDashboard = '/agent-dashboard';
  static const String pendingApprovals = '/pending-approvals';
  static const String verificationHistory = '/verification-history';

  // ================= DATA CONTRIBUTOR ROUTES =================
  static const String contributorDashboard = '/contributor-dashboard';
  static const String priceHistory = '/price-history';
  static const String submitBatchPrices = '/submit-batch-prices';

  // Other screens
  static const String todo = '/todo';
  static const String itemDetails = '/itemDetails';
  static const String categoryDetails = '/categoryDetails';
  static const String chat = '/chat';

  // Role Request
  static const String roleRequest = '/role-request';
}