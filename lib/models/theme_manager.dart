import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeManager extends ChangeNotifier {
  ThemeManager._();
  static final ThemeManager instance = ThemeManager._();

  static const String _key = 'isDarkMode';
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;
  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool(_key) ?? false;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, _isDarkMode);
    notifyListeners();
  }

  // ─── Light Theme ─────────────────────────────────────────────────
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    fontFamily: 'Roboto',
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF6750A4),
      secondary: Color(0xFFCFBDF6),
      tertiary: Color(0xFFFFC7C6),
      surface: Colors.white,
      onSurface: Colors.black,
      onPrimary: Colors.white,
      outline: Color(0xFFEEEEEE),
      surfaceContainerHighest: Color(0xFFF5F5F5),
    ),
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 0,
    ),
    cardTheme: const CardThemeData(color: Colors.white, elevation: 2),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: Color(0xFF6750A4),
      unselectedItemColor: Color(0xFF828282),
    ),
    dividerColor: const Color(0xFFEEEEEE),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFF5F5F5),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      hintStyle: const TextStyle(color: Color(0xFF999999)),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    bottomSheetTheme: const BottomSheetThemeData(backgroundColor: Colors.white),
  );

  // ─── Dark Theme ──────────────────────────────────────────────────
  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    fontFamily: 'Roboto',
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF9F84D2),
      secondary: Color(0xFF7B68A8),
      tertiary: Color(0xFFFF9E9D),
      surface: Color(0xFF1E1E2C),
      onSurface: Color(0xFFE8E8E8),
      onPrimary: Colors.white,
      outline: Color(0xFF2E2E40),
      surfaceContainerHighest: Color(0xFF2A2A3C),
    ),
    scaffoldBackgroundColor: const Color(0xFF141420),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1E1E2C),
      foregroundColor: Color(0xFFE8E8E8),
      elevation: 0,
    ),
    cardTheme: const CardThemeData(color: Color(0xFF1E1E2C), elevation: 4),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF1A1A28),
      selectedItemColor: Color(0xFF9F84D2),
      unselectedItemColor: Color(0xFF6E6E82),
    ),
    dividerColor: const Color(0xFF2E2E40),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF2A2A3C),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      hintStyle: const TextStyle(color: Color(0xFF6E6E82)),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: const Color(0xFF1E1E2C),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Color(0xFF1E1E2C),
    ),
  );
}
