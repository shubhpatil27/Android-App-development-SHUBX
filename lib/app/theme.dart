import 'package:flutter/material.dart';

class ShubXColors {
  static const Color black = Color(0xFF080808);
  static const Color charcoal = Color(0xFF121212);
  static const Color card = Color(0xFF191919);

  static const Color gold = Color(0xFFD4AF37);
  static const Color lightGold = Color(0xFFF1D675);
  static const Color darkGold = Color(0xFF9A7620);

  static const Color white = Color(0xFFF5F5F5);
  static const Color grey = Color(0xFF9E9E9E);
  static const Color darkGrey = Color(0xFF555555);
}

class ShubXTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      scaffoldBackgroundColor: ShubXColors.black,

      colorScheme: const ColorScheme.dark(
        primary: ShubXColors.gold,
        secondary: ShubXColors.lightGold,
        surface: ShubXColors.charcoal,
      ),

      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: ShubXColors.white,
          fontWeight: FontWeight.w800,
        ),
        headlineLarge: TextStyle(
          color: ShubXColors.white,
          fontWeight: FontWeight.w700,
        ),
        headlineMedium: TextStyle(
          color: ShubXColors.white,
          fontWeight: FontWeight.w700,
        ),
        titleLarge: TextStyle(
          color: ShubXColors.white,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(
          color: ShubXColors.white,
        ),
        bodyMedium: TextStyle(
          color: ShubXColors.grey,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ShubXColors.gold,
          foregroundColor: ShubXColors.black,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}