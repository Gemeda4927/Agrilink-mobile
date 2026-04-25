class ApiConstants {
  // ================= BASE URLS =================
  static const String baseUrl = "https://agrilink-1-x6ph.onrender.com";
  
  // Local development server IP (for device registration and local testing)
  // static const String localBaseUrl = "http://10.50.89.199:3000";
  
  static const String cropAdvisorBaseUrl =
      "https://senakebede-crop-advisor-backend.hf.space";

  // ================= DEVICE REGISTRATION =================
  static const String deviceRegister = "$baseUrl/devices/register";
  static const String deviceUnregister = "$baseUrl/devices/unregister";
  
  // ================= AUTH ENDPOINTS =================
  static const String signup = "$baseUrl/auth/signup";
  static const String signin = "$baseUrl/auth/signin";
  static const String googleSignin = "$baseUrl/auth/google-signin";
  static const String verifyOtp = "$baseUrl/auth/verify-otp";
  static const String forgotPassword = "$baseUrl/auth/forgot-password";
  static const String resetPassword = "$baseUrl/auth/reset-password";
  static const String register =
      "$baseUrl/auth/signup"; // Legacy - use signup instead

  // ================= ROLE-SPECIFIC ENDPOINTS =================
  // Note: Only farmer creation endpoint exists. The role field in body is ignored.
  static const String createFarmer = "$baseUrl/auth/create-farmer";

  // ================= CATEGORY ENDPOINTS =================
  static const String category = "$baseUrl/category";
  static const String subcategory = "$baseUrl/subcategory";

  // ================= PRODUCT ENDPOINTS =================
  static const String product = "$baseUrl/product";
  static const String myProducts = "$baseUrl/product/my-products";
  static const String allProduct = "$baseUrl/all-product";
  static String getProductById(String id) => "$baseUrl/product/$id";
  static String updateProduct(String id) => "$baseUrl/product/$id";
  static String deleteProduct(String id) => "$baseUrl/product/$id";

  // ================= LOCATION ENDPOINTS (ETHIOPIA) =================
  static const String regions = "$baseUrl/regions";
  static const String zones = "$baseUrl/zones";
  static const String zonesByRegion = "$baseUrl/zones/by-region";
  static const String woredas = "$baseUrl/woredas";
  static const String woredasByZone = "$baseUrl/woredas/by-zone";
  static const String kebeles = "$baseUrl/kebeles";
  static const String kebelesByWoreda = "$baseUrl/kebeles/by-woreda";

  // ================= ROLE REQUEST ENDPOINTS =================
  static const String roleRequest = "$baseUrl/role-request";
  static String getRoleRequestById(String id) => "$baseUrl/role-request/$id";
  static String updateRoleRequestStatus(String id) =>
      "$baseUrl/role-request/$id";
  static String deleteRoleRequest(String id) => "$baseUrl/role-request/$id";

  // ================= PROFILE ENDPOINTS =================
  static const String profileCreate = "$baseUrl/profile";
  static const String profileUpdate = "$baseUrl/profile";
  static const String profileGetByUser = "$baseUrl/user";

  // ================= CHAT ENDPOINTS =================
  static const String chatConversations = "$baseUrl/chat/conversations";
  static const String chatSendMessage = "$baseUrl/chat/send";
  static const String chatSocketUrl =
      "wss://agrilink-1-x6ph.onrender.com/socket";

  // ================= CART ENDPOINTS =================
  static const String cart = "$baseUrl/cart";
  static String deleteCartItem(String productId) => "$baseUrl/cart/$productId";

  // ================= ORDER ENDPOINTS =================
  static const String myOrders = "$baseUrl/orders/my-orders";
  static const String farmerOrders = "$baseUrl/orders/farmer-orders";
  static const String farmerOrdersPending =
      "$baseUrl/orders/farmer-orders/pending";
  static String verifyOrder(String orderId) =>
      "$baseUrl/orders/verify/$orderId";

  // ================= PAYMENT ENDPOINTS =================
  static const String checkout = "$baseUrl/orders/checkout";
  static const String chapaWebhook = "$baseUrl/orders/webhook/chapa";

  // ================= MARKET INSIGHT ENDPOINTS =================
  static const String marketPrice = "$baseUrl/market-price";
  static const String marketPriceApproved = "$baseUrl/market-price/approved";
  static const String marketPriceMyProduct = "$baseUrl/market-price/myproduct";
  static String approveMarketPrice(String id) =>
      "$baseUrl/market-price/approve/$id";
  static String rejectMarketPrice(String id) =>
      "$baseUrl/market-price/reject/$id";
  static String getMarketPriceById(String id) => "$baseUrl/market-price/$id";
  static String getApprovedPriceById(String id) =>
      "$baseUrl/market-price/approved/$id";

  // ================= CROP ADVISOR ENDPOINTS =================
  static const String cropAdvisorChat = "$cropAdvisorBaseUrl/api/v1/chat";

  // ================= ENUMS / OPTIONS =================
  // Current Role Options
  static const List<String> currentRoleOptions = [
    'DA_OFFICER',
    'FARMER',
    'OTHER',
  ];

  // Education Level Options
  static const List<String> educationLevelOptions = [
    'NONE',
    'PRIMARY',
    'SECONDARY',
    'DIPLOMA',
    'DEGREE',
    'MASTERS',
    'PHD',
  ];

  // Request Status Options
  static const List<String> requestStatusOptions = [
    'PENDING',
    'APPROVED',
    'REJECTED',
    'CANCELLED',
  ];
}