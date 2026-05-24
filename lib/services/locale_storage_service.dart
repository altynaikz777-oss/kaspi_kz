import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleStorageService {
  static const _key = 'app_locale_code';

  Future<Locale> readLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_key) ?? 'ru';
    return Locale(code);
  }

  Future<void> saveLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, locale.languageCode);
  }
}
