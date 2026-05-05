import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        surface: AppColors.background, // Background color as primary surface
        surfaceContainer: AppColors.surface, // Card background
        surfaceContainerHighest: AppColors.surfaceVariant, // Elevated sheets
        outlineVariant: AppColors.divider, // Borders
        error: AppColors.error,
      ),
      scaffoldBackgroundColor: AppColors.background,
      dividerColor: AppColors.divider,
      textTheme: const TextTheme(
        displayLarge: AppTextStyles.display,
        headlineLarge: AppTextStyles.headline,
        titleLarge: AppTextStyles.title,
        bodyLarge: AppTextStyles.body,
        bodyMedium: AppTextStyles.bodySmall,
        labelLarge: AppTextStyles.label,
      ).apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      ),
    );
  }

  // TODO: T-38 polish pass
  static ThemeData get dark {
    return ThemeData.dark().copyWith(
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        surface: AppColors.backgroundDark,
        surfaceContainer: AppColors.surfaceDark,
        error: AppColors.error,
      ),
      scaffoldBackgroundColor: AppColors.backgroundDark,
    );
  }
}
