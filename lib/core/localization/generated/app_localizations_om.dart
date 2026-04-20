// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Oromo (`om`).
class AppLocalizationsOm extends AppLocalizations {
  AppLocalizationsOm([String locale = 'om']) : super(locale);

  @override
  String get welcomeBack => 'Baga nagaan dhuftan!';

  @override
  String get signInSubtitle => 'Akkaawuntii kee seenuuf galmaa\'i';

  @override
  String get emailOrPhone => 'Imeelii ykn lakkoofsa bilbilaa';

  @override
  String get emailOrPhoneHint => 'Imeelii ykn lakkoofsa bilbilaa galchi';

  @override
  String get emailOrPhoneRequired =>
      'Maaloo imeelii ykn lakkoofsa bilbilaa galchi';

  @override
  String get password => 'Jecha icciitii';

  @override
  String get passwordHint => 'Jecha icciitii kee galchi';

  @override
  String get passwordRequired => 'Maaloo jecha icciitii galchi';

  @override
  String get passwordMinLength =>
      'Jechi icciitii yoo xiqqaate qubee 6 qabaachuu qaba';

  @override
  String get login => 'Seeni';

  @override
  String get rememberMe => 'Na yaadadhu';

  @override
  String get forgotPassword => 'Jecha icciitii irraanfatte?';

  @override
  String get createAccount => 'Akkaawuntii uumi';

  @override
  String get noAccount => 'Akkaawuntii hin qabduu?';

  @override
  String get quickDebugLogin => 'Seensa Qormaataa';

  @override
  String get selectTestAccount => 'Akkaawuntii filadhu';

  @override
  String get orDivider => 'Ykn';

  @override
  String get signInWithGoogle => 'Google\'n seeni';

  @override
  String welcomeMessage(Object email) {
    return 'Baga nagaan dhuftan $email';
  }

  @override
  String get selectLanguage => 'Afaan filadhu';

  @override
  String get appTitle => 'AgriLink';

  @override
  String get goodMorning => 'Akkam bulte';

  @override
  String get goodAfternoon => 'Akkam ooltan';

  @override
  String get goodEvening => 'Akkam galgaloofte';

  @override
  String get logout => 'Ba\'i';

  @override
  String get noUserDataFound =>
      'Odeeffannoon fayyadamaa hin argamne. Maaloo seeni.';

  @override
  String get exploreCategories => 'Ramaddiiwwan daawwadhu';

  @override
  String get noCategoriesAvailable => 'Ramaddiin hin jiru';

  @override
  String get noSubcategories => 'Ramaddii xiqqaan hin jiru';

  @override
  String get backToCategories => 'Gara ramaddiiwwaniitti deebi\'i';

  @override
  String get home => 'Mana';

  @override
  String get products => 'Oomishoota';

  @override
  String get myProducts => 'Oomisha koo';

  @override
  String get myOrders => 'Ajaja koo';

  @override
  String get postProduct => 'Oomisha maxxansi';

  @override
  String get aiAdvisory => 'Gorsa AI';

  @override
  String get farmingCompanion => 'Hiriyaa qonnaa kee';

  @override
  String get roleAgentActive => 'Gaheen Agentii hojiirra jira';

  @override
  String get activeStatus => 'HOJIIRRA JIRA';

  @override
  String get joinAsAgent => 'Akka Agentitti makami';

  @override
  String get requestAgentRole => 'Gahee Agentii gaafadhu';

  @override
  String get sendingRequest => 'Gaafannaa ergaa jira...';

  @override
  String get requestStatus => 'Haala gaafannaa';

  @override
  String get statusLabel => 'Haala';

  @override
  String get roleRequestPending => 'Gaafannaan eegamaa jira';

  @override
  String get roleRequestApproved => 'Gaafannaan hayyamame!';

  @override
  String get roleRequestRejected => 'Gaafannaan didame';

  @override
  String get active => 'HOJIIRRA JIRA';

  @override
  String get reapply => 'Irra deebi\'ii gaafadhu';

  @override
  String get failedToLoadRequestStatus =>
      'Haalli gaafannaa fe\'amuu hin dandeenye';

  @override
  String get retry => 'Irra deebi\'ii yaali';

  @override
  String get requestSubmittedSuccessfully => 'Gaafannaan milkaa\'inaan ergame!';

  @override
  String get administratorAccess => 'Seensa Bulchiinsaa';

  @override
  String get notifications => 'Beeksisoota';

  @override
  String get comingSoon => 'Dhiheenya keessatti ni dhufa!';

  @override
  String get marketplace => 'Gabaa';

  @override
  String get quickActions => 'Tarkaanfii ariifachiisaa';

  @override
  String get ordersReceived => 'Ajaja ga\'an';
}
