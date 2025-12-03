import 'package:flutter/material.dart';

/// Color palette aplikasi
class AppColors {
  // Primary - Teal
  static const Color primary = Color(0xFF21808D);
  static const Color primaryLight = Color(0xFF32B8C6);
  static const Color primaryDark = Color(0xFF1D7480);

  // Secondary - Cream
  static const Color cream = Color(0xFFFCFCF9);
  static const Color creamDark = Color(0xFFFFFFFE);

  // Accent - Orange
  static const Color orange = Color(0xFFE68161);
  static const Color orangeLight = Color(0xFFF4A582);
  static const Color orangeDark = Color(0xFFA8472F);

  // Text
  static const Color textPrimary = Color(0xFF13343B);
  static const Color textSecondary = Color(0xFF626C71);
  static const Color textWhite = Color(0xFFFFFFFF);

  // Background
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Color(0xFFFFFFFF);

  // Status
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);

  // Rank Colors
  static const Color bronze = Color(0xFFCD7F32);
  static const Color silver = Color(0xFFC0C0C0);
  static const Color gold = Color(0xFFFFD700);
  static const Color platinum = Color(0xFFE5E4E2);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient orangeGradient = LinearGradient(
    colors: [orange, orangeLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
