import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalizationProvider extends ChangeNotifier {
  String _currentLanguage = 'vi'; // Mặc định tiếng Việt
  static const String _languageKey = 'selected_language';

  String get currentLanguage => _currentLanguage;
  bool get isVietnamese => _currentLanguage == 'vi';
  bool get isEnglish => _currentLanguage == 'en';

  // Load ngôn ngữ đã lưu từ SharedPreferences
  Future<void> loadLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _currentLanguage = prefs.getString(_languageKey) ?? 'vi';
      notifyListeners();
    } catch (e) {
      _currentLanguage = 'vi';
    }
  }

  // Thay đổi ngôn ngữ và lưu vào SharedPreferences
  Future<void> changeLanguage(String languageCode) async {
    if (languageCode != _currentLanguage) {
      _currentLanguage = languageCode;

      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_languageKey, languageCode);
      } catch (e) {
        // Xử lý lỗi nếu cần
      }

      notifyListeners();
    }
  }

  // Toggle giữa tiếng Việt và tiếng Anh
  Future<void> toggleLanguage() async {
    final newLanguage = _currentLanguage == 'vi' ? 'en' : 'vi';
    await changeLanguage(newLanguage);
  }
}
