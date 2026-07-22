import 'package:flutter/material.dart';

/// ثيم مخصص لكبار السن: تباين عالٍ، خطوط كبيرة وواضحة،
/// أزرار كبيرة سهلة اللمس، وتصميم خالٍ من الفوضى البصرية.
class AppTheme {
  static const Color primaryGreen = Color(0xFF16624F);
  static const Color primaryGreenDark = Color(0xFF0E4235);
  static const Color background = Color(0xFFFAF9F6);
  static const Color cardColor = Colors.white;
  static const Color danger = Color(0xFFB3261E);
  static const Color textDark = Color(0xFF1A1A1A);

  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryGreen,
        primary: primaryGreen,
        error: danger,
      ),
      fontFamily: 'Cairo', // خط عربي واضح؛ يسقط تلقائيًا لخط النظام إن لم يتوفر
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: textDark,
        ),
        titleLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: textDark,
        ),
        bodyLarge: TextStyle(fontSize: 20, color: textDark),
        bodyMedium: TextStyle(fontSize: 18, color: textDark),
        labelLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        titleTextStyle: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(56),
          textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 2,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.black26),
        ),
      ),
      dividerColor: Colors.black12,
    );
  }
}
