import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'language_event.dart';
part 'language_state.dart';

class LanguageBloc extends Bloc<LanguageEvent, LanguageState> {
  static const String _localeKey = 'app_locale';
  static const String _countryCodeKey = 'app_country_code';

  LanguageBloc() : super(LanguageState.initial()) {
    // Register event handlers
    on<ChangeLanguage>(_onChangeLanguage);
    on<LoadSavedLanguage>(_onLoadSavedLanguage);
    on<SetInitialLanguage>(_onSetInitialLanguage);

    // Load saved language on initialization
    add(const LoadSavedLanguage());
  }

  /// Handle language change
  Future<void> _onChangeLanguage(
    ChangeLanguage event,
    Emitter<LanguageState> emit,
  ) async {
    try {
      // Set loading state
      emit(state.copyWith(isLoading: true));

      // Save to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_localeKey, event.locale.languageCode);
      await prefs.setString(_countryCodeKey, event.locale.countryCode ?? '');

      // Emit new state with selected locale
      emit(state.copyWith(locale: event.locale, isLoading: false));

      print('Language changed to: ${event.locale.languageCode}');
    } catch (error) {
      print('Error saving language: $error');
      emit(state.copyWith(isLoading: false));
    }
  }

  /// Handle loading saved language from storage
  Future<void> _onLoadSavedLanguage(
    LoadSavedLanguage event,
    Emitter<LanguageState> emit,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString(_localeKey);
      final countryCode = prefs.getString(_countryCodeKey);

      if (languageCode != null) {
        // Load saved locale
        final locale = countryCode != null && countryCode.isNotEmpty
            ? Locale(languageCode, countryCode)
            : Locale(languageCode);

        emit(state.copyWith(locale: locale));
        print('Loaded saved language: ${locale.languageCode}');
      } else {
        // No saved language, check device locale
        _checkDeviceLocale(emit);
      }
    } catch (error) {
      print('Error loading language: $error');
      // Fallback to English
      emit(state.copyWith(locale: const Locale('en', 'US')));
    }
  }

  /// Handle setting initial language (useful for app startup)
  Future<void> _onSetInitialLanguage(
    SetInitialLanguage event,
    Emitter<LanguageState> emit,
  ) async {
    emit(state.copyWith(locale: event.locale));
    print('Initial language set to: ${event.locale.languageCode}');
  }

  /// Check device locale and set if supported
  Future<void> _checkDeviceLocale(Emitter<LanguageState> emit) async {
    try {
      // Get device locale
      final deviceLocale = WidgetsBinding.instance.platformDispatcher.locale;
      final supportedLocales = ['en', 'am', 'om'];

      if (deviceLocale != null &&
          supportedLocales.contains(deviceLocale.languageCode)) {
        // Device locale is supported
        emit(state.copyWith(locale: deviceLocale));
        print('Using device locale: ${deviceLocale.languageCode}');
      } else {
        // Default to English
        emit(state.copyWith(locale: const Locale('en', 'US')));
        print('Device locale not supported, defaulting to English');
      }
    } catch (error) {
      print('Error checking device locale: $error');
      emit(state.copyWith(locale: const Locale('en', 'US')));
    }
  }

  /// Helper method to get current language code
  String getCurrentLanguageCode() {
    return state.locale.languageCode;
  }

  /// Helper method to check if a specific language is selected
  bool isLanguageSelected(String languageCode) {
    return state.locale.languageCode == languageCode;
  }

  /// Helper method to get full locale string (e.g., 'en_US')
  String getLocaleString() {
    if (state.locale.countryCode != null) {
      return '${state.locale.languageCode}_${state.locale.countryCode}';
    }
    return state.locale.languageCode;
  }
}
