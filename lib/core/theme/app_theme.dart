import 'package:flutter/material.dart';

class AppTheme {
  static AppTheme of(BuildContext context) => AppTheme();

  Color get secondaryBackground => Colors.grey[50]!;
  Color get accent4 => Colors.grey[100]!;
  Color get primaryBackground => Colors.white;
  Color get primaryText => Colors.black;
  Color get alternate => Colors.grey[300]!;
  Color get primaryColor => const Color(0xFF63DA5C);

  TextStyle get displayLarge => const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black);
  TextStyle get displaySmall => const TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: Colors.black);
  TextStyle get labelMedium => TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.grey[600]);
  TextStyle get titleSmall => const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black);
}