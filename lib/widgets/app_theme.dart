import 'package:flutter/material.dart';


class AppTheme {
  // Background Colors 
  static const Color background = Color(0xFF1A1D23);
  static const Color surface = Color(0xFF252930);
  static const Color surfaceLight = Color(0xFF2F343D);
  
  // Primary Colors 
  static const Color primary = Color(0xFF4A90E2);       
  static const Color primaryDark = Color(0xFF357ABD);
  
  // Status Colors 
  static const Color success = Color(0xFF27AE60);        
  static const Color warning = Color(0xFFE67E22);        
  static const Color error = Color(0xFFE74C3C);          
  static const Color purple = Color(0xFF9B59B6);         
  static const Color info = Color(0xFF3498DB);           
  
  // Text Colors 
  static const Color textPrimary = Color(0xFFF5F5F5);
  static const Color textSecondary = Color(0xFFB8BCC4);
  static const Color textTertiary = Color(0xFF7A7E87);
  
  // Border Colors 
  static const Color borderColor = Color(0xFF3A3F4A);
  static const Color borderLight = Color(0xFF4A4F5A);
  
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
}