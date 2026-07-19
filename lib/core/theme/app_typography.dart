import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Inter-based type scale, tuned for a calm OS-like feel.
class AppTypography {
  const AppTypography._();

  static TextTheme textTheme(
    TextTheme base, {
    required Color primary,
    required Color secondary,
  }) {
    final inter = GoogleFonts.interTextTheme(base);
    return inter
        .copyWith(
          displaySmall: inter.displaySmall?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
          headlineMedium: inter.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
          headlineSmall: inter.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          titleLarge: inter.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
          titleMedium: inter.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
          bodyLarge: inter.bodyLarge?.copyWith(fontSize: 15.5, height: 1.45),
          bodyMedium: inter.bodyMedium?.copyWith(fontSize: 14, height: 1.45),
          bodySmall: inter.bodySmall?.copyWith(fontSize: 12.5, color: secondary),
          labelLarge: inter.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        )
        .apply(bodyColor: primary, displayColor: primary);
  }
}
