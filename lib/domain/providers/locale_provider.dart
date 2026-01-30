import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider for app locale management
final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});

/// Notifier for managing app locale
class LocaleNotifier extends StateNotifier<Locale> {
  static const String _localeKey = 'app_locale';
  
  LocaleNotifier() : super(const Locale('en')) {
    _loadLocale();
  }

  /// Load saved locale from preferences
  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString(_localeKey);
    
    if (languageCode != null) {
      state = Locale(languageCode);
    }
  }

  /// Set locale and save to preferences
  Future<void> setLocale(Locale locale) async {
    state = locale;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, locale.languageCode);
  }

  /// Toggle between English and Arabic
  Future<void> toggleLocale() async {
    final newLocale = state.languageCode == 'en' 
        ? const Locale('ar') 
        : const Locale('en');
    await setLocale(newLocale);
  }
}
