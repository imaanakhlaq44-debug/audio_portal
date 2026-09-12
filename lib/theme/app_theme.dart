import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Semantic color palette for the Imaan & Akhlaq brand.
///
/// Exposed as a [ThemeExtension] so every widget reads colors via
/// `context.colors` and automatically adapts to light / dark (night) mode.
/// Brand colors sourced from the official Brand Guidelines.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.primary,
    required this.primaryDeep,
    required this.secondary,
    required this.secondaryDeep,
    required this.tertiary,
    required this.headline,
    required this.background,
    required this.surfaceLowest,
    required this.surfaceLow,
    required this.surface,
    required this.surfaceHigh,
    required this.surfaceHighest,
    required this.surfaceVariant,
    required this.primaryFixed,
    required this.secondaryFixed,
    required this.tertiaryFixed,
    required this.onSurface,
    required this.onSurfaceVariant,
    required this.outline,
    required this.outlineVariant,
    required this.error,
    required this.success,
    required this.shadow,
    required this.isDark,
  });

  // Brand
  final Color primary; // pink container
  final Color primaryDeep; // deep pink (text / accents)
  final Color secondary; // orange (play buttons, active nav)
  final Color secondaryDeep;
  final Color tertiary; // blue accent
  final Color headline; // navy headline text

  // Surfaces
  final Color background;
  final Color surfaceLowest; // cards
  final Color surfaceLow;
  final Color surface;
  final Color surfaceHigh;
  final Color surfaceHighest;
  final Color surfaceVariant;

  // Tinted containers (category tiles)
  final Color primaryFixed;
  final Color secondaryFixed;
  final Color tertiaryFixed;

  // Text / lines
  final Color onSurface;
  final Color onSurfaceVariant;
  final Color outline;
  final Color outlineVariant;

  // Functional
  final Color error;
  final Color success;
  final Color shadow;

  final bool isDark;

  static const AppColors light = AppColors(
    primary: Color(0xFFCA2962),
    primaryDeep: Color(0xFFA8014A),
    secondary: Color(0xFFDD7A10),
    secondaryDeep: Color(0xFF914D00),
    tertiary: Color(0xFF40547A),
    headline: Color(0xFF192F52),
    background: Color(0xFFFFF8F7),
    surfaceLowest: Color(0xFFFFFFFF),
    surfaceLow: Color(0xFFFFF0F1),
    surface: Color(0xFFFFE9EB),
    surfaceHigh: Color(0xFFFCE2E5),
    surfaceHighest: Color(0xFFF6DCE0),
    surfaceVariant: Color(0xFFF6DCE0),
    primaryFixed: Color(0xFFFFD9DF),
    secondaryFixed: Color(0xFFFFDCC3),
    tertiaryFixed: Color(0xFFD7E3FF),
    onSurface: Color(0xFF26181B),
    onSurfaceVariant: Color(0xFF594045),
    outline: Color(0xFF8D7075),
    outlineVariant: Color(0xFFE0BEC4),
    error: Color(0xFFBA1A1A),
    success: Color(0xFF3E8E5A),
    shadow: Color(0xFF192F52),
    isDark: false,
  );

  /// Night mode: deep navy surfaces (matches the splash illustration sky),
  /// softened brand accents so they don't glare in a dark bedroom.
  static const AppColors dark = AppColors(
    primary: Color(0xFFE2557F),
    primaryDeep: Color(0xFFFF8FB0),
    secondary: Color(0xFFF2A24D),
    secondaryDeep: Color(0xFFFFC98A),
    tertiary: Color(0xFF9DB4E0),
    headline: Color(0xFFF1F4FB),
    background: Color(0xFF0B1A33),
    surfaceLowest: Color(0xFF14264A),
    surfaceLow: Color(0xFF122240),
    surface: Color(0xFF1B3159),
    surfaceHigh: Color(0xFF223B69),
    surfaceHighest: Color(0xFF2A4677),
    surfaceVariant: Color(0xFF2A4677),
    primaryFixed: Color(0xFF4A2340),
    secondaryFixed: Color(0xFF4A3524),
    tertiaryFixed: Color(0xFF243A63),
    onSurface: Color(0xFFEFF2F8),
    onSurfaceVariant: Color(0xFFB9C3D6),
    outline: Color(0xFF8391AB),
    outlineVariant: Color(0xFF3B5079),
    error: Color(0xFFFF8A80),
    success: Color(0xFF7BD59B),
    shadow: Color(0xFF000000),
    isDark: true,
  );

  @override
  AppColors copyWith() => this;

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppColors(
      primary: l(primary, other.primary),
      primaryDeep: l(primaryDeep, other.primaryDeep),
      secondary: l(secondary, other.secondary),
      secondaryDeep: l(secondaryDeep, other.secondaryDeep),
      tertiary: l(tertiary, other.tertiary),
      headline: l(headline, other.headline),
      background: l(background, other.background),
      surfaceLowest: l(surfaceLowest, other.surfaceLowest),
      surfaceLow: l(surfaceLow, other.surfaceLow),
      surface: l(surface, other.surface),
      surfaceHigh: l(surfaceHigh, other.surfaceHigh),
      surfaceHighest: l(surfaceHighest, other.surfaceHighest),
      surfaceVariant: l(surfaceVariant, other.surfaceVariant),
      primaryFixed: l(primaryFixed, other.primaryFixed),
      secondaryFixed: l(secondaryFixed, other.secondaryFixed),
      tertiaryFixed: l(tertiaryFixed, other.tertiaryFixed),
      onSurface: l(onSurface, other.onSurface),
      onSurfaceVariant: l(onSurfaceVariant, other.onSurfaceVariant),
      outline: l(outline, other.outline),
      outlineVariant: l(outlineVariant, other.outlineVariant),
      error: l(error, other.error),
      success: l(success, other.success),
      shadow: l(shadow, other.shadow),
      isDark: t < 0.5 ? isDark : other.isDark,
    );
  }
}

/// Convenience accessor: `context.colors.primary`.
extension AppColorsContext on BuildContext {
  AppColors get colors =>
      Theme.of(this).extension<AppColors>() ?? AppColors.light;
}

/// Typography + ThemeData factory.
class AppTheme {
  AppTheme._();

  static TextStyle headline({
    double size = 24,
    FontWeight weight = FontWeight.w700,
    required Color color,
  }) {
    return GoogleFonts.bricolageGrotesque(
      fontSize: size,
      fontWeight: weight,
      color: color,
    );
  }

  static TextStyle body({
    double size = 16,
    FontWeight weight = FontWeight.w400,
    required Color color,
  }) {
    return GoogleFonts.plusJakartaSans(
      fontSize: size,
      fontWeight: weight,
      color: color,
    );
  }

  static ThemeData get lightTheme => _build(AppColors.light);
  static ThemeData get darkTheme => _build(AppColors.dark);

  static ThemeData _build(AppColors c) {
    final brightness = c.isDark ? Brightness.dark : Brightness.light;
    final base = ThemeData(useMaterial3: true, brightness: brightness);
    return base.copyWith(
      extensions: [c],
      scaffoldBackgroundColor: c.background,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: c.primaryDeep,
        onPrimary: c.isDark ? c.background : Colors.white,
        secondary: c.secondaryDeep,
        onSecondary: c.isDark ? c.background : Colors.white,
        tertiary: c.headline,
        onTertiary: c.background,
        surface: c.background,
        onSurface: c.onSurface,
        surfaceContainerHighest: c.surfaceHighest,
        onSurfaceVariant: c.onSurfaceVariant,
        outline: c.outline,
        outlineVariant: c.outlineVariant,
        error: c.error,
        onError: Colors.white,
      ),
      textTheme: GoogleFonts.plusJakartaSansTextTheme(
        base.textTheme,
      ).apply(bodyColor: c.onSurface, displayColor: c.headline),
      appBarTheme: AppBarTheme(
        backgroundColor: c.surfaceLowest,
        foregroundColor: c.headline,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: c.headline),
        titleTextStyle: headline(size: 22, color: c.primaryDeep),
      ),
      cardTheme: CardThemeData(
        color: c.surfaceLowest,
        elevation: 2,
        shadowColor: c.shadow.withValues(alpha: 0.08),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: c.surfaceLowest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle: headline(size: 18, color: c.headline),
        contentTextStyle: body(size: 14, color: c.onSurfaceVariant),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: c.surfaceLowest,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: c.isDark ? c.surfaceHighest : c.headline,
        contentTextStyle: body(size: 14, color: Colors.white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      dividerTheme: DividerThemeData(
        color: c.outlineVariant.withValues(alpha: 0.4),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: c.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
          elevation: 2,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: c.primaryDeep),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? Colors.white : c.outline,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) =>
              s.contains(WidgetState.selected) ? c.secondary : c.surfaceVariant,
        ),
        trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.surfaceLowest,
        hintStyle: body(color: c.onSurfaceVariant),
        counterStyle: body(size: 12, color: c.outline),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(100),
          borderSide: BorderSide(
            color: c.outlineVariant.withValues(alpha: 0.4),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(100),
          borderSide: BorderSide(
            color: c.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(100),
          borderSide: BorderSide(color: c.primaryDeep, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 14,
        ),
      ),
    );
  }
}
