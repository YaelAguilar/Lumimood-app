import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF63DA5C);
  static const Color primaryText = Color(0xFF101518);
  static const Color scaffoldBackground = Color(0xFFF5FBFB);
  static const Color alternate = Color(0xFFDFEDEC);

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: scaffoldBackground,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      primary: primaryColor,
      secondary: Colors.grey[300]!,
      surface: Colors.white,
      onSurface: primaryText,
      brightness: Brightness.light,
    ),
    textTheme: TextTheme(
      displayLarge: GoogleFonts.notoSans(fontSize: 32, fontWeight: FontWeight.bold, color: primaryText),
      displaySmall: GoogleFonts.interTight(fontSize: 24, fontWeight: FontWeight.w600, color: primaryText),
      headlineMedium: GoogleFonts.readexPro(fontSize: 28, fontWeight: FontWeight.w600, color: primaryText),
      titleSmall: GoogleFonts.interTight(fontSize: 18, fontWeight: FontWeight.w600, color: primaryText),
      bodyMedium: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: primaryText),
      labelMedium: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.normal, color: primaryText),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: scaffoldBackground,
      hintStyle: GoogleFonts.inter(color: Colors.grey[600], fontSize: 14),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: alternate, width: 1)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: alternate, width: 1)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF06D5CD), width: 2)),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFC4454D), width: 1)),
      focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFC4454D), width: 2)),
    ),
  );
}
