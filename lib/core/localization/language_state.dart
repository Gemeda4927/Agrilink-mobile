part of 'language_bloc.dart';

class LanguageState extends Equatable {
  final Locale locale;
  final bool isLoading;
  
  const LanguageState({
    required this.locale,
    this.isLoading = false,
  });
  
  // Initial state with English as default
  factory LanguageState.initial() {
    return const LanguageState(
      locale: Locale('en', 'US'),
      isLoading: false,
    );
  }
  
  // Copy with method for state updates
  LanguageState copyWith({
    Locale? locale,
    bool? isLoading,
  }) {
    return LanguageState(
      locale: locale ?? this.locale,
      isLoading: isLoading ?? this.isLoading,
    );
  }
  
  @override
  List<Object> get props => [locale, isLoading];
  
  @override
  String toString() => 'LanguageState { locale: ${locale.languageCode}, isLoading: $isLoading }';
}