import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final ButtonOptions options;
  final Widget? icon;

  const CustomButton({
    super.key,
    this.onPressed,
    required this.text,
    required this.options,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final hasElevation = options.elevation > 0;

    return Container(
      width: options.width,
      height: options.height,
      decoration: BoxDecoration(
        color: options.color,
        borderRadius: options.borderRadius,
        border: Border.all(
          color: options.borderSide.color,
          width: options.borderSide.width,
        ),
        boxShadow: hasElevation
            ? [
                BoxShadow(
                  color: Colors.black.withAlpha(51),
                  blurRadius: options.elevation,
                  offset: Offset(0, options.elevation / 2),
                )
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: options.borderRadius,
          child: Container(
            padding: options.padding,
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  icon!,
                  const SizedBox(width: 12),
                ],
                Text(text, style: options.textStyle),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ButtonOptions {
  final double? width, height;
  final double elevation;
  final EdgeInsetsGeometry padding;
  final Color color;
  final TextStyle textStyle;
  final BorderSide borderSide;
  final BorderRadius borderRadius;

  ButtonOptions({
    this.width,
    this.height,
    this.padding = EdgeInsets.zero,
    required this.color,
    required this.textStyle,
    this.elevation = 0,
    this.borderSide = BorderSide.none,
    this.borderRadius = BorderRadius.zero,
  });
}