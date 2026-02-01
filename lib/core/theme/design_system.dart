import 'package:flutter/material.dart';

class AppColors {
  // Primary Palette
  static const Color primary = Color(0xFF2E7D32);
  static const Color primaryLight = Color(0xFF64FF64);
  static const Color accent = Color(0xFF00C853);
  static const Color secondary = Color(
    0xFFFFA000,
  ); // Added secondary color for decoColors

  // Backgrounds
  static const Color background = Color(0xFFF8FAF8); // Changed from F8F9FA
  static const Color backgroundAccent = Color(
    0xFFE8F5E9,
  ); // Added for better gradient
  static const Color surface = Colors.white;

  // Glass Colors (Increased opacity for mobile visibility)
  static Color glassWhite = Colors.white.withOpacity(
    0.85,
  ); // Up from 0.7, renamed from glassBackground
  static Color glassPrimary = primary.withOpacity(0.15); // Added glassPrimary
  static Color glassBorder = Colors.white.withOpacity(0.4); // Up from 0.3

  // Gradients
  static const LinearGradient mainGradient = LinearGradient(
    colors: [
      Color(0xFFF1F8E9),
      Color(0xFFE8F5E9),
    ], // Darkened second color for more pronounced gradient
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient cardGradient = LinearGradient(
    colors: [Colors.white, const Color(0xFFF9FFF9)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Text
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF757575);
}

class AppTheme {
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        background: AppColors.background,
      ),
      fontFamily: 'Roboto',
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class ShadowStyles {
  static List<BoxShadow> get soft => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      offset: const Offset(0, 4),
      blurRadius: 10,
    ),
  ];

  static List<BoxShadow> get premium => [
    BoxShadow(
      color: AppColors.primary.withValues(alpha: 0.1),
      offset: const Offset(0, 10),
      blurRadius: 20,
    ),
  ];
}
