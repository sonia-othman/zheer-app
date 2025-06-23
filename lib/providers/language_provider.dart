import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zheer/services/api_service.dart';

class LanguageProvider extends ChangeNotifier {
  final ApiService _apiService;
  Locale _currentLocale = const Locale('en', '');
  List<String> _availableLanguages = ['en', 'ar', 'ku'];

  static const List<Locale> supportedLocales = [
    Locale('en', ''),
    Locale('ar', ''),
    Locale('ku', ''),
  ];

  LanguageProvider(this._apiService) {
    _loadSavedLanguage();
    _loadAvailableLanguages();
  }

  Locale get currentLocale => _currentLocale;
  List<String> get availableLanguages => _availableLanguages;
  String get currentLanguageCode => _currentLocale.languageCode;

  String getLanguageName(String code) {
    switch (code) {
      case 'en':
        return 'English';
      case 'ar':
        return 'العربية';
      case 'ku':
        return 'کوردی';
      default:
        return code.toUpperCase();
    }
  }

  String getLanguageNameInEnglish(String code) {
    switch (code) {
      case 'en':
        return 'English';
      case 'ar':
        return 'Arabic';
      case 'ku':
        return 'Kurdish';
      default:
        return code.toUpperCase();
    }
  }

  Future<void> _loadSavedLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLang = prefs.getString('selected_language') ?? 'en';

      if (_availableLanguages.contains(savedLang)) {
        _currentLocale = Locale(savedLang, '');
      } else {
        _currentLocale = const Locale('en', '');
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading saved language: $e');
      _currentLocale = const Locale('en', '');
    }
  }

  Future<void> _loadAvailableLanguages() async {
    try {
      final languages = await _apiService.getAvailableLanguages();
      if (languages.isNotEmpty) {
        final allLanguages = <String>{'en', 'ar', 'ku', ...languages}.toList();
        _availableLanguages = allLanguages;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading available languages: $e');
    }
  }

  Future<bool> changeLanguage(String languageCode) async {
    if (!_availableLanguages.contains(languageCode)) {
      debugPrint('Language $languageCode is not supported');
      return false;
    }

    try {
      bool serverSuccess = true;
      try {
        serverSuccess = await _apiService.switchLanguage(languageCode);
      } catch (e) {
        debugPrint('Server language update failed: $e');
      }

      _currentLocale = Locale(languageCode, '');

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('selected_language', languageCode);

      notifyListeners();

      debugPrint(
        'Language changed to: ${getLanguageNameInEnglish(languageCode)}',
      );
      return true;
    } catch (e) {
      debugPrint('Error changing language: $e');
      return false;
    }
  }

  bool isRTL() {
    return _currentLocale.languageCode == 'ar' ||
        _currentLocale.languageCode == 'ku';
  }

  TextDirection getTextDirection() {
    return isRTL() ? TextDirection.rtl : TextDirection.ltr;
  }

  String getFontFamily() {
    switch (_currentLocale.languageCode) {
      case 'ar':
      case 'ku':
        return 'NotoSansArabic';
      case 'en':
      default:
        return 'Roboto';
    }
  }
}
