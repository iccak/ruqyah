import 'package:flutter/material.dart';

/// ثيم مخصص لكبار السن، مبني على تصميم مرجعي: أزرار كبسولية (Pill)،
/// خلفية "هيدر" خضراء نعناعية فاتحة، وبطاقات بيضاء دافئة على خلفية
/// كريمية، مع تباين عالٍ وخطوط كبيرة وواضحة.
class AppTheme {
  // اللون الأساسي (الأزرار الصلبة، النصوص البارزة)
  static const Color primaryGreen = Color(0xFF1B5E3F);
  static const Color primaryGreenDark = Color(0xFF123F2A);

  // خلفية الهيدر (منطقة العنوان العلوية) - أخضر نعناعي فاتح جدًا
  static const Color heroBackground = Color(0xFFDCEEDD);
  // نمط زخرفي خفيف فوق الهيدر
  static const Color heroPattern = Color(0x141B5E3F);

  // خلفية عامة كريمية دافئة (بدل الأبيض البارد)
  static const Color background = Color(0xFFF8F6EF);
  static const Color cardColor = Colors.white;

  // أخضر فاتح للعناصر الثانوية: حقول الإدخال، شريط البحث، زر "تعديل"
  static const Color softGreen = Color(0xFFDCEEDF);
  static const Color softGreenBorder = Color(0xFFBFDDC4);

  // أحمر فاتح لأزرار الحذف
  static const Color softPink = Color(0xFFFBE2E2);
  static const Color danger = Color(0xFFC23B3B);

  static const Color textDark = Color(0xFF20291F);
  static const Color textMuted = Color(0xFF6B7A6C);

  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryGreen,
        primary: primaryGreen,
        error: danger,
        surface: background,
      ),
      fontFamily: 'Cairo', // خط عربي واضح؛ يسقط تلقائيًا لخط النظام إن لم يتوفر
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.w800,
          color: textDark,
        ),
        titleLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: textDark,
        ),
        bodyLarge: TextStyle(fontSize: 20, color: textDark),
        bodyMedium: TextStyle(fontSize: 17, color: textDark),
        labelLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: heroBackground,
        foregroundColor: primaryGreenDark,
        centerTitle: true,
        elevation: 0,
        titleTextStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: primaryGreenDark,
        ),
      ),
      // كل الأزرار البارزة كبسولية الشكل (Stadium) بحسب التصميم المرجعي
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(58),
          textStyle: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
          elevation: 0,
          shape: const StadiumBorder(),
        ),
      ),
      cardTheme: CardTheme(
        color: cardColor,
        elevation: 0,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFFEDEAE0)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: softGreen,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: primaryGreen, width: 1.5),
        ),
        hintStyle: const TextStyle(color: textMuted),
      ),
      dividerColor: Colors.black12,
    );
  }
}
