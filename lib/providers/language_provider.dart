// providers/language_provider.dart
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class LanguageProvider with ChangeNotifier {
  final ApiService apiService;
  Locale _currentLocale = const Locale('en', '');

  LanguageProvider(this.apiService);

  Locale get currentLocale => _currentLocale;

  Future<void> switchLanguage(String languageCode) async {
    try {
      await apiService.switchLanguage(languageCode);
      _currentLocale = Locale(languageCode);
      notifyListeners();
    } catch (e) {
      print("Error switching language: $e");
      rethrow;
    }
  }
}
