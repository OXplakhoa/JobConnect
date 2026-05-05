import 'package:flutter/material.dart';

class AppColors {
  const AppColors._();

  static const Color primary = Color(0xFF0D9488);
  static const Color onPrimary = Color(0xFFFFFFFF);
  
  // Light theme neutral tokens
  static const Color background = Color(0xFFF8F7F4);
  static const Color surface = Color(0xFFFDFCFA);
  static const Color surfaceVariant = Color(0xFFF1F0ED);
  static const Color divider = Color(0xFFE8E6E1);
  static const Color textPrimary = Color(0xFF1A1D1E);
  static const Color textSecondary = Color(0xFF6B7272);

  // Semantic tokens
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFDC2626);

  // Dark theme neutral tokens (skeleton - TODO: T-38 polish pass)
  static const Color backgroundDark = Color(0xFF1A1D1E);
  static const Color surfaceDark = Color(0xFF242828);
  static const Color textPrimaryDark = Color(0xFFF0EFED);
  static const Color textSecondaryDark = Color(0xFF9CA09E);
}
