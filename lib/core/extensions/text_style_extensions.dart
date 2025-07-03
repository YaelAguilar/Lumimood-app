import 'package:flutter/material.dart';

extension TextStyleExtension on TextStyle {
  TextStyle override({
    String? fontFamily,
    Color? color,
    double? letterSpacing,
  }) {
    return copyWith(
      fontFamily: fontFamily,
      color: color,
      letterSpacing: letterSpacing,
    );
  }
}