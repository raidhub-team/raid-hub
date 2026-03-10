import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// [ThemeProvider]
/// 앱 전체의 다크 모드/라이트 모드 상태를 관리하는 Provider 클래스입니다.
/// 사용자의 마지막 테마 선택을 기기에 저장하여 다음 실행 시에도 유지합니다.
class ThemeProvider with ChangeNotifier {
  static const String _themeKey = "theme_mode";
  bool _isDarkMode = true; // 기본값 다크모드

  bool get isDarkMode => _isDarkMode;

  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  ThemeProvider() {
    _loadThemeFromPrefs();
  }

  /// 테마 전환
  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    _saveThemeToPrefs();
    notifyListeners();
  }

  /// 기기(SharedPreferences)에서 테마 정보 불러오기
  Future<void> _loadThemeFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool(_themeKey) ?? true;
    notifyListeners();
  }

  /// 선택한 테마 정보를 기기에 저장하기
  Future<void> _saveThemeToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, _isDarkMode);
  }
}
