// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Amharic (`am`).
class AppLocalizationsAm extends AppLocalizations {
  AppLocalizationsAm([String locale = 'am']) : super(locale);

  @override
  String get welcomeBack => 'እንኳን ደህና መጡ';

  @override
  String get signInSubtitle => 'ወደ መለያዎ ለመግባት ይግቡ';

  @override
  String get emailOrPhone => 'ኢሜይል ወይም ስልክ';

  @override
  String get emailOrPhoneHint => 'ኢሜይል ወይም ስልክ ያስገቡ';

  @override
  String get emailOrPhoneRequired => 'እባክዎ ኢሜይል ወይም ስልክ ያስገቡ';

  @override
  String get password => 'የይለፍ ቃል';

  @override
  String get passwordHint => 'የይለፍ ቃልዎን ያስገቡ';

  @override
  String get passwordRequired => 'እባክዎ የይለፍ ቃል ያስገቡ';

  @override
  String get passwordMinLength => 'የይለፍ ቃል ቢያንስ 6 ቁምፊዎች መሆን አለበት';

  @override
  String get login => 'ግባ';

  @override
  String get rememberMe => 'አስታውሰኝ';

  @override
  String get forgotPassword => 'የይለፍ ቃል ረሳሁ';

  @override
  String get createAccount => 'መለያ ፍጠር';

  @override
  String get noAccount => 'መለያ የለዎትም?';

  @override
  String get quickDebugLogin => 'ፈጣን መግቢያ';

  @override
  String get selectTestAccount => 'ሙከራ መለያ ይምረጡ';

  @override
  String get orDivider => 'ወይም';

  @override
  String get signInWithGoogle => 'በGoogle ይግቡ';

  @override
  String welcomeMessage(Object email) {
    return 'እንኳን ደህና መጡ $email';
  }

  @override
  String get selectLanguage => 'ቋንቋ ይምረጡ';

  @override
  String get appTitle => 'አግሪሊንክ';

  @override
  String get goodMorning => 'እንደምን አደሩ';

  @override
  String get goodAfternoon => 'እንደምን ዋሉ';

  @override
  String get goodEvening => 'እንደምን አመሹ';

  @override
  String get logout => 'ውጣ';

  @override
  String get noUserDataFound => 'ምንም የተጠቃሚ መረጃ አልተገኘም እባክዎ ይግቡ';

  @override
  String get exploreCategories => 'ምድቦችን ያስሱ';

  @override
  String get noCategoriesAvailable => 'ምንም ምድቦች የሉም';

  @override
  String get noSubcategories => 'ምንም ንዑስ ምድቦች አልተገኙም';

  @override
  String get backToCategories => 'ወደ ምድቦች ይመለሱ';

  @override
  String get home => 'መነሻ';

  @override
  String get products => 'ምርቶች';

  @override
  String get myProducts => 'የእኔ ምርቶች';

  @override
  String get myOrders => 'የእኔ ትዕዛዞች';

  @override
  String get postProduct => 'ምርት ይለጥፉ';

  @override
  String get aiAdvisory => 'የAI ምክር';

  @override
  String get farmingCompanion => 'የእርሻ አጋርዎ';

  @override
  String get roleAgentActive => 'ሚና፡ ወኪል';

  @override
  String get activeStatus => 'ንቁ';

  @override
  String get joinAsAgent => 'እንደ ወኪል ይቀላቀሉ';

  @override
  String get sendingRequest => 'ጥያቄ በመላክ ላይ...';

  @override
  String get requestStatus => 'የጥያቄ ሁኔታ';

  @override
  String get statusLabel => 'ሁኔታ';
}
