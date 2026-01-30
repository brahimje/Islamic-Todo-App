import 'package:flutter/material.dart';
import 'package:islamic_todo_app/generated_files/l10n/app_localizations.dart';

/// Extension on BuildContext to make accessing localized strings easier
extension LocalizationExtension on BuildContext {
  /// Get the current AppLocalizations instance
  AppLocalizations get l10n => AppLocalizations.of(this)!;
  
  /// Check if current locale is Arabic (RTL)
  bool get isArabic => Localizations.localeOf(this).languageCode == 'ar';
  
  /// Get text direction based on locale
  TextDirection get textDirection => isArabic ? TextDirection.rtl : TextDirection.ltr;
}
