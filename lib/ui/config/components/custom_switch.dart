import 'package:flutter/material.dart';

class CustomSwitch extends StatelessWidget {
  const CustomSwitch({
    super.key,
    required this.title,
    this.description = '',
    required this.value,
    required this.onChanged,
    this.icon,
  });

  final String title;
  final String description;
  final bool value;
  final void Function(bool) onChanged;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    // TODO:
    return Container();
  }
}
