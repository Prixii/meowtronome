import 'package:flutter/material.dart';
import 'package:meowtronome/core/rhythm_pattern.dart';
import 'package:meowtronome/global.dart';
import 'package:meowtronome/ui/components/custom_divider.dart';
import 'package:meowtronome/ui/pattern_selector/components/rhythm_pattern_preview.dart';

class RhythmPatternItem extends StatelessWidget {
  const RhythmPatternItem({
    super.key,
    required this.pattern,
    required this.uuid,
    this.onSelect,
  });
  final RhythmPattern pattern;
  final String uuid;
  final void Function()? onSelect;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: .opaque,
      onTap: () => onSelect?.call(),
      child: Column(
        mainAxisAlignment: .center,
        children: [
          const SizedBox(height: 8),
          Text(
            pattern.name,
            style: subtitleTextStyle.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          CustomDivider(
            indent: 32,
            endIndent: 32,
            color: Theme.of(context).colorScheme.primaryFixedDim,
          ),
          const SizedBox(height: 8),
          RhythmPatternPreview(pattern: pattern),
          const SizedBox(height: 8),
          const CustomDivider(),
        ],
      ),
    );
  }
}
