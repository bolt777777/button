import 'package:flutter/material.dart';

const Color kCoral = Color(0xFFE8615A);
const Color kCoralLight = Color(0xFFF0877F);
const Color kCoralDark = Color(0xFFC94C45);
const Color kCoralBg = Color(0xFFFFF5F4);
const Color kTextPrimary = Color(0xFF1E1E2D);
const Color kTextSecondary = Color(0xFF8E8E93);
const Color kBackground = Color(0xFFFAFAFC);
const Color kCardWhite = Colors.white;
const Color kGreen = Color(0xFF34C759);
const Color kOrange = Color(0xFFFF9500);

ThemeData buildAppTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: kCoral,
    brightness: Brightness.light,
    primary: kCoral,
    onPrimary: Colors.white,
    surface: kBackground,
    onSurface: kTextPrimary,
    error: kCoralDark,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: Colors.white,
    visualDensity: VisualDensity.standard,
    fontFamily: '.SF Pro Text',
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: Colors.white,
      foregroundColor: kTextPrimary,
      titleTextStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
        color: kTextPrimary,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: kCardWhite,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        elevation: 0,
        backgroundColor: kCoral,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: kCoral,
        side: const BorderSide(color: kCoral, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFF5F5F7),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: kCoral, width: 1.5),
      ),
      hintStyle: const TextStyle(color: kTextSecondary, fontSize: 15),
      labelStyle: const TextStyle(color: kTextSecondary, fontSize: 15),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
    ),
    dialogTheme: DialogThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
  );
}
