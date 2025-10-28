import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'home': 'Home',
      'history': 'History',
      'profile': 'Profile',
      'language': 'Language',
      'sign_in': 'Sign in',
      'sign_out': 'Sign out',
    },
    'ru': {
      'home': 'Главная',
      'history': 'История',
      'profile': 'Профиль',
      'language': 'Язык',
      'sign_in': 'Войти',
      'sign_out': 'Выйти',
    },
  };

  String t(String key) {
    return _localizedValues[locale.languageCode]?[key] ??
        _localizedValues['en']![key]!;
  }

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'ru'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
