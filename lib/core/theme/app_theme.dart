import 'package:flutter/material.dart';

class AppTheme {
  final BuildContext context;
  AppTheme(this.context);

  static AppTheme of(BuildContext context) => AppTheme(context);

  Color get secondaryBackground => Theme.of(context).scaffoldBackgroundColor;
  Color get accent4 => Colors.grey[100]!;
  Color get primaryBackground => Colors.white;
  Color get primaryText => const Color(0xFF101518);
  Color get alternate => Colors.grey[300]!;
  Color get primaryColor => Theme.of(context).primaryColor;


  TextStyle get displayLarge => Theme.of(context).textTheme.displayLarge!;
  TextStyle get displaySmall => Theme.of(context).textTheme.displaySmall!;
  TextStyle get headlineMedium => Theme.of(context).textTheme.headlineMedium!;
  TextStyle get titleSmall => Theme.of(context).textTheme.titleSmall!;
  TextStyle get bodyMedium => Theme.of(context).textTheme.bodyMedium!;
  TextStyle get labelMedium => Theme.of(context).textTheme.labelMedium!;
}