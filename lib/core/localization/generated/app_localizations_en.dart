// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'AgriLink';

  @override
  String get welcomeBack => 'Welcome Back!';

  @override
  String get signInSubtitle => 'Sign in to continue to your account';

  @override
  String get emailOrPhone => 'Email or Phone';

  @override
  String get emailOrPhoneHint => 'Enter your email or phone';

  @override
  String get emailOrPhoneRequired => 'Please enter email or phone';

  @override
  String get password => 'Password';

  @override
  String get passwordHint => 'Enter your password';

  @override
  String get passwordRequired => 'Please enter password';

  @override
  String get passwordMinLength => 'Password must be at least 6 characters';

  @override
  String get login => 'Login';

  @override
  String get rememberMe => 'Remember me';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get createAccount => 'Create Account';

  @override
  String get noAccount => 'Don\'t have an account?';

  @override
  String get quickDebugLogin => 'Quick Debug Login';

  @override
  String get selectTestAccount => 'Select a test account';

  @override
  String get orDivider => 'OR';

  @override
  String get signInWithGoogle => 'Sign in with Google';

  @override
  String welcomeMessage(Object email) {
    return 'Welcome $email';
  }

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get goodMorning => 'Good Morning';

  @override
  String get goodAfternoon => 'Good Afternoon';

  @override
  String get goodEvening => 'Good Evening';

  @override
  String get logout => 'Logout';

  @override
  String get noUserDataFound => 'No user data found. Please login.';

  @override
  String get exploreCategories => 'Explore Categories';

  @override
  String get noCategoriesAvailable => 'No categories available';

  @override
  String get noSubcategories => 'No subcategories found';

  @override
  String get backToCategories => 'Back to Categories';

  @override
  String get home => 'Home';

  @override
  String get products => 'Products';

  @override
  String get myProducts => 'My Products';

  @override
  String get myOrders => 'My Orders';

  @override
  String get postProduct => 'Post Product';

  @override
  String get aiAdvisory => 'AI Advisory';

  @override
  String get farmingCompanion => 'Your Farming Companion';

  @override
  String get roleAgentActive => 'Agent Role Active';

  @override
  String get activeStatus => 'ACTIVE';

  @override
  String get joinAsAgent => 'Join as Agent';

  @override
  String get requestAgentRole => 'Request Agent Role';

  @override
  String get sendingRequest => 'Sending request...';

  @override
  String get requestStatus => 'Request Status';

  @override
  String get statusLabel => 'Status';

  @override
  String get roleRequestPending => 'Role Request Pending';

  @override
  String get roleRequestApproved => 'Role Request Approved!';

  @override
  String get roleRequestRejected => 'Request Rejected';

  @override
  String get active => 'ACTIVE';

  @override
  String get reapply => 'Reapply';

  @override
  String get failedToLoadRequestStatus => 'Failed to load request status';

  @override
  String get retry => 'Retry';

  @override
  String get requestSubmittedSuccessfully => 'Request submitted successfully!';

  @override
  String get administratorAccess => 'Administrator Access';

  @override
  String get notifications => 'Notifications';

  @override
  String get comingSoon => 'Coming soon!';

  @override
  String get marketplace => 'Marketplace';

  @override
  String get quickActions => 'Quick Actions';

  @override
  String get ordersReceived => 'Orders Received';
}
