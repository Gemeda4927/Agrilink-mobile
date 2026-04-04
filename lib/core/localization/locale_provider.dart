import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider {
  static const String _localeKey = 'app_locale';
  static const String _countryCodeKey = 'app_country_code';

  // Singleton pattern
  static final LocaleProvider _instance = LocaleProvider._internal();
  factory LocaleProvider() => _instance;
  LocaleProvider._internal();

  // Get saved locale from SharedPreferences
  Future<Locale> getSavedLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString(_localeKey);
      final countryCode = prefs.getString(_countryCodeKey);

      if (languageCode != null && languageCode.isNotEmpty) {
        // Return saved locale with country code if available
        if (countryCode != null && countryCode.isNotEmpty) {
          return Locale(languageCode, countryCode);
        }
        return Locale(languageCode);
      }

      // Return default locale (English)
      return const Locale('en', 'US');
    } catch (error) {
      print('Error getting saved locale: $error');
      return const Locale('en', 'US');
    }
  }

  // Save locale to SharedPreferences
  Future<void> saveLocale(Locale locale) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_localeKey, locale.languageCode);

      if (locale.countryCode != null && locale.countryCode!.isNotEmpty) {
        await prefs.setString(_countryCodeKey, locale.countryCode!);
      } else {
        // Clear country code if not provided
        await prefs.remove(_countryCodeKey);
      }

      print(
        'Locale saved: ${locale.languageCode}${locale.countryCode != null ? '_${locale.countryCode}' : ''}',
      );
    } catch (error) {
      print('Error saving locale: $error');
    }
  }

  // Clear saved locale (reset to default)
  Future<void> clearSavedLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_localeKey);
      await prefs.remove(_countryCodeKey);
      print('Saved locale cleared');
    } catch (error) {
      print('Error clearing saved locale: $error');
    }
  }

  // Check if locale is supported
  bool isLocaleSupported(Locale locale) {
    const supportedLocales = ['en', 'am', 'om'];
    return supportedLocales.contains(locale.languageCode);
  }

  // Get list of supported locales with display information
  List<Map<String, dynamic>> getSupportedLocales() {
    return [
      {
        'locale': const Locale('en', 'US'),
        'languageCode': 'en',
        'countryCode': 'US',
        'displayName': 'English',
        'nativeName': 'English',
        'flag': '🇬🇧',
        'direction': TextDirection.ltr,
        'fontFamily': 'Roboto',
      },
      {
        'locale': const Locale('am', 'ET'),
        'languageCode': 'am',
        'countryCode': 'ET',
        'displayName': 'Amharic',
        'nativeName': 'አማርኛ',
        'flag': '🇪🇹',
        'direction': TextDirection.ltr,
        'fontFamily': 'NotoSansEthiopic',
      },
      {
        'locale': const Locale('om', 'ET'),
        'languageCode': 'om',
        'countryCode': 'ET',
        'displayName': 'Oromo',
        'nativeName': 'Oromoo',
        'flag': '🇪🇹',
        'direction': TextDirection.ltr,
        'fontFamily': 'Roboto',
      },
    ];
  }

  // Get supported language codes
  List<String> getSupportedLanguageCodes() {
    return ['en', 'am', 'om'];
  }

  // Get locale by language code
  Locale? getLocaleByLanguageCode(String languageCode) {
    final supportedLocales = getSupportedLocales();
    final localeData = supportedLocales.firstWhere(
      (locale) => locale['languageCode'] == languageCode,
      orElse: () => {},
    );

    if (localeData.isNotEmpty) {
      return localeData['locale'] as Locale;
    }
    return null;
  }

  // Get display name for locale
  String getDisplayName(Locale locale, {bool useNativeName = false}) {
    final supportedLocales = getSupportedLocales();
    final localeData = supportedLocales.firstWhere(
      (loc) => loc['languageCode'] == locale.languageCode,
      orElse: () => {},
    );

    if (localeData.isNotEmpty) {
      return useNativeName
          ? localeData['nativeName'] as String
          : localeData['displayName'] as String;
    }

    return locale.languageCode;
  }

  // Get flag emoji for locale
  String getFlag(Locale locale) {
    final supportedLocales = getSupportedLocales();
    final localeData = supportedLocales.firstWhere(
      (loc) => loc['languageCode'] == locale.languageCode,
      orElse: () => {},
    );

    if (localeData.isNotEmpty) {
      return localeData['flag'] as String;
    }

    return '🌐';
  }

  // Get font family for locale
  String getFontFamily(Locale locale) {
    final supportedLocales = getSupportedLocales();
    final localeData = supportedLocales.firstWhere(
      (loc) => loc['languageCode'] == locale.languageCode,
      orElse: () => {},
    );

    if (localeData.isNotEmpty) {
      return localeData['fontFamily'] as String;
    }

    return 'Roboto';
  }

  // Check if locale is RTL (Right-to-Left)
  bool isRTL(Locale locale) {
    final supportedLocales = getSupportedLocales();
    final localeData = supportedLocales.firstWhere(
      (loc) => loc['languageCode'] == locale.languageCode,
      orElse: () => {},
    );

    if (localeData.isNotEmpty) {
      return localeData['direction'] == TextDirection.rtl;
    }

    return false;
  }

  // Get device locale
  Future<Locale> getDeviceLocale() async {
    try {
      final deviceLocale = WidgetsBinding.instance.platformDispatcher.locale;
      if (deviceLocale != null && isLocaleSupported(deviceLocale)) {
        return deviceLocale;
      }
      return const Locale('en', 'US');
    } catch (error) {
      print('Error getting device locale: $error');
      return const Locale('en', 'US');
    }
  }

  // Get appropriate locale (saved > device > default)
  Future<Locale> getAppropriateLocale() async {
    try {
      // Try to get saved locale first
      final savedLocale = await getSavedLocale();
      if (savedLocale.languageCode.isNotEmpty) {
        return savedLocale;
      }

      // If no saved locale, try device locale
      final deviceLocale = await getDeviceLocale();
      if (isLocaleSupported(deviceLocale)) {
        return deviceLocale;
      }

      // Fallback to default
      return const Locale('en', 'US');
    } catch (error) {
      print('Error getting appropriate locale: $error');
      return const Locale('en', 'US');
    }
  }

  // Get locale string (e.g., 'en_US')
  String getLocaleString(Locale locale) {
    if (locale.countryCode != null && locale.countryCode!.isNotEmpty) {
      return '${locale.languageCode}_${locale.countryCode}';
    }
    return locale.languageCode;
  }

  // Parse locale from string (e.g., 'en_US' or 'en')
  Locale parseLocale(String localeString) {
    try {
      final parts = localeString.split('_');
      if (parts.length == 2) {
        return Locale(parts[0], parts[1]);
      }
      return Locale(parts[0]);
    } catch (error) {
      print('Error parsing locale string: $error');
      return const Locale('en', 'US');
    }
  }

  // Check if two locales are equal
  bool areLocalesEqual(Locale locale1, Locale locale2) {
    if (locale1.languageCode != locale2.languageCode) return false;
    if (locale1.countryCode == null && locale2.countryCode == null) return true;
    if (locale1.countryCode == null || locale2.countryCode == null)
      return false;
    return locale1.countryCode == locale2.countryCode;
  }
}
