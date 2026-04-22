import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF1976D2);
  static const Color primaryLight = Color(0xFFE8F1FB);
  static const Color errorColor = Color(0xFFE53935);
  static const Color textPrimary = Color(0xFF1E1E24);
  static const Color textSecondary = Color(0xFF888888);
  static const Color textTertiary = Color(0xFF999999);
  static const Color background = Color(0xFFF8F8FA);
  static const Color cardBg = Colors.white;
  static const Color dividerColor = Color(0xFFF0F0F0);

  static ThemeData get theme => ThemeData(
        primaryColor: primaryColor,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          primary: primaryColor,
          error: errorColor,
        ),
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Inter',
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: errorColor,
            side: const BorderSide(color: errorColor),
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      );
}
