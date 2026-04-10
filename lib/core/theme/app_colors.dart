import 'package:flutter/material.dart';

abstract final class AppColors {
  // Primary - warm orange
  static const Color primary = Color(0xFFFF6B35);
  static const Color primaryLight = Color(0xFFFF9A6C);
  static const Color primaryDark = Color(0xFFE05A2B);

  // Secondary - green
  static const Color secondary = Color(0xFF4CAF50);
  static const Color secondaryLight = Color(0xFF80E27E);
  static const Color secondaryDark = Color(0xFF087F23);

  // Background
  static const Color backgroundLight = Color(0xFFFFFBF5);
  static const Color backgroundDark = Color(0xFF1A1A1A);

  // Surface
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF2C2C2C);

  // Error
  static const Color error = Color(0xFFD32F2F);
  static const Color errorLight = Color(0xFFEF5350);
  static const Color errorDark = Color(0xFFC62828);

  // Neutral
  static const Color onPrimaryLight = Color(0xFFFFFFFF);
  static const Color onSecondaryLight = Color(0xFFFFFFFF);
  static const Color onBackgroundLight = Color(0xFF1C1B1F);
  static const Color onSurfaceLight = Color(0xFF1C1B1F);
  static const Color onErrorLight = Color(0xFFFFFFFF);

  static const Color onPrimaryDark = Color(0xFFFFFFFF);
  static const Color onSecondaryDark = Color(0xFFFFFFFF);
  static const Color onBackgroundDark = Color(0xFFE6E1E5);
  static const Color onSurfaceDark = Color(0xFFE6E1E5);
  static const Color onErrorDark = Color(0xFFFFFFFF);
}
