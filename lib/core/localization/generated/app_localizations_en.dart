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
  String get welcomeMessage => '👋 Hello! I\'m your AI Crop Advisor...';

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
  String get myOrders => 'Orders';

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
  String get active => 'Active';

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
  String get comingSoon => 'Coming Soon';

  @override
  String get marketplace => 'Marketplace';

  @override
  String get quickActions => 'Quick Actions';

  @override
  String get ordersReceived => 'Orders Received';

  @override
  String get searchProducts => 'Search products...';

  @override
  String get sortProducts => 'Sort Products';

  @override
  String get byName => 'By Name';

  @override
  String get priceLowToHigh => 'Price: Low to High';

  @override
  String get priceHighToLow => 'Price: High to Low';

  @override
  String get filterByCategory => 'Filter by Category';

  @override
  String get loadingProducts => 'Loading products...';

  @override
  String get filteringProducts => 'Filtering products...';

  @override
  String get failedToLoadProducts => 'Failed to load products';

  @override
  String get noProductsFound => 'No products found';

  @override
  String get tryDifferentSearchTerm => 'Try a different search term';

  @override
  String get checkBackLater => 'Check back later for new products';

  @override
  String get clearSearch => 'Clear Search';

  @override
  String get addToCart => 'Add to Cart';

  @override
  String get sort => 'Sort';

  @override
  String get filter => 'Filter';

  @override
  String get allCategories => 'All Categories';

  @override
  String productsFound(Object count) {
    return '$count products found';
  }

  @override
  String pageOf(Object currentPage, Object totalPages) {
    return 'Page $currentPage of $totalPages';
  }

  @override
  String kgAvailable(Object amount) {
    return '$amount kg available';
  }

  @override
  String total(Object total) {
    return 'Total: $total ETB';
  }

  @override
  String addedToCart(Object amount) {
    return 'Added $amount item(s) to cart';
  }

  @override
  String chatAboutProduct(Object productName) {
    return 'Chat about $productName';
  }

  @override
  String get store => 'Store';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get profile => 'Profile';

  @override
  String get createProfile => 'Create Profile';

  @override
  String get profilePhoto => 'Profile Photo';

  @override
  String get addPhoto => 'Add Photo';

  @override
  String get personalInformation => 'Personal Information';

  @override
  String get fullName => 'Full Name';

  @override
  String get enterFullName => 'Enter your full name';

  @override
  String get locationDetails => 'Location Details';

  @override
  String get region => 'Region';

  @override
  String get zone => 'Zone';

  @override
  String get woreda => 'Woreda';

  @override
  String get kebele => 'Kebele';

  @override
  String get selectRegion => 'Select Region';

  @override
  String get selectZone => 'Select Zone';

  @override
  String get selectWoreda => 'Select Woreda';

  @override
  String get selectKebele => 'Select Kebele';

  @override
  String get gpsLocationOptional => 'GPS Location (Optional)';

  @override
  String get gpsDescription =>
      'Add your exact location manually or get current location';

  @override
  String locationCaptured(Object latitude, Object longitude) {
    return 'Location captured: $latitude, $longitude';
  }

  @override
  String get latitude => 'LATITUDE';

  @override
  String get longitude => 'LONGITUDE';

  @override
  String get clearLocation => 'Clear Location';

  @override
  String get useCurrentLocation => 'Use Current Location';

  @override
  String get gettingLocation => 'Getting Location...';

  @override
  String get backToDashboard => 'Back to Dashboard';

  @override
  String get skip => 'Skip';

  @override
  String get pleaseEnterNameAndKebele =>
      'Please enter your name and select a kebele';

  @override
  String get profileCreatedSuccess => 'Profile created successfully';

  @override
  String get failedToPickImage => 'Failed to pick image. Please try again.';

  @override
  String get locationPermissionDenied =>
      'Location permission denied. Please enable location access.';

  @override
  String get locationPermanentlyDenied =>
      'Location permission permanently denied. Please enable from settings.';

  @override
  String get failedToGetLocation =>
      'Failed to get location. Please check GPS is enabled.';

  @override
  String get locationCleared => 'Location cleared';

  @override
  String get backToDashboardTooltip => 'Back to Dashboard';

  @override
  String get createProfileButton => 'Create Profile';

  @override
  String get error => 'Error';

  @override
  String get success => 'Success';

  @override
  String get optional => 'Optional';

  @override
  String get updateProfile => 'Update Profile';

  @override
  String get changePhoto => 'Change Photo';

  @override
  String get removePhoto => 'Remove Photo';

  @override
  String get manualLocation => 'Manual Location';

  @override
  String get latitudeHint => 'e.g., 7.688936';

  @override
  String get longitudeHint => 'e.g., 36.8198876';

  @override
  String get applyManualLocation => 'Apply Manual Location';

  @override
  String get currentLocationActive => 'Current Location Active';

  @override
  String get updateFromGPS => 'Update from GPS';

  @override
  String get updating => 'Updating...';

  @override
  String get clear => 'Clear';

  @override
  String get updateProfileButton => 'Update Profile';

  @override
  String get profileUpdatedSuccess => 'Profile updated successfully';

  @override
  String get manualLocationApplied => 'Manual location applied';

  @override
  String get invalidCoordinates =>
      'Invalid coordinates. Please enter valid numbers.';

  @override
  String get pleaseEnterBothCoordinates =>
      'Please enter both latitude and longitude';

  @override
  String get currentLocation => 'Current Location';

  @override
  String get apply => 'Apply';

  @override
  String get myProfile => 'My Profile';

  @override
  String get edit => 'Edit';

  @override
  String get loadingProfile => 'Loading profile...';

  @override
  String get userNotLoggedIn => 'User not logged in';

  @override
  String get couldNotOpenMap => 'Could not open map';

  @override
  String get chooseMapOption => 'Choose Map Option';

  @override
  String get openInAppMap => 'Open in App Map';

  @override
  String get viewMapWithMarkers => 'View map with markers and controls';

  @override
  String get openInExternalMap => 'Open in External Map';

  @override
  String get openInGoogleMaps => 'Open in Google Maps';

  @override
  String get contactInformation => 'Contact Information';

  @override
  String get locationInformation => 'Location Information';

  @override
  String get accountInformation => 'Account Information';

  @override
  String get phone => 'Phone';

  @override
  String get email => 'Email';

  @override
  String get kebeleId => 'Kebele ID';

  @override
  String get kebeleName => 'Kebele Name';

  @override
  String get gpsCoordinates => 'GPS Coordinates';

  @override
  String get viewMap => 'View Map';

  @override
  String get options => 'Options';

  @override
  String get memberSince => 'Member Since';

  @override
  String get accountStatus => 'Account Status';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get noProfileFound => 'No Profile Found';

  @override
  String get noProfileDescription =>
      'You haven\'t created a profile yet.\nCreate one to get started!';

  @override
  String get maybeLater => 'Maybe Later';

  @override
  String get oopsSomethingWentWrong => 'Oops! Something went wrong';

  @override
  String get goHome => 'Go Home';

  @override
  String get noProfileDataAvailable => 'No profile data available';

  @override
  String get notProvided => 'Not provided';

  @override
  String get today => 'Today';

  @override
  String get yearAgo => 'year ago';

  @override
  String get yearsAgo => 'years ago';

  @override
  String get monthAgo => 'month ago';

  @override
  String get monthsAgo => 'months ago';

  @override
  String get dayAgo => 'day ago';

  @override
  String get daysAgo => 'days ago';

  @override
  String get hourAgo => 'hour ago';

  @override
  String get hoursAgo => 'hours ago';

  @override
  String get logoutTitle => 'Logout';

  @override
  String get logoutConfirmation => 'Are you sure you want to logout?';

  @override
  String get cancel => 'Cancel';

  @override
  String get logoutButton => 'Logout';

  @override
  String get inactive => 'Inactive';

  @override
  String get pending => 'Pending';

  @override
  String get locationMap => 'Location Map';

  @override
  String get moreOptions => 'More options';

  @override
  String get refreshMap => 'Refresh map';

  @override
  String get failedToLoadMap => 'Failed to load map';

  @override
  String get checkInternetConnection => 'Please check your internet connection';

  @override
  String get loadingMap => 'Loading map...';

  @override
  String get zoomIn => 'Zoom In';

  @override
  String get zoomOut => 'Zoom Out';

  @override
  String get satelliteView => 'Satellite View';

  @override
  String get streetView => 'Street View';

  @override
  String get myLocation => 'My Location';

  @override
  String get fullscreen => 'Fullscreen';

  @override
  String coordinatesCopied(Object coordinates) {
    return 'Coordinates copied: $coordinates';
  }

  @override
  String get failedToCopyCoordinates => 'Failed to copy coordinates';

  @override
  String get couldNotOpenGoogleMaps => 'Could not open Google Maps';

  @override
  String get failedToOpenDirections => 'Failed to open directions';

  @override
  String get sharedLocation => 'Shared Location';

  @override
  String get viewOnMaps => 'View on Maps';

  @override
  String get failedToShareLocation => 'Failed to share location';

  @override
  String get copyCoordinates => 'Copy Coordinates';

  @override
  String get getDirections => 'Get Directions';

  @override
  String get shareLocation => 'Share Location';

  @override
  String get shareWithOthers => 'Share with others';

  @override
  String get copy => 'Copy';

  @override
  String get directions => 'Directions';

  @override
  String get share => 'Share';

  @override
  String get coordinates => 'Coordinates';

  @override
  String get streetViewMap => '📍 Street View';

  @override
  String get satelliteViewMap => '🛰️ Satellite View';

  @override
  String get aiCropAdvisor => 'AI Crop Advisor';

  @override
  String get onlinePoweredByAI => 'Online • Powered by AI';

  @override
  String get askAnything => 'Ask me anything...';

  @override
  String get close => 'Close';
}
