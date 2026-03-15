import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_translations.dart';

class LocaleManager extends ChangeNotifier {
  LocaleManager._();
  static final LocaleManager instance = LocaleManager._();

  static const String _localKey = 'app_locale';
  String _locale = 'th';

  String get locale => _locale;
  bool get isEnglish => _locale == 'en';
  bool get isThai => _locale == 'th';

  /// Get translated string by key
  String t(String key) => AppTranslations.get(key, _locale);

  /// Load locale from SharedPreferences (for initial app startup / guest)
  Future<void> loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    _locale = prefs.getString(_localKey) ?? 'th';
    notifyListeners();
  }

  /// Load user settings from Firestore after login
  Future<void> loadUserSettings() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        final data = doc.data();
        final settings = data?['settings'] as Map<String, dynamic>?;
        if (settings != null) {
          _locale = settings['locale'] ?? 'th';
        }
      }

      // Also save locally for faster startup
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_localKey, _locale);

      notifyListeners();
    } catch (e) {
      if (kDebugMode) print('Error loading user settings: $e');
    }
  }

  /// Change language and save to Firestore + local
  Future<void> setLocale(String newLocale) async {
    if (_locale == newLocale) return;
    _locale = newLocale;
    notifyListeners();

    // Save locally
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localKey, newLocale);

    // Save to Firestore if logged in
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'settings': {'locale': newLocale},
        }, SetOptions(merge: true));
      } catch (e) {
        if (kDebugMode) print('Error saving locale to Firestore: $e');
      }
    }
  }

  /// Reset to default on logout
  void resetToDefault() {
    _locale = 'th';
    notifyListeners();
  }
}
