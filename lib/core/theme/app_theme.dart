import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

/// AURA themes. Dark is the primary experience; light is fully supported.
class AppTheme {
  const AppTheme._();

  static ThemeData dark() {
    final base = ThemeData(brightness: Brightness.dark, useMaterial3: true);
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
    ).copyWith(
      primary: AppColors.primary,
      onPrimary: Colors.white,
      secondary: AppColors.accent,
      onSecondary: AppColors.background,
      surface: AppColors.background,
      onSurface: AppColors.textPrimary,
      surfaceContainerLow: AppColors.card,
      surfaceContainerHighest: AppColors.cardAlt,
      outline: AppColors.border,
      error: AppColors.error,
    );
    return _build(base, scheme, AppColors.textPrimary, AppColors.textSecondary);
  }

  static ThemeData light() {
    final base = ThemeData(brightness: Brightness.light, useMaterial3: true);
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
    ).copyWith(
      primary: AppColors.primary,
      onPrimary: Colors.white,
      secondary: const Color(0xFF0891B2),
      surface: AppColors.lightBackground,
      onSurface: AppColors.lightTextPrimary,
      surfaceContainerLow: AppColors.lightCard,
      surfaceContainerHighest: AppColors.lightCardAlt,
      outline: AppColors.lightBorder,
      error: AppColors.error,
    );
    return _build(
      base,
      scheme,
      AppColors.lightTextPrimary,
      AppColors.lightTextSecondary,
    );
  }

  static ThemeData _build(
    ThemeData base,
    ColorScheme scheme,
    Color textPrimary,
    Color textSecondary,
  ) {
    final radius = BorderRadius.circular(AppSpacing.radiusMd);
    return base.copyWith(
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      textTheme: AppTypography.textTheme(
        base.textTheme,
        primary: textPrimary,
        secondary: textSecondary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: base.textTheme.titleLarge?.copyWith(
          color: textPrimary,
          letterSpacing: 0.2,
        ),
        iconTheme: IconThemeData(color: textPrimary),
      ),
      cardTheme: CardThemeData(
        color: scheme.surfaceContainerLow,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          side: BorderSide(color: scheme.outline),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surfaceContainerLow,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSpacing.radiusXl),
          ),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outline,
        thickness: 1,
        space: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: scheme.surfaceContainerHighest,
        contentTextStyle: TextStyle(color: textPrimary),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerLow,
        hintStyle: TextStyle(color: textSecondary),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 14,
        ),
        border: OutlineInputBorder(borderRadius: radius, borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: scheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 52),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 52),
          foregroundColor: textPrimary,
          side: BorderSide(color: scheme.outline),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
      ),
    );
  }
}
