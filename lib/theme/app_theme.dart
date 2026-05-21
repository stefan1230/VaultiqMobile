import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Invoice-style fintech palette: charcoal base + vibrant lime accent.
class AppColors {
  static const lime = Color(0xFFD4F94C);
  static const limeDark = Color(0xFFB8E635);
  static const onLime = Color(0xFF0A0C0F);

  static const surfaceDark = Color(0xFF0D0F12);
  static const surfaceDarkElevated = Color(0xFF14171D);
  static const cardDark = Color(0xFF1A1E26);
  static const cardDarkElevated = Color(0xFF22262F);
  static const cardDarkBorder = Color(0xFF2E333D);

  static const textPrimary = Color(0xFFFFFFFF);
  static const textMuted = Color(0xFF8B929E);

  static const orange = Color(0xFFF59E0B);
  static const coral = Color(0xFFFF8A65);
  static const emerald = lime;
  static const violet = Color(0xFFA78BFA);
  static const amber = orange;

  // Aliases used across the app
  static const teal = lime;
  static const tealDark = limeDark;

  static const surfaceLight = Color(0xFFF4F5F7);
  static const cardLight = Colors.white;

  static LinearGradient meshBackground(bool dark) => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: dark
            ? [surfaceDark, const Color(0xFF101218), surfaceDark]
            : [const Color(0xFFE8EBF0), surfaceLight, surfaceLight],
      );

  static Color primary(bool dark) => dark ? lime : limeDark;
  static Color onPrimary(bool dark) => onLime;
}

TextTheme _textTheme(Brightness brightness) {
  final base = brightness == Brightness.dark
      ? ThemeData.dark().textTheme
      : ThemeData.light().textTheme;
  final primaryColor =
      brightness == Brightness.dark ? AppColors.textPrimary : Colors.black87;
  return GoogleFonts.plusJakartaSansTextTheme(base).apply(
    bodyColor: brightness == Brightness.dark ? AppColors.textMuted : null,
    displayColor: primaryColor,
  ).copyWith(
    displaySmall: GoogleFonts.plusJakartaSans(
      fontWeight: FontWeight.w800,
      letterSpacing: -1.2,
      color: primaryColor,
    ),
    headlineMedium: GoogleFonts.plusJakartaSans(
      fontWeight: FontWeight.w800,
      letterSpacing: -0.5,
      color: primaryColor,
    ),
    headlineSmall: GoogleFonts.plusJakartaSans(
      fontWeight: FontWeight.w700,
      letterSpacing: -0.3,
      color: primaryColor,
    ),
    titleLarge: GoogleFonts.plusJakartaSans(
      fontWeight: FontWeight.w700,
      color: primaryColor,
    ),
    titleMedium: GoogleFonts.plusJakartaSans(
      fontWeight: FontWeight.w600,
      color: primaryColor,
    ),
    labelLarge: GoogleFonts.plusJakartaSans(
      fontWeight: FontWeight.w600,
      letterSpacing: 0.3,
    ),
  );
}

ThemeData buildLightTheme() {
  final scheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.limeDark,
    onPrimary: AppColors.onLime,
    secondary: AppColors.limeDark,
    onSecondary: AppColors.onLime,
    surface: AppColors.surfaceLight,
    onSurface: Colors.black87,
    error: AppColors.coral,
    onError: Colors.white,
  );
  return _buildTheme(scheme, Brightness.light);
}

ThemeData buildDarkTheme() {
  final scheme = ColorScheme(
    brightness: Brightness.dark,
    primary: AppColors.lime,
    onPrimary: AppColors.onLime,
    secondary: AppColors.lime,
    onSecondary: AppColors.onLime,
    surface: AppColors.surfaceDark,
    onSurface: AppColors.textPrimary,
    surfaceContainerHighest: AppColors.cardDarkElevated,
    error: AppColors.coral,
    onError: Colors.white,
  );
  return _buildTheme(scheme, Brightness.dark);
}

ThemeData _buildTheme(ColorScheme scheme, Brightness brightness) {
  final dark = brightness == Brightness.dark;
  final cardColor = dark ? AppColors.cardDark : AppColors.cardLight;
  final cardBorder =
      dark ? AppColors.cardDarkBorder : Colors.grey.shade200;

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    textTheme: _textTheme(brightness),
    scaffoldBackgroundColor:
        dark ? AppColors.surfaceDark : AppColors.surfaceLight,
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
      color: cardColor,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: cardBorder),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primary(dark),
        foregroundColor: AppColors.onPrimary(dark),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
        textStyle: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w800,
          fontSize: 15,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary(dark),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        side: BorderSide(color: AppColors.primary(dark), width: 1.5),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      height: 64,
      elevation: 0,
      backgroundColor: dark ? AppColors.surfaceDarkElevated : AppColors.cardLight,
      indicatorColor: AppColors.lime.withValues(alpha: dark ? 0.18 : 0.25),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return GoogleFonts.plusJakartaSans(
          fontSize: 0,
          height: 0,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          color: selected ? AppColors.lime : AppColors.textMuted,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return IconThemeData(
          size: 26,
          color: selected
              ? AppColors.lime
              : (dark ? AppColors.textMuted : Colors.grey.shade600),
        );
      }),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: dark ? AppColors.cardDarkElevated : Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: cardBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: cardBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: AppColors.primary(dark), width: 2),
      ),
      labelStyle: GoogleFonts.plusJakartaSans(
        fontWeight: FontWeight.w500,
        color: dark ? AppColors.textMuted : null,
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: dark ? AppColors.cardDarkElevated : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: AppColors.lime,
      linearTrackColor: dark
          ? AppColors.cardDarkBorder
          : Colors.grey.shade300,
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
  );
}
