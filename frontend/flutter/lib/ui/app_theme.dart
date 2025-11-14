import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color seedBlue = Color(0xFF4F6AC6);
  static const Color seedTeal = Color(0xFF4FB0C6);

  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seedBlue,
      secondary: seedTeal,
      brightness: Brightness.light,
    );
    return _baseTheme(colorScheme);
  }

  static ThemeData dark() {
    final baseScheme = ColorScheme.fromSeed(
      seedColor: seedBlue,
      secondary: seedTeal,
      brightness: Brightness.dark,
    );
    final colorScheme = baseScheme.copyWith(
      surface: const Color(0xFF181C26),
      surfaceContainerHighest: const Color(0xFF1F2431),
      surfaceContainerHigh: const Color(0xFF1D2331),
      surfaceContainer: const Color(0xFF151A26),
      onSurface: const Color(0xFFE6E9F5),
    );
    return _baseTheme(colorScheme);
  }

  static ThemeData _baseTheme(ColorScheme scheme) {
    final isDark = scheme.brightness == Brightness.dark;
    final baseTextTheme = GoogleFonts.interTextTheme();
    final textTheme = baseTextTheme.apply(
      bodyColor: scheme.onSurface,
      displayColor: scheme.onSurface,
    );
    final cardBaseColor = isDark ? const Color(0xFF1A2434) : Colors.white;
  final glassColor = cardBaseColor.withValues(alpha: isDark ? 0.78 : 0.86);
    final scaffoldColor = isDark ? const Color(0xFF0A0E16) : const Color(0xFFF1F4F8);
    final surfaceHigh = scheme.surfaceContainerHigh;
    final surfaceHighest = scheme.surfaceContainerHighest;
    return ThemeData(
      colorScheme: scheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: scaffoldColor,
      canvasColor: Colors.transparent,
      useMaterial3: true,
      navigationBarTheme: NavigationBarThemeData(
  backgroundColor: surfaceHighest.withValues(alpha: isDark ? 0.55 : 0.7),
  indicatorColor: scheme.primary.withValues(alpha: 0.2),
      ),
      cardTheme: CardThemeData(
        color: glassColor,
        elevation: isDark ? 0 : 8,
        surfaceTintColor: Colors.transparent,
    shadowColor: isDark
      ? Colors.black.withValues(alpha: 0.6)
      : Colors.black.withValues(alpha: 0.08),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      appBarTheme: AppBarTheme(
  backgroundColor: surfaceHigh.withValues(alpha: isDark ? 0.32 : 0.42),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        foregroundColor: scheme.onSurface,
        titleTextStyle: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 6,
        backgroundColor: scheme.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      snackBarTheme: SnackBarThemeData(
  backgroundColor: isDark ? surfaceHigh.withValues(alpha: 0.92) : scheme.primary,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: isDark ? scheme.onSurface : Colors.white,
          fontWeight: FontWeight.w600,
        ),
        behavior: SnackBarBehavior.floating,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: glassColor,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        titleTextStyle: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
  fillColor: isDark ? scheme.surface.withValues(alpha: 0.7) : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: scheme.outline.withValues(alpha: 0.25)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: scheme.outline.withValues(alpha: 0.22)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: scheme.primary.withValues(alpha: 0.7)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: scheme.primary,
          textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
