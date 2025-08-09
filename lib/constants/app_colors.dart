import 'package:flutter/material.dart';

class AppColors {
  // Background colors
  static const Color backgroundColor = Color(0xFFE4E2D6);
  
  // Primary colors
  static const Color primaryRed = Color(0xFFca0707);
  static const Color primaryOrange = Color(0xFFd56e0d);
  
  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryRed, primaryOrange],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Header gradient (135 degrees)
  static const LinearGradient headerGradient = LinearGradient(
    colors: [primaryRed, primaryOrange],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    transform: GradientRotation(135 * 3.14159 / 180), // 135 degrees in radians
  );
  
  // Text colors
  static const Color textPrimary = Colors.black;
  static const Color textSecondary = Color(0xFF666666);
  static const Color textLight = Color(0xFF999999);
  
  // Card colors
  static const Color cardBackground = Colors.white;
  static const Color cardShadow = Color(0x40000000);
  
  // Status colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFF44336);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);
  
  // Recipe card specific colors
  static const Color recipeCardBackground = Colors.white;
  static const Color recipeCardShadow = Color(0x40000000);
  static const double recipeCardBorderRadius = 16.0;
  static const double recipeCardBlurRadius = 10.0;
  static const Offset recipeCardOffset = Offset(2, 4);
} 