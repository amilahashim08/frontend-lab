import 'package:flutter/material.dart';

/// Dark gaming-dashboard theme per REQUIREMENTS §12.
class AppTheme {
  AppTheme._();

  static const Color background = Color(0xFF0A0E17);
  static const Color surface = Color(0xFF12182A);
  static const Color surfaceElevated = Color(0xFF1A2238);
  static const Color primary = Color(0xFF00D4FF);
  static const Color secondary = Color(0xFF9B5CFF);
  static const Color accent = Color(0xFF00FFB2);
  static const Color error = Color(0xFFFF5C7A);
  static const Color textPrimary = Color(0xFFF0F4FF);
  static const Color textSecondary = Color(0xFF8B9BB8);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: 'Roboto',
      colorScheme: const ColorScheme.dark(
        surface: surface,
        primary: primary,
        secondary: secondary,
        tertiary: accent,
        error: error,
        onSurface: textPrimary,
        onPrimary: background,
      ),
      scaffoldBackgroundColor: background,
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: primary.withValues(alpha: 0.2)),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        foregroundColor: textPrimary,
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: textPrimary),
        bodyMedium: TextStyle(color: textPrimary),
        bodySmall: TextStyle(color: textSecondary),
        titleLarge: TextStyle(color: textPrimary),
        titleMedium: TextStyle(color: textPrimary),
        titleSmall: TextStyle(color: textPrimary),
        headlineMedium: TextStyle(color: textPrimary),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceElevated,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        hintStyle: const TextStyle(color: textSecondary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: background,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  static BoxDecoration glowCard({Color? glowColor}) {
    return BoxDecoration(
      color: surface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: (glowColor ?? primary).withValues(alpha: 0.35),
      ),
      boxShadow: [
        BoxShadow(
          color: (glowColor ?? primary).withValues(alpha: 0.12),
          blurRadius: 20,
          spreadRadius: 0,
        ),
      ],
    );
  }
}
