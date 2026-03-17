class ApiConstants {
  static const String baseUrl = "https://agrilink-1-x6ph.onrender.com";

  // ================= AUTH =================
  static const String signup = "$baseUrl/auth/signup";
  static const String signin = "$baseUrl/auth/signin";
  static const String googleSignin = "$baseUrl/auth/google-signin";
  static const String verifyOtp = "$baseUrl/auth/verify-otp";
  static const String forgotPassword = "$baseUrl/auth/forgot-password";
  static const String resetPassword = "$baseUrl/auth/reset-password";

  // ================= CATEGORY =================
  static const String category = "$baseUrl/category";
  static const String subcategory = "$baseUrl/subcategory";

  // ================= LOCATION (ETHIOPIA) =================
  static const String regions = "$baseUrl/regions";
  static const String zones = "$baseUrl/zones";
  static const String zonesByRegion = "$baseUrl/zones/by-region";
  static const String woredas = "$baseUrl/woredas";
  static const String woredasByZone = "$baseUrl/woredas/by-zone";
  static const String kebeles = "$baseUrl/kebeles";
  static const String kebelesByWoreda = "$baseUrl/kebeles/by-woreda";

  // ================= ROLE & REGISTRATION =================
  static const String register = "$baseUrl/auth/signup";
  static const String roleRequest = "$baseUrl/role-request";

  // ================= PROFILE =================
  static const String profileCreate = "$baseUrl/profile";
  static const String profileUpdate = "$baseUrl/profile";
  static const String profileGetByUser = "$baseUrl/user";

  // ================= CHAT =================
  static const String chatConversations = "$baseUrl/chat/conversations";
  static const String chatSendMessage = "$baseUrl/chat/send"; 
  static const String chatSocketUrl = "wss://agrilink-1-x6ph.onrender.com/socket"; 
}