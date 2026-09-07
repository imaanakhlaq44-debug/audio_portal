import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Imaan & Akhlaq brand design system
/// Colors sourced directly from the official Brand Guidelines.
class AppTheme {
  // ---- Brand Colors (from Brand Guidelines PDF) ----
  static const Color primaryPink = Color(0xFFCA2962); // primary-container
  static const Color primaryPinkDeep = Color(0xFFA8014A); // primary
  static const Color secondaryOrange = Color(0xFFDD7A10); // secondary-container
  static const Color secondaryOrangeDeep = Color(0xFF914D00); // secondary
  static const Color navy = Color(0xFF192F52); // tertiary / text
  static const Color tertiaryBlue = Color(0xFF40547A);

  // ---- Surfaces ----
  static const Color background = Color(0xFFFFF8F7);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFFFF0F1);
  static const Color surfaceContainer = Color(0xFFFFE9EB);
  static const Color surfaceContainerHigh = Color(0xFFFCE2E5);
  static const Color surfaceContainerHighest = Color(0xFFF6DCE0);
  static const Color surfaceVariant = Color(0xFFF6DCE0);
  static const Color surfaceDim = Color(0xFFEED4D7);

  // Fixed tone containers (used for category tiles)
  static const Color primaryFixed = Color(0xFFFFD9DF);
  static const Color secondaryFixed = Color(0xFFFFDCC3);
  static const Color tertiaryFixed = Color(0xFFD7E3FF);

  // ---- Text ----
  static const Color onSurface = Color(0xFF26181B);
  static const Color onSurfaceVariant = Color(0xFF594045);
  static const Color outline = Color(0xFF8D7075);
  static const Color outlineVariant = Color(0xFFE0BEC4);

  // ---- Functional ----
  static const Color error = Color(0xFFBA1A1A);
  static const Color success = Color(0xFF3E8E5A);

  static TextStyle headline({
    double size = 24,
    FontWeight weight = FontWeight.w700,
    Color? color,
  }) {
    return GoogleFonts.bricolageGrotesque(
      fontSize: size,
      fontWeight: weight,
      color: color ?? navy,
    );
  }

  static TextStyle body({
    double size = 16,
    FontWeight weight = FontWeight.w400,
    Color? color,
  }) {
    return GoogleFonts.plusJakartaSans(
      fontSize: size,
      fontWeight: weight,
      color: color ?? onSurfaceVariant,
    );
  }

  static ThemeData get lightTheme {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme.light(
        primary: primaryPinkDeep,
        secondary: secondaryOrangeDeep,
        tertiary: navy,
        surface: background,
        error: error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: onSurface,
      ),
      textTheme: base.textTheme.apply(bodyColor: onSurface, displayColor: navy),
      appBarTheme: AppBarTheme(
        backgroundColor: surfaceContainerLowest,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: navy),
        titleTextStyle: headline(size: 22, color: primaryPinkDeep),
      ),
      cardTheme: CardThemeData(
        color: surfaceContainerLowest,
        elevation: 2,
        shadowColor: navy.withValues(alpha: 0.08),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryPinkDeep,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
          elevation: 2,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceContainerLowest,
        hintStyle: body(color: onSurfaceVariant),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(100),
          borderSide: BorderSide(color: outlineVariant.withValues(alpha: 0.4)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(100),
          borderSide: BorderSide(color: outlineVariant.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(100),
          borderSide: const BorderSide(color: primaryPinkDeep, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 14,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surfaceContainerLowest,
        selectedItemColor: secondaryOrange,
        unselectedItemColor: onSurfaceVariant,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
