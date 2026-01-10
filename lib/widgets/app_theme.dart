import 'package:flutter/material.dart';

class AppTheme {
  // Dark Theme Colors
  static const Color darkBackground = Color(0xFF1A1D23);
  static const Color darkSurface = Color(0xFF252930);
  static const Color darkSurfaceLight = Color(0xFF2F343D);
  
  // Light Theme Colors
  static const Color lightBackground = Color(0xFFF5F7FA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceLight = Color(0xFFF0F2F5);
  
  // Primary Colors (Same for both themes)
  static const Color primary = Color(0xFF4A90E2);
  static const Color primaryDark = Color(0xFF357ABD);
  
  // Status Colors (Same for both themes)
  static const Color success = Color(0xFF27AE60);
  static const Color warning = Color(0xFFE67E22);
  static const Color error = Color(0xFFE74C3C);
  static const Color purple = Color(0xFF9B59B6);
  static const Color info = Color(0xFF3498DB);
  
  // Dark Text Colors
  static const Color darkTextPrimary = Color(0xFFF5F5F5);
  static const Color darkTextSecondary = Color(0xFFB8BCC4);
  static const Color darkTextTertiary = Color(0xFF7A7E87);
  
  // Light Text Colors
  static const Color lightTextPrimary = Color(0xFF1A1D23);
  static const Color lightTextSecondary = Color(0xFF5A5E67);
  static const Color lightTextTertiary = Color(0xFF8A8E97);
  
  // Dark Border Colors
  static const Color darkBorderColor = Color(0xFF3A3F4A);
  static const Color darkBorderLight = Color(0xFF4A4F5A);
  
  // Light Border Colors
  static const Color lightBorderColor = Color(0xFFE0E3E8);
  static const Color lightBorderLight = Color(0xFFD0D3D8);
  
  // Gradient Definitions
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF4A90E2), Color(0xFF9B59B6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF27AE60), Color(0xFF229954)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient warningGradient = LinearGradient(
    colors: [Color(0xFFE67E22), Color(0xFFD35400)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient errorGradient = LinearGradient(
    colors: [Color(0xFFE74C3C), Color(0xFFC0392B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Helper methods to get theme-specific colors
  static Color background(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkBackground
        : lightBackground;
  }

  static Color surface(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkSurface
        : lightSurface;
  }

  static Color surfaceLight(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkSurfaceLight
        : lightSurfaceLight;
  }

  static Color textPrimary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkTextPrimary
        : lightTextPrimary;
  }

  static Color textSecondary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkTextSecondary
        : lightTextSecondary;
  }

  static Color textTertiary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkTextTertiary
        : lightTextTertiary;
  }

  static Color borderColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkBorderColor
        : lightBorderColor;
  }

  static Color borderLight(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkBorderLight
        : lightBorderLight;
  }

  // Theme Data
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: primary,
    scaffoldBackgroundColor: darkBackground,
    colorScheme: const ColorScheme.dark(
      primary: primary,
      secondary: purple,
      surface: darkSurface,
      error: error,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: darkSurface,
      elevation: 0,
      iconTheme: IconThemeData(color: darkTextPrimary),
    ),
    cardTheme: CardThemeData(
      color: darkSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: darkBorderColor),
      ),
    ),
  );

  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: primary,
    scaffoldBackgroundColor: lightBackground,
    colorScheme: const ColorScheme.light(
      primary: primary,
      secondary: purple,
      surface: lightSurface,
      error: error,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: lightSurface,
      elevation: 0,
      iconTheme: IconThemeData(color: lightTextPrimary),
    ),
    cardTheme: CardThemeData(
      color: lightSurface,
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: lightBorderColor),
      ),
    ),
  );
}
