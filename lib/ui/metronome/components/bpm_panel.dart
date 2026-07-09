import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meowtronome/ui/components/custom_divider.dart';
import 'package:meowtronome/ui/components/custom_icon_button.dart';
import 'package:meowtronome/ui/layout_helper.dart';
import 'package:meowtronome/ui/metronome/provider/metronome_notifier.dart';

class BpmPanel extends StatefulWidget {
  const BpmPanel({super.key, required this.notifier});
  final MetronomeNotifier notifier;

  @override
  State<BpmPanel> createState() => _BpmPanelState();
}

class _BpmPanelState extends State<BpmPanel> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.notifier.bpm.toString());
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus && _isEditing) {
      _commitBpm();
      setState(() => _isEditing = false);
    }
  }

  void _commitBpm() {
    final value = int.tryParse(_controller.text);
    if (value != null && value > 0) {
      widget.notifier.setBpm(value);
    }
    _controller.text = widget.notifier.bpm.toString();
  }

  void _startEditing() {
    setState(() => _isEditing = true);
    _controller.text = widget.notifier.bpm.toString();
    _controller.selection = TextSelection(
      baseOffset: 0,
      extentOffset: _controller.text.length,
    );
    _focusNode.requestFocus();
  }

  TextStyle _textStyle(BuildContext context) => TextStyle(
    fontSize: LayoutHelper.getBpmTextSize(context),
    fontWeight: FontWeight.bold,
    color: Theme.of(context).colorScheme.primary,
    height: 1,
  );

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notifier = widget.notifier;

    return Container(
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.secondary),
      height: 128,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 64,
            child: CustomIconButton(
              icon: Icons.remove,
              size: 24,
              onTap: () => notifier.setBpm(notifier.bpm - 1),
            ),
          ),
          CustomDivider(
            vertical: true,
            color: Theme.of(context).colorScheme.primaryFixed,
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.only(bottom: 8),
              child: _isEditing
                  ? TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      textAlign: TextAlign.center,
                      style: _textStyle(context),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      onSubmitted: (_) {
                        _commitBpm();
                        setState(() => _isEditing = false);
                      },
                    )
                  : GestureDetector(
                      onTap: _startEditing,
                      behavior: HitTestBehavior.opaque,
                      child: Text(
                        notifier.bpm.toString(),
                        style: _textStyle(context),
                        textAlign: TextAlign.center,
                      ),
                    ),
            ),
          ),
          CustomDivider(
            vertical: true,
            color: Theme.of(context).colorScheme.primaryFixed,
          ),
          SizedBox(
            width: 64,
            child: CustomIconButton(
              icon: Icons.add,
              size: 24,
              onTap: () => notifier.setBpm(notifier.bpm + 1),
            ),
          ),
        ],
      ),
    );
  }
}
