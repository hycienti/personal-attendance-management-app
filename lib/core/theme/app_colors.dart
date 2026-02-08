import 'package:flutter/material.dart';

/// ALU brand and app colors. Use via theme or directly when needed.
abstract final class AppColors {
  AppColors._();

  // Primary (ALU Red)
  static const Color primary = Color(0xFFD32F2F);
  static const Color primaryDark = Color(0xFFB71C1C);
  static const Color aluRed = Color(0xFFD32F2F);

  // Navy / Background
  static const Color aluNavy = Color(0xFF1A2332);
  static const Color backgroundLight = Color(0xFFF6F6F8);
  static const Color backgroundDark = Color(0xff0f172a);
  static const Color surfaceDark = Color(0xFF162033);
  static const Color cardDark = Color(0xFF1E293B);

  // Semantic
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFFBBF24);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Text
  static const Color textSecondaryLight = Color(0xFF64748B);
  static const Color textSecondaryDark = Color(0xFF92A4C9);
  static const Color textOnPrimary = Colors.white;
}
