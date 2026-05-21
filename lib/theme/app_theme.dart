import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Fintech palette — deep navy base, electric teal accent, soft surfaces.
class AppColors {
  static const teal = Color(0xFF2DD4BF);
  static const tealDark = Color(0xFF0D9488);
  static const mint = Color(0xFF5EEAD4);
  static const emerald = Color(0xFF34D399);
  static const amber = Color(0xFFFBBF24);
  static const coral = Color(0xFFFB7185);
  static const violet = Color(0xFF818CF8);

  static const surfaceDark = Color(0xFF0B1120);
  static const surfaceDarkElevated = Color(0xFF111827);
  static const cardDark = Color(0xFF1A2332);
  static const cardDarkBorder = Color(0xFF2A3548);

  static const surfaceLight = Color(0xFFF1F5F9);
  static const cardLight = Colors.white;

  static const gradientHero = [Color(0xFF0D9488), Color(0xFF0E7490), Color(0xFF1E3A5F)];
  static const gradientHeroLight = [Color(0xFF14B8A6), Color(0xFF0891B2), Color(0xFF1E40AF)];

  static LinearGradient heroGradient(bool dark) => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: dark ? gradientHero : gradientHeroLight,
      );

  static LinearGradient meshBackground(bool dark) => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: dark
            ? [
                const Color(0xFF0B1120),
                const Color(0xFF0F172A),
                const Color(0xFF0B1120),
              ]
            : [
                const Color(0xFFE0F2FE),
                AppColors.surfaceLight,
                AppColors.surfaceLight,
              ],
      );
}

TextTheme _textTheme(Brightness brightness) {
  final base = brightness == Brightness.dark
      ? ThemeData.dark().textTheme
      : ThemeData.light().textTheme;
  return GoogleFonts.plusJakartaSansTextTheme(base).copyWith(
    displaySmall: GoogleFonts.plusJakartaSans(
      fontWeight: FontWeight.w800,
      letterSpacing: -1.2,
    ),
    headlineMedium: GoogleFonts.plusJakartaSans(
      fontWeight: FontWeight.w700,
      letterSpacing: -0.5,
    ),
    headlineSmall: GoogleFonts.plusJakartaSans(
      fontWeight: FontWeight.w700,
      letterSpacing: -0.3,
    ),
    titleLarge: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
    titleMedium: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
    labelLarge: GoogleFonts.plusJakartaSans(
      fontWeight: FontWeight.w600,
      letterSpacing: 0.2,
    ),
  );
}

ThemeData buildLightTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.tealDark,
    brightness: Brightness.light,
    surface: AppColors.surfaceLight,
    primary: AppColors.tealDark,
  );
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: scheme,
    textTheme: _textTheme(Brightness.light),
    scaffoldBackgroundColor: AppColors.surfaceLight,
    appBarTheme: AppBarTheme(
      centerTitle: false,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: scheme.onSurface,
      titleTextStyle: GoogleFonts.plusJakartaSans(
        fontSize: 20,
        fontWeight: FontWeight.w800,
        color: scheme.onSurface,
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.cardLight,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.grey.shade200),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.tealDark,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 0,
        textStyle: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w700,
          fontSize: 15,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        side: BorderSide(color: AppColors.tealDark.withValues(alpha: 0.4)),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      height: 72,
      elevation: 0,
      backgroundColor: AppColors.cardLight,
      indicatorColor: AppColors.teal.withValues(alpha: 0.18),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return GoogleFonts.plusJakartaSans(
          fontSize: 11,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return IconThemeData(
          size: 24,
          color: selected ? AppColors.tealDark : Colors.grey.shade600,
        );
      }),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.tealDark, width: 2),
      ),
      labelStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w500),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
  );
}

ThemeData buildDarkTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.teal,
    brightness: Brightness.dark,
    surface: AppColors.surfaceDark,
    primary: AppColors.teal,
  );
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: scheme,
    textTheme: _textTheme(Brightness.dark),
    scaffoldBackgroundColor: AppColors.surfaceDark,
    appBarTheme: AppBarTheme(
      centerTitle: false,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: scheme.onSurface,
      titleTextStyle: GoogleFonts.plusJakartaSans(
        fontSize: 20,
        fontWeight: FontWeight.w800,
        color: scheme.onSurface,
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.cardDark,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.cardDarkBorder),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.teal,
        foregroundColor: AppColors.surfaceDark,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 0,
        textStyle: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w700,
          fontSize: 15,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        side: BorderSide(color: AppColors.teal.withValues(alpha: 0.35)),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      height: 72,
      elevation: 0,
      backgroundColor: AppColors.surfaceDarkElevated,
      indicatorColor: AppColors.teal.withValues(alpha: 0.22),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return GoogleFonts.plusJakartaSans(
          fontSize: 11,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          color: selected ? AppColors.teal : Colors.white54,
        );
      }),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.05),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.cardDarkBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.cardDarkBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.teal, width: 2),
      ),
      labelStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w500),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
  );
}
