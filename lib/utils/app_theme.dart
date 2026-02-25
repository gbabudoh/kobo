import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class KobboTheme {
  // Brand Colors
  static const Color primarySpringGreen = Color(0xFF2E8B57); // SeaGreen as base, or nicer Emerald
  static const Color primaryEmerald = Color(0xFF10B981); // Modern Emerald
  static const Color primaryDark = Color(0xFF065F46);
  static const Color backgroundLight = Color(0xFFF9FAFB); // Cool Gray 50
  static const Color surfaceWhite = Colors.white;
  static const Color textDark = Color(0xFF1F2937); // Cool Gray 800
  static const Color textGray = Color(0xFF6B7280);
  
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primaryEmerald,
      scaffoldBackgroundColor: backgroundLight,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryEmerald,
        primary: primaryEmerald,
        secondary: const Color(0xFF34D399),
        surface: surfaceWhite,
      ),
      
      // Typography
      textTheme: TextTheme(
        displayLarge: GoogleFonts.outfit(
          fontSize: 32, fontWeight: FontWeight.bold, color: textDark, letterSpacing: -0.5),
        displayMedium: GoogleFonts.outfit(
          fontSize: 28, fontWeight: FontWeight.bold, color: textDark, letterSpacing: -0.5),
        displaySmall: GoogleFonts.outfit(
          fontSize: 24, fontWeight: FontWeight.w600, color: textDark),
        headlineMedium: GoogleFonts.outfit(
          fontSize: 20, fontWeight: FontWeight.w600, color: textDark),
        titleLarge: GoogleFonts.inter(
          fontSize: 18, fontWeight: FontWeight.w600, color: textDark),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16, color: textDark),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14, color: textGray),
        labelLarge: GoogleFonts.inter(
          fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
      ),
      
      // Card Theme
      cardTheme: CardThemeData(
        color: surfaceWhite,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey.withValues(alpha: 0.1)),
        ),
        margin: EdgeInsets.zero,
      ),
      
      // AppBar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: textDark),
        titleTextStyle: TextStyle(color: textDark, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      
      // Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryEmerald,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
      ),
      
      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryEmerald, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}
