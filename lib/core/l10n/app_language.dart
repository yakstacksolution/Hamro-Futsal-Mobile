import 'package:flutter/widgets.dart';

/// Languages the app ships translations for.
///
/// [nativeName] is always shown in the language's own script so people can
/// find their language whatever the app is currently set to.
enum AppLanguage {
  english('en', 'English'),
  nepali('ne', 'नेपाली'),
  hindi('hi', 'हिन्दी');

  const AppLanguage(this.code, this.nativeName);

  final String code;
  final String nativeName;

  Locale get locale => Locale(code);

  static List<Locale> get supportedLocales =>
      values.map((AppLanguage language) => language.locale).toList();

  static AppLanguage? fromCode(String? code) {
    if (code == null || code.isEmpty) return null;
    for (final AppLanguage language in values) {
      // Older builds stored the display name ('English', 'नेपाली', 'हिन्दी').
      if (language.code == code || language.nativeName == code) return language;
    }
    return null;
  }

  static AppLanguage? fromLocale(Locale locale) =>
      fromCode(locale.languageCode);
}
