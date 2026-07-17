import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Tap-to-edit text that commits on unfocus, submit, tap outside, or keyboard dismiss.
class InlineEditableText extends StatefulWidget {
  const InlineEditableText({
    super.key,
    required this.value,
    required this.onSubmit,
    required this.style,
    this.textAlign = TextAlign.center,
    this.keyboardType,
    this.inputFormatters,
    this.enabled = true,
  });

  final String value;
  final ValueChanged<String> onSubmit;
  final TextStyle style;
  final TextAlign textAlign;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final bool enabled;

  @override
  State<InlineEditableText> createState() => _InlineEditableTextState();
}

class _InlineEditableTextState extends State<InlineEditableText>
    with WidgetsBindingObserver {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  bool _isEditing = false;
  bool _keyboardVisible = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
    WidgetsBinding.instance.addObserver(this);
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus && _isEditing) {
      final text = _controller.text;
      setState(() => _isEditing = false);
      widget.onSubmit(text);
    }
  }

  @override
  void didChangeMetrics() {
    if (!mounted || !_isEditing) return;
    final visible = View.of(context).viewInsets.bottom > 0;
    if (_keyboardVisible && !visible && _focusNode.hasFocus) {
      _focusNode.unfocus();
    }
    _keyboardVisible = visible;
  }

  void _startEditing() {
    if (!widget.enabled) return;
    setState(() => _isEditing = true);
    _controller.text = widget.value;
    _controller.selection = TextSelection(
      baseOffset: 0,
      extentOffset: _controller.text.length,
    );
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (!_isEditing && widget.enabled) ? _startEditing : null,
      behavior: HitTestBehavior.opaque,
      child: Center(
        child: _isEditing
            ? TextField(
                controller: _controller,
                focusNode: _focusNode,
                keyboardType: widget.keyboardType,
                inputFormatters: widget.inputFormatters,
                textAlign: widget.textAlign,
                style: widget.style,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                onTapOutside: (_) => _focusNode.unfocus(),
                onSubmitted: (_) => _focusNode.unfocus(),
              )
            : Text(
                widget.value,
                style: widget.style,
                textAlign: widget.textAlign,
              ),
      ),
    );
  }
}

/// Unfocuses the current focus when a pointer lands outside its render box.
class UnfocusOnPointerOutside extends StatelessWidget {
  const UnfocusOnPointerOutside({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (event) {
        final focus = FocusManager.instance.primaryFocus;
        if (focus == null || focus.context == null) return;
        final renderObject = focus.context!.findRenderObject();
        if (renderObject is! RenderBox) return;
        final local = renderObject.globalToLocal(event.position);
        if (!renderObject.paintBounds.contains(local)) {
          focus.unfocus();
        }
      },
      child: child,
    );
  }
}
