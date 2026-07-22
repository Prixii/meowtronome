import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meowtronome/core/rhythm_pattern.dart';
import 'package:meowtronome/global.dart';
import 'package:meowtronome/ui/color_helper.dart';
import 'package:meowtronome/ui/components/animated_list.dart';
import 'package:meowtronome/ui/components/custom_divider.dart';
import 'package:meowtronome/ui/components/custom_icon_button.dart';
import 'package:meowtronome/ui/components/inline_editable_text.dart';
import 'package:meowtronome/ui/pattern_selector/components/rhythm_pattern_preview.dart';

class RhythmPatternItem extends StatefulWidget {
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
  State<RhythmPatternItem> createState() => _RhythmPatternItemState();
}

class _RhythmPatternItemState extends State<RhythmPatternItem> {
  bool _previewHovered = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final previewActive = _previewHovered;
    final dividerColor = resolveInteractiveColor(
      context,
      active: previewActive,
      inactive: scheme.primaryFixed,
    );
    final noteColor = resolveInteractiveColor(
      context,
      active: previewActive,
      inactive: scheme.primaryFixed,
    );

    return Padding(
      padding: const EdgeInsets.all(1.0),
      child: Column(
        mainAxisAlignment: .center,
        children: [
          SizedBox(
            height: 48,
            child: RhythmPatternItemTitle(
              isSystemPattern: widget.isSystemPattern,
              pattern: widget.pattern,
              onRename: widget.onRename,
              onDelete: widget.onDelete,
            ),
          ),
          AnimatedCustomDivider(
            indent: 0,
            endIndent: 0,
            color: dividerColor,
          ),
          const SizedBox(height: 8),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            onEnter: (_) {
              if (_previewHovered) return;
              setState(() => _previewHovered = true);
            },
            onExit: (_) {
              if (!_previewHovered) return;
              setState(() => _previewHovered = false);
            },
            child: GestureDetector(
              behavior: .opaque,
              onTap: widget.onSelect,
              child: TweenAnimationBuilder<Color?>(
                duration: kAnimatedListDuration,
                curve: kAnimatedListCurve,
                tween: ColorTween(end: noteColor),
                builder: (context, color, _) {
                  return RhythmPatternPreview(
                    pattern: widget.pattern,
                    color: color ?? noteColor,
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 8),
          AnimatedCustomDivider(color: dividerColor),
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
