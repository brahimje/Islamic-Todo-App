import 'package:flutter/material.dart';

/// App color palette - Minimalist Black & White theme
class AppColors {
  AppColors._();

  // Primary colors
  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);

  // Gray scale
  static const Color gray50 = Color(0xFFFAFAFA);
  static const Color gray100 = Color(0xFFF5F5F5);
  static const Color gray200 = Color(0xFFEEEEEE);
  static const Color gray300 = Color(0xFFE0E0E0);
  static const Color gray400 = Color(0xFFBDBDBD);
  static const Color gray500 = Color(0xFF9E9E9E);
  static const Color gray600 = Color(0xFF757575);
  static const Color gray700 = Color(0xFF616161);
  static const Color gray800 = Color(0xFF424242);
  static const Color gray900 = Color(0xFF212121);

  // Semantic colors (subtle, still minimalist)
  static const Color success = Color(0xFF2E7D32);
  static const Color successLight = Color(0xFFE8F5E9);
  static const Color warning = Color(0xFFF57C00);
  static const Color warningLight = Color(0xFFFFF3E0);
  static const Color error = Color(0xFFC62828);
  static const Color errorLight = Color(0xFFFFEBEE);

  // Prayer-specific colors (optional accents)
  static const Color prayerFajr = Color(0xFF5C6BC0);
  static const Color prayerDhuhr = Color(0xFFFFB74D);
  static const Color prayerAsr = Color(0xFF81C784);
  static const Color prayerMaghrib = Color(0xFFE57373);
  static const Color prayerIsha = Color(0xFF7986CB);

  // Background colors
  static const Color background = white;
  static const Color surface = gray50;
  static const Color cardBackground = gray100;

  // Text colors
  static const Color textPrimary = gray900;
  static const Color textSecondary = gray600;
  static const Color textTertiary = gray500;
  static const Color textOnDark = white;

  // Border colors
  static const Color border = gray200;
  static const Color borderLight = gray100;
  static const Color borderDark = gray400;
}
