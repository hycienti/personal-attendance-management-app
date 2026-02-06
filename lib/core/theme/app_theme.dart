import 'package:flutter/material.dart';

import '../constants/app_constants.dart';
import 'app_colors.dart';

/// Centralized app theme (light and dark).
/// Uses system font to avoid network font loading (works offline / in restricted environments).
abstract final class AppTheme {
  AppTheme._();

  static TextStyle _style({
    required double fontSize,
    required FontWeight fontWeight,
    required Color color,
  }) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
    );
  }

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: AppColors.textOnPrimary,
        surface: AppColors.backgroundLight,
        onSurface: Colors.black87,
        error: AppColors.error,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: AppColors.backgroundLight,
      textTheme: _textTheme(Colors.black87),
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: AppColors.backgroundLight,
        foregroundColor: Colors.black87,
        titleTextStyle: _style(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Colors.black87,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
          side: BorderSide(color: Colors.grey.shade200),
        ),
        color: Colors.white,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        hintStyle: TextStyle(color: Colors.grey.shade500),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(AppConstants.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          textStyle: _style(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textOnPrimary,
          ),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondaryLight,
      ),
    );
  }

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: AppColors.primary,
        onPrimary: AppColors.textOnPrimary,
        surface: AppColors.backgroundDark,
        onSurface: Colors.white,
        error: AppColors.error,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: AppColors.backgroundDark,
      textTheme: _textTheme(Colors.white),
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: AppColors.backgroundDark,
        foregroundColor: Colors.white,
        titleTextStyle: _style(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
          side: const BorderSide(color: Color(0xFF334155)),
        ),
        color: AppColors.aluNavy,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1E293B),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF334155)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(AppConstants.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          textStyle: _style(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textOnPrimary,
          ),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondaryDark,
        backgroundColor: Color(0xFF0D1117),
      ),
    );
  }

  static TextTheme _textTheme(Color defaultColor) {
    return TextTheme(
      displayLarge: _style(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: defaultColor,
      ),
      headlineMedium: _style(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: defaultColor,
      ),
      titleLarge: _style(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: defaultColor,
      ),
      titleMedium: _style(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: defaultColor,
      ),
      bodyLarge: _style(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: defaultColor,
      ),
      bodyMedium: _style(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: defaultColor,
      ),
      labelLarge: _style(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: defaultColor,
      ),
    );
  }
}
