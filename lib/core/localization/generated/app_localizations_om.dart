// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Oromo (`om`).
class AppLocalizationsOm extends AppLocalizations {
  AppLocalizationsOm([String locale = 'om']) : super(locale);

  @override
  String get welcomeBack => 'Baga Nagaan Deebi\'ani!';

  @override
  String get signInSubtitle => 'Akkauntii keessanitti fufuuf seenaa';

  @override
  String get emailOrPhone => 'Iimeeli ykn Bilbilaa';

  @override
  String get emailOrPhoneHint => 'Iimeeli ykn bilbilaa keessan galchi';

  @override
  String get emailOrPhoneRequired => 'Maaloo iimeeli ykn bilbilaa galchi';

  @override
  String get password => 'Jecha Darbii';

  @override
  String get passwordHint => 'Jecha darbii keessan galchi';

  @override
  String get passwordRequired => 'Maaloo jecha darbii galchi';

  @override
  String get passwordMinLength => 'Jechi darbii xiqqaatti 6 arfii ta\'uu qaba';

  @override
  String get login => 'Seenu';

  @override
  String get rememberMe => 'Na Yaadadhu';

  @override
  String get forgotPassword => 'Jecha Darbii Ni Irranfatee?';

  @override
  String get createAccount => 'Akkauntii Uumi';

  @override
  String get noAccount => 'Akkauntii hin qabduu?';

  @override
  String get quickDebugLogin => 'Seensa Sagexii Safaraa';

  @override
  String get selectTestAccount => 'Akkauntii Qorumsaa Filadhu';

  @override
  String get orDivider => 'Ykn';

  @override
  String get signInWithGoogle => 'Google\'iin Seenu';

  @override
  String get welcomeMessage =>
      '👋 Akkam! Ani gorsaa midhaanii AI dha. Filannoo midhaanii, fayyaa lafaa, ilbiisota, fi haala qilleensaa irratti si gargaaruu nan danda\'a.';

  @override
  String get selectLanguage => 'Afaan Filadhu';

  @override
  String get appTitle => 'AgriLink';

  @override
  String get goodMorning => 'Bareedan Ganama';

  @override
  String get goodAfternoon => 'Nagaan Waaree';

  @override
  String get goodEvening => 'Galgannagaa';

  @override
  String get logout => 'Bahii';

  @override
  String get noUserDataFound =>
      'Odeeffannoon fayyadamaa hin argamne. Maaloo seenaa.';

  @override
  String get exploreCategories => 'Ramaddii Keessaa Barbaadi';

  @override
  String get noCategoriesAvailable => 'Ramaddiin hin jiru';

  @override
  String get noSubcategories => 'Ramaddi xiqqoon hin argamne';

  @override
  String get backToCategories => 'Garra Ramaddiitti Deebi\'i';

  @override
  String get home => 'ka\'uumsa';

  @override
  String get products => 'Oomishaalee';

  @override
  String get myProducts => 'Oomishaalee Kiyya';

  @override
  String get myOrders => 'Ajajawwan Kiyya';

  @override
  String get postProduct => 'Oomisha Maxxansi';

  @override
  String get aiAdvisory => 'Gorsa AI';

  @override
  String get farmingCompanion => 'Hiriyaa Qonnaa Keessan';

  @override
  String get roleAgentActive => 'Haalli Agenimaa Ji\'aa';

  @override
  String get activeStatus => 'JI\'AA';

  @override
  String get joinAsAgent => 'Agenima Ta\'uu';

  @override
  String get requestAgentRole => 'Gaaffii Agenimaa';

  @override
  String get sendingRequest => 'Gaaffii Ergaa jira...';

  @override
  String get requestStatus => 'Haalli Gaaffii';

  @override
  String get statusLabel => 'Haalli';

  @override
  String get roleRequestPending => 'Gaaffiin Eeggachaa jira';

  @override
  String get roleRequestApproved => 'Gaaffiin Fudhatame!';

  @override
  String get roleRequestRejected => 'Gaaffiin Diifame';

  @override
  String get active => 'Ji\'aa';

  @override
  String get reapply => 'Irarra Gaafadhu';

  @override
  String get failedToLoadRequestStatus =>
      'Haalli gaaffii baachuun hin danda\'amne';

  @override
  String get retry => 'Irarra Yaali';

  @override
  String get requestSubmittedSuccessfully => 'Gaaffiin milkaayeen ergame!';

  @override
  String get administratorAccess => 'Keeniinsa Abbaa Taati';

  @override
  String get notifications => 'Beeksisawwan';

  @override
  String get comingSoon => 'Dafee Ni Dhufa';

  @override
  String get marketplace => 'Gabaa';

  @override
  String get quickActions => 'Gochaawwan Saffisaa';

  @override
  String get ordersReceived => 'Ajajawwan Dhufan';

  @override
  String get searchProducts => 'Oomishaalee Barbaadi...';

  @override
  String get sortProducts => 'Oomishaalee Qindeessi';

  @override
  String get byName => 'Maqaadhaan';

  @override
  String get priceLowToHigh => 'Gatii: Gadii hanga Olaanaa';

  @override
  String get priceHighToLow => 'Gatii: Olaanaa hanga Gadiitti';

  @override
  String get filterByCategory => 'Ramaddiidhaan Calalchi';

  @override
  String get loadingProducts => 'Oomishaalee Baachaa jira...';

  @override
  String get filteringProducts => 'Oomishaalee Calalchaa jira...';

  @override
  String get failedToLoadProducts => 'Oomishaaleen baachuun hin danda\'amne';

  @override
  String get noProductsFound => 'Oomishaan hin argamne';

  @override
  String get tryDifferentSearchTerm => 'Jecha barbaachisaa adda ta\'e yaali';

  @override
  String get checkBackLater => 'Oomishaalee haaraaf booda deebi\'i';

  @override
  String get clearSearch => 'Barbaadisa Haqi';

  @override
  String get addToCart => 'Gara Gaarii Dabali';

  @override
  String get sort => 'Qindeessi';

  @override
  String get filter => 'Calalchi';

  @override
  String get allCategories => 'Ramaddii Hunda';

  @override
  String productsFound(Object count) {
    return '$count oomishaaleen argaman';
  }

  @override
  String pageOf(Object currentPage, Object totalPages) {
    return 'Fuula $currentPage kan $totalPages';
  }

  @override
  String kgAvailable(Object amount) {
    return '$amount kg jira';
  }

  @override
  String total(Object total) {
    return 'Ida\'amti: $total Birrii';
  }

  @override
  String addedToCart(Object amount) {
    return '$amount wantootni gara gaariitti dabalaman';
  }

  @override
  String chatAboutProduct(Object productName) {
    return 'Waa\'ee $productName haasa\'i';
  }

  @override
  String get store => 'kuufama';

  @override
  String get dashboard => 'Daashboordii';

  @override
  String get profile => 'Piroofaayilii';

  @override
  String get createProfile => 'Profaayilii Uumi';

  @override
  String get profilePhoto => 'Suuraa Profaayilii';

  @override
  String get addPhoto => 'Suuraa Dabali';

  @override
  String get personalInformation => 'Odeeffannoo Dhuunfaa';

  @override
  String get fullName => 'Maqaa Guutuu';

  @override
  String get enterFullName => 'Maqaa guutuu keessan galchi';

  @override
  String get locationDetails => 'Ibsa Iddoo';

  @override
  String get region => 'Naannoo';

  @override
  String get zone => 'Zone';

  @override
  String get woreda => 'Woreda';

  @override
  String get kebele => 'Qabeellee';

  @override
  String get selectRegion => 'Naannoo Filadhu';

  @override
  String get selectZone => 'Zone Filadhu';

  @override
  String get selectWoreda => 'Woreda Filadhu';

  @override
  String get selectKebele => 'Qabeellee Filadhu';

  @override
  String get gpsLocationOptional => 'Iddoo GPS (Filannoodha)';

  @override
  String get gpsDescription =>
      'Iddoo sirrii keessan dabaluuf, qilleensa fi yaada qonnaa sirrii argachuuf';

  @override
  String locationCaptured(Object latitude, Object longitude) {
    return 'Iddoo Qabame';
  }

  @override
  String get latitude => 'Latitude';

  @override
  String get longitude => 'Longitude';

  @override
  String get clearLocation => 'Iddoo Haqi';

  @override
  String get useCurrentLocation => 'Iddoo Ammaa Fayyadam';

  @override
  String get gettingLocation => 'Iddoo Argachaa jira...';

  @override
  String get backToDashboard => 'Gara Daashboordii Deebi\'i';

  @override
  String get skip => 'Darbi';

  @override
  String get pleaseEnterNameAndKebele =>
      'Maaloo maqaa keessan galchiitii qabeellee filadhaa';

  @override
  String get profileCreatedSuccess => 'Profaayilii milkaayeen uumame';

  @override
  String get failedToPickImage =>
      'Suuraa filachuun hin milkoofne. Maaloo irarra yaali.';

  @override
  String get locationPermissionDenied =>
      'Eeyyamni iddoo hin kennamne. Maaloo iddoo fayyadamuu danda\'umsi.';

  @override
  String get locationPermanentlyDenied =>
      'Eeyyamni iddoo yeroo hundaaf hin kennamne. Maaloo settings irraa dandeessisi.';

  @override
  String get failedToGetLocation =>
      'Iddoo argachuun hin milkoofne. Maaloo GPS akka ture mirkaneeffadhaa.';

  @override
  String get locationCleared => 'Iddoon haqame';

  @override
  String get backToDashboardTooltip => 'Gara Daashboordii Deebi\'i';

  @override
  String get createProfileButton => 'Profaayilii Uumi';

  @override
  String get error => 'Dogoggora';

  @override
  String get success => 'Milkaa\'ina';

  @override
  String get optional => 'Filannoodha';

  @override
  String get updateProfile => 'Profaayilii Fooyyessi';

  @override
  String get changePhoto => 'Suuraa Jijjiiri';

  @override
  String get removePhoto => 'Suuraa Balleessi';

  @override
  String get manualLocation => 'Iddoo Harkaa';

  @override
  String get latitudeHint => 'Fkn., 7.688936';

  @override
  String get longitudeHint => 'Fkn., 36.8198876';

  @override
  String get applyManualLocation => 'Iddoo Harkaa Hojiirra Oolchi';

  @override
  String get currentLocationActive => 'Iddoo Ammaa Jira';

  @override
  String get updateFromGPS => 'GPS Irraa Fooyyessi';

  @override
  String get updating => 'Fooyyeessaa jira...';

  @override
  String get clear => 'Haqi';

  @override
  String get updateProfileButton => 'Profaayilii Fooyyessi';

  @override
  String get profileUpdatedSuccess => 'Profaayiliin milkaayeen fooyyesse';

  @override
  String get manualLocationApplied => 'Iddoon harkaa hojiirra oole';

  @override
  String get invalidCoordinates =>
      'Koordineetii sirrii hin taane. Maaloo lakkoofsa sirrii galchi.';

  @override
  String get pleaseEnterBothCoordinates =>
      'Maaloo latitude fi longitude lachuu galchi';

  @override
  String get currentLocation => 'Iddoo Ammaa';

  @override
  String get apply => 'Hojiirra Oolchi';

  @override
  String get myProfile => 'Profaayilii Koo';

  @override
  String get edit => 'Gulaali';

  @override
  String get loadingProfile => 'Profaayilii baachaa jira...';

  @override
  String get userNotLoggedIn => 'Fayyadaan hin seenne';

  @override
  String get couldNotOpenMap => 'Kaartaa banuun hin danda\'amne';

  @override
  String get chooseMapOption => 'Filannoo Kaartaa Filadhu';

  @override
  String get openInAppMap => 'Kaartaa App Keessatti Bani';

  @override
  String get viewMapWithMarkers =>
      'Kaartaa mallattoo fi to\'annoowaa wajjin ilaali';

  @override
  String get openInExternalMap => 'Kaartaa Alaa Bani';

  @override
  String get openInGoogleMaps => 'Google Maps keessatti bani';

  @override
  String get contactInformation => 'Odeeffannoo Qunnamtii';

  @override
  String get locationInformation => 'Odeeffannoo Iddoo';

  @override
  String get accountInformation => 'Odeeffannoo Akkauntii';

  @override
  String get phone => 'Bilbilaa';

  @override
  String get email => 'Iimeelii';

  @override
  String get kebeleId => 'ID Qabeellee';

  @override
  String get kebeleName => 'Maqaa Qabeellee';

  @override
  String get gpsCoordinates => 'Koordineetii GPS';

  @override
  String get viewMap => 'Kaartaa Ilaali';

  @override
  String get options => 'Filannoo';

  @override
  String get memberSince => 'Misraamicha Ture';

  @override
  String get accountStatus => 'Haala Akkauntii';

  @override
  String get editProfile => 'Profaayilii Gulaali';

  @override
  String get noProfileFound => 'Profaayiliin Hin Argamne';

  @override
  String get noProfileDescription => 'Profaayilii hin uumamne.\nUumuun eegali!';

  @override
  String get maybeLater => 'Booda Dhufuun';

  @override
  String get oopsSomethingWentWrong => 'Dok! Dogoggorsi Gunnuume';

  @override
  String get goHome => 'Gara Manaa Deemi';

  @override
  String get noProfileDataAvailable => 'Odeeffannoon Profaayilii Hin Jiru';

  @override
  String get notProvided => 'Hin Kennamne';

  @override
  String get today => 'Har\'a';

  @override
  String get yearAgo => 'Wagga Dura';

  @override
  String get yearsAgo => 'Waggoota Dura';

  @override
  String get monthAgo => 'Ji\'a Dura';

  @override
  String get monthsAgo => 'Ji\'oota Dura';

  @override
  String get dayAgo => 'Guyyaa Dura';

  @override
  String get daysAgo => 'Guyyoota Dura';

  @override
  String get hourAgo => 'Sa\'aatii Dura';

  @override
  String get hoursAgo => 'Sa\'aatiota Dura';

  @override
  String get logoutTitle => 'Bahii';

  @override
  String get logoutConfirmation => 'Ba\'uu barbaadda?';

  @override
  String get cancel => 'Haqi';

  @override
  String get logoutButton => 'Bahii';

  @override
  String get inactive => 'Hin Ji\'aa';

  @override
  String get pending => 'Eeggachaa jira';

  @override
  String get locationMap => 'Kaartaa Iddoo';

  @override
  String get moreOptions => 'Filannoo Dabalaa';

  @override
  String get refreshMap => 'Kaartaa Haaromsi';

  @override
  String get failedToLoadMap => 'Kaartaan baachuun hin milkoofne';

  @override
  String get checkInternetConnection =>
      'Maaloo qunnamtii internet keessan mirkaneeffadhaa';

  @override
  String get loadingMap => 'Kaartaa baachaa jira...';

  @override
  String get zoomIn => 'Guddisi';

  @override
  String get zoomOut => 'Xiqxeessi';

  @override
  String get satelliteView => 'Ilaalcha Sateelayitii';

  @override
  String get streetView => 'Ilaalcha Daandii';

  @override
  String get myLocation => 'Iddoo Kiyya';

  @override
  String get fullscreen => 'Wiirtuu Guutuu';

  @override
  String coordinatesCopied(Object coordinates) {
    return 'Koordineetiin ni kuufame: $coordinates';
  }

  @override
  String get failedToCopyCoordinates => 'Koordineetii kuufamuun hin milkoofne';

  @override
  String get couldNotOpenGoogleMaps => 'Google Maps banuun hin danda\'amne';

  @override
  String get failedToOpenDirections => 'Qajeelcha banuun hin milkoofne';

  @override
  String get sharedLocation => 'Iddoo Wajjiramu';

  @override
  String get viewOnMaps => 'Kaartaa irratti ilaali';

  @override
  String get failedToShareLocation => 'Iddoon wajjiramuun hin milkoofne';

  @override
  String get copyCoordinates => 'Koordineetii Kuufadhu';

  @override
  String get getDirections => 'Qajeelcha Argadhu';

  @override
  String get shareLocation => 'Iddoo Wajjirani';

  @override
  String get shareWithOthers => 'Kan biroo wajjin wajjirani';

  @override
  String get copy => 'Kuufadhu';

  @override
  String get directions => 'Qajeelcha';

  @override
  String get share => 'Wajjirani';

  @override
  String get coordinates => 'Koordineetii';

  @override
  String get streetViewMap => '📍 Ilaalicha Daandii';

  @override
  String get satelliteViewMap => '🛰️ Ilaalicha Sateelayitii';

  @override
  String get aiCropAdvisor => 'Gorsaa Midhaanii AI';

  @override
  String get onlinePoweredByAI => 'Toora irratti • AI’n deeggarame';

  @override
  String get askAnything => 'Waa kamiyyuu na gaafadhu...';

  @override
  String get close => 'Cufi';
}
