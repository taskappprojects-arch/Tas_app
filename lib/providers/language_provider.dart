import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_app/utils/app_strings.dart';

class LanguageProvider with ChangeNotifier {
  String _currentLang = 'en';

  String get currentLang => _currentLang;
  bool get isBengali => _currentLang == 'bn';

  LanguageProvider() {
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    _currentLang = prefs.getString('language') ?? 'en';
    notifyListeners();
  }

  Future<void> setLanguage(String langCode) async {
    if (['en', 'bn', 'hi'].contains(langCode)) {
      _currentLang = langCode;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('language', langCode);
      notifyListeners();
    }
  }

  String translate(String key) {
    return AppStrings.translations[_currentLang]?[key] ?? AppStrings.translations['en']?[key] ?? key;
  }
}
