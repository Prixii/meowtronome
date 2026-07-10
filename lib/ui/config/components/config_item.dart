import 'package:flutter/material.dart';
import 'package:meowtronome/global.dart';

class ConfigItem extends StatelessWidget {
  const ConfigItem({
    super.key,
    required this.title,
    this.description,
    this.trailing,
    this.padding = const EdgeInsets.all(16),
  });

  final String title;
  final String? description;
  final Widget? trailing;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,

      child: Column(
        crossAxisAlignment: .start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: subtitleTextStyle.copyWith(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ),
              ?trailing,
            ],
          ),
          if (description != null)
            Text(
              description!,
              style: bodyTextStyle.copyWith(
                color: Theme.of(context).colorScheme.primaryFixedDim,
              ),
            ),
        ],
      ),
    );
  }
}
