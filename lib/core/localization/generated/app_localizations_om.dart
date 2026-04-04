// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Oromo (`om`).
class AppLocalizationsOm extends AppLocalizations {
  AppLocalizationsOm([String locale = 'om']) : super(locale);

  @override
  String get welcomeBack => 'Baga Nagaan Dhuftan!';

  @override
  String get signInSubtitle => 'Akkaawuntii kee seenuuf galchi';

  @override
  String get emailOrPhone => 'Imeelii ykn Bilbila';

  @override
  String get emailOrPhoneHint => 'Imeelii ykn bilbila keessan galchaa';

  @override
  String get emailOrPhoneRequired => 'Maalimoo imeelii ykn bilbila galchaa';

  @override
  String get password => 'Jecha icciitii';

  @override
  String get passwordHint => 'Jecha icciitii keessan galchaa';

  @override
  String get passwordRequired => 'Maalimoo jecha icciitii galchaa';

  @override
  String get passwordMinLength =>
      'Jechi icciitii xiqqaatti 6 arfii ta\'uu qaba';

  @override
  String get login => 'Seeni';

  @override
  String get rememberMe => 'Na yaadadhu';

  @override
  String get forgotPassword => 'Jecha icciitii irraanfadhe';

  @override
  String get createAccount => 'Akkaawuntii uumuu';

  @override
  String get noAccount => 'Akkaawuntii hin qabduu?';

  @override
  String get quickDebugLogin => 'Seensa Testii';

  @override
  String get selectTestAccount => 'Akkaawuntii filadhu';

  @override
  String get orDivider => 'Ykn';

  @override
  String get signInWithGoogle => 'Google tiin seeni';

  @override
  String welcomeMessage(Object email) {
    return 'Baga nagaan dhufte $email';
  }

  @override
  String get selectLanguage => 'Afaan Filadhu';

  @override
  String get appTitle => 'AgriLink';

  @override
  String get goodMorning => 'Bareedan Bulte';

  @override
  String get goodAfternoon => 'Baga Ooltan';

  @override
  String get goodEvening => 'Galgaloo Gaarii';

  @override
  String get logout => 'Ba\'i';

  @override
  String get noUserDataFound =>
      'Dhaataa fayyadamtaa hin argamne. Maalimoo seeni.';

  @override
  String get exploreCategories => 'Koreewwan Daawwadhu';

  @override
  String get noCategoriesAvailable => 'Ramaddiin hin jiru';

  @override
  String get noSubcategories => 'Ramaddiin xiqqaan hin argamne';

  @override
  String get backToCategories => 'Gara Ramaddiiwwaniitti Deebi\'i';

  @override
  String get home => 'Mana';

  @override
  String get products => 'Oomishoota';

  @override
  String get myProducts => 'Oomishoota Kiyya';

  @override
  String get myOrders => 'Ajajawwan Kiyya';

  @override
  String get postProduct => 'Oomisha Galchi';

  @override
  String get aiAdvisory => 'Gorsa AI';

  @override
  String get farmingCompanion => 'Hiriyaa Qonna Keessan';

  @override
  String get roleAgentActive => 'Gahee: AGEENTII';

  @override
  String get activeStatus => 'Aktiivii';

  @override
  String get joinAsAgent => 'Ageentii ta\'uu';

  @override
  String get sendingRequest => 'Gaafannaa ergaa...';

  @override
  String get requestStatus => 'Haala Gaafannaa';

  @override
  String get statusLabel => 'Haala';
}
