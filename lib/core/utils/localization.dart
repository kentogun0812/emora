// lib/core/utils/localization.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  late Map<String, String> _localizedStrings;

  Future<bool> load() async {
    // Load corresponding language file
    String jsonString = await rootBundle.loadString(
        'assets/i18n/${locale.languageCode}.json');
    Map<String, dynamic> jsonMap = json.decode(jsonString);

    _localizedStrings = _flattenMap(jsonMap);
    return true;
  }

  // Flatten nested JSON structure into flat keys: e.g. login.welcome
  Map<String, String> _flattenMap(Map<String, dynamic> map, [String prefix = '']) {
    Map<String, String> flattened = {};
    map.forEach((key, value) {
      String newKey = prefix.isEmpty ? key : '$prefix.$key';
      if (value is Map<String, dynamic>) {
        flattened.addAll(_flattenMap(value, newKey));
      } else {
        flattened[newKey] = value.toString();
      }
    });
    return flattened;
  }

  String translate(String key, [Map<String, String>? arguments]) {
    String value = _localizedStrings[key] ?? key;
    if (arguments != null) {
      arguments.forEach((argKey, argValue) {
        value = value.replaceAll('{$argKey}', argValue);
      });
    }
    return value;
  }
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['vn', 'en', 'ko', 'jp'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    AppLocalizations localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

// Extension Helper for concise translation in Widget: context.translate('key')
extension LocalizationExtension on BuildContext {
  String translate(String key, [Map<String, String>? arguments]) {
    return AppLocalizations.of(this)?.translate(key, arguments) ?? key;
  }
}
