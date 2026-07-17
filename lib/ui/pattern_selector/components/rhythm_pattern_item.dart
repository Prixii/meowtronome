import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meowtronome/core/rhythm_pattern.dart';
import 'package:meowtronome/global.dart';
import 'package:meowtronome/ui/components/custom_divider.dart';
import 'package:meowtronome/ui/components/custom_icon_button.dart';
import 'package:meowtronome/ui/components/inline_editable_text.dart';
import 'package:meowtronome/ui/pattern_selector/components/rhythm_pattern_preview.dart';

class RhythmPatternItem extends StatelessWidget {
  const RhythmPatternItem({
    super.key,
    required this.pattern,
    required this.uuid,
    required this.onSelect,
    required this.onDelete,
    required this.onRename,
    this.isSystemPattern = false,
  });
  final RhythmPattern pattern;
  final String uuid;
  final void Function() onSelect;
  final void Function() onDelete;
  final void Function(String newName) onRename;
  final bool isSystemPattern;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(1.0),

      child: Column(
        mainAxisAlignment: .center,
        children: [
          SizedBox(
            height: 48,
            child: RhythmPatternItemTitle(
              isSystemPattern: isSystemPattern,
              pattern: pattern,
              onRename: onRename,
              onDelete: onDelete,
            ),
          ),
          CustomDivider(
            indent: 0,
            endIndent: 0,
            color: Theme.of(context).colorScheme.primaryFixed,
          ),
          const SizedBox(height: 8),
          GestureDetector(
            behavior: .opaque,
            onTap: () => onSelect.call(),
            child: RhythmPatternPreview(pattern: pattern),
          ),
          const SizedBox(height: 8),
          const CustomDivider(),
        ],
      ),
    );
  }
}

class RhythmPatternItemTitle extends StatelessWidget {
  const RhythmPatternItemTitle({
    super.key,
    required this.isSystemPattern,
    required this.pattern,
    required this.onRename,
    required this.onDelete,
  });

  final bool isSystemPattern;
  final RhythmPattern pattern;
  final void Function(String newName) onRename;
  final void Function() onDelete;

  @override
  Widget build(BuildContext context) {
    final textStyle = subtitleTextStyle.copyWith(
      color: Theme.of(context).colorScheme.primary,
    );

    return Row(
      children: [
        SizedBox(
          width: 48,
          child: isSystemPattern
              ? null
              : CustomIconButton(icon: Icons.edit, onTap: () => {}),
        ),
        isSystemPattern
            ? Container()
            : CustomDivider(
                vertical: true,
                color: Theme.of(context).colorScheme.primaryFixed,
              ),
        Expanded(
          child: InlineEditableText(
            value: pattern.name,
            onSubmit: onRename,
            style: textStyle,
            enabled: !isSystemPattern,
            inputFormatters: [LengthLimitingTextInputFormatter(8)],
          ),
        ),
        isSystemPattern
            ? Container()
            : CustomDivider(
                vertical: true,
                color: Theme.of(context).colorScheme.primaryFixed,
              ),
        SizedBox(
          width: 48,
          child: isSystemPattern
              ? null
              : CustomIconButton(
                  icon: Icons.delete,
                  onTap: () => onDelete.call(),
                ),
        ),
      ],
    );
  }
}
