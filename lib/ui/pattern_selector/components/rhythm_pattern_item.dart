import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meowtronome/core/rhythm_pattern.dart';
import 'package:meowtronome/global.dart';
import 'package:meowtronome/ui/components/custom_divider.dart';
import 'package:meowtronome/ui/components/custom_icon_button.dart';
import 'package:meowtronome/ui/pattern_selector/components/rhythm_pattern_preview.dart';

class RhythmPatternItem extends StatelessWidget {
  const RhythmPatternItem({
    super.key,
    required this.pattern,
    required this.uuid,
    this.onSelect,
    this.onRename,
    this.isSystemPattern = false,
  });
  final RhythmPattern pattern;
  final String uuid;
  final void Function()? onSelect;
  final void Function(String newName)? onRename;
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
            onTap: () => onSelect?.call(),
            child: RhythmPatternPreview(pattern: pattern),
          ),
          const SizedBox(height: 8),
          const CustomDivider(),
        ],
      ),
    );
  }
}

class RhythmPatternItemTitle extends StatefulWidget {
  const RhythmPatternItemTitle({
    super.key,
    required this.isSystemPattern,
    required this.pattern,
    this.onRename,
  });

  final bool isSystemPattern;
  final RhythmPattern pattern;
  final void Function(String newName)? onRename;

  @override
  State<RhythmPatternItemTitle> createState() => _RhythmPatternItemTitleState();
}

class _RhythmPatternItemTitleState extends State<RhythmPatternItemTitle> {
  late final TextEditingController _controller;
  var isEditing = false;
  late final FocusNode _focusNode;

  @override
  initState() {
    super.initState();
    _controller = TextEditingController(text: widget.pattern.name);
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus && isEditing) {
        setState(() => isEditing = false);
        widget.onRename?.call(_controller.text);
      }
    });
  }

  @override
  dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 48,
          child: widget.isSystemPattern
              ? null
              : CustomIconButton(icon: Icons.edit, onTap: () => {}),
        ),
        widget.isSystemPattern
            ? Container()
            : CustomDivider(
                vertical: true,
                color: Theme.of(context).colorScheme.primaryFixed,
              ),
        Expanded(
          child: isEditing
              ? TextField(
                  controller: _controller,
                  autofocus: false,
                  textAlign: .center,
                  style: subtitleTextStyle.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  inputFormatters: [LengthLimitingTextInputFormatter(8)],
                  focusNode: _focusNode,
                  onSubmitted: (value) {
                    setState(() => isEditing = false);
                    widget.onRename?.call(value);
                  },
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                )
              : GestureDetector(
                  behavior: .opaque,
                  onTap: () {
                    setState(() => isEditing = true);
                    _controller.text = widget.pattern.name;
                    _controller.selection = TextSelection(
                      baseOffset: 0,
                      extentOffset: _controller.text.length,
                    );
                    _focusNode.requestFocus();
                  },
                  child: Text(
                    widget.pattern.name,
                    style: subtitleTextStyle.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    textAlign: .center,
                  ),
                ),
        ),
        widget.isSystemPattern
            ? Container()
            : CustomDivider(
                vertical: true,
                color: Theme.of(context).colorScheme.primaryFixed,
              ),
        SizedBox(
          width: 48,
          child: widget.isSystemPattern
              ? null
              : CustomIconButton(icon: Icons.delete, onTap: () => {}),
        ),
      ],
    );
  }
}
