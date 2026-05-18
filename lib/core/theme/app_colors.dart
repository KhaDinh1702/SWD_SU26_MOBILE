import 'package:flutter/material.dart';

class AppColors {
  // Primary palette (from brand image)
  static const cream = Color(0xFFF2EDE8);
  static const lightBlue = Color(0xFFB8D4E0);
  static const primaryBlue = Color(0xFF1E9ED8);
  static const darkBlue = Color(0xFF185E78);

  // Text
  static const textDark = Color(0xFF1A2B35);
  static const textMedium = Color(0xFF4A6572);
  static const textLight = Color(0xFF8AA5B0);

  // Utility
  static const white = Color(0xFFFFFFFF);
  static const cardBg = Color(0xFFFFFFFF);
  static const divider = Color(0xFFE8EEF2);

  // Tier colors
  static const tierGold = Color(0xFFF4C542);
  static const tierSilver = Color(0xFFB0BEC5);
  static const tierPlatinum = Color(0xFF90CAF9);
  static const tierMember = Color(0xFF80CBC4);

  // Gradient shortcuts
  static const List<Color> primaryGradient = [darkBlue, primaryBlue];
  static const List<Color> lightGradient = [lightBlue, primaryBlue];
}
