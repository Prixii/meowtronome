import 'package:flutter/material.dart';

class CustomDivider extends StatelessWidget {
  const CustomDivider({
    super.key,
    this.vertical = false,
    this.thickness = 1,
    this.indent = 0,
    this.endIndent = 0,
    this.color,
  });

  final bool vertical;
  final double thickness;
  final double indent;
  final double endIndent;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return vertical
        ? VerticalDivider(
            color: color ?? Theme.of(context).colorScheme.primary,
            thickness: thickness,
            indent: indent,
            width: 1,
            endIndent: endIndent,
          )
        : Divider(
            color: color ?? Theme.of(context).colorScheme.primary,
            thickness: thickness,
            indent: indent,
            height: 1,
            endIndent: endIndent,
          );
  }
}
