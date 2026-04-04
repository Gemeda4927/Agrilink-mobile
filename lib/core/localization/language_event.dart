part of 'language_bloc.dart';

abstract class LanguageEvent extends Equatable {
  const LanguageEvent();
  
  @override
  List<Object> get props => [];
}

class ChangeLanguage extends LanguageEvent {
  final Locale locale;
  
  const ChangeLanguage(this.locale);
  
  @override
  List<Object> get props => [locale];
  
  @override
  String toString() => 'ChangeLanguage { locale: ${locale.languageCode} }';
}

class LoadSavedLanguage extends LanguageEvent {
  const LoadSavedLanguage();
  
  @override
  List<Object> get props => [];
}

class SetInitialLanguage extends LanguageEvent {
  final Locale locale;
  
  const SetInitialLanguage(this.locale);
  
  @override
  List<Object> get props => [locale];
}