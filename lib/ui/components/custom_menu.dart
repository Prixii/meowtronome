import 'package:flutter/material.dart';
import 'package:meowtronome/global.dart';
import 'package:meowtronome/ui/components/animated_list.dart';
import 'package:meowtronome/ui/components/custom_divider.dart';
import 'package:meowtronome/ui/components/selectable_button.dart';

class CustomMenu extends StatefulWidget {
  const CustomMenu({
    super.key,
    required this.options,
    this.initialValue,
    this.width = 128,
    this.onSelected,
  });

  final List<OptionData> options;
  final String? initialValue;
  final double width;
  final void Function(String value)? onSelected;

  @override
  State<CustomMenu> createState() => _CustomMenuState();
}

class _CustomMenuState extends State<CustomMenu> {
  final FocusNode _buttonFocusNode = FocusNode();
  AnimationStatus _animationStatus = .dismissed;
  late String _currentValue;
  late String _currentHoverValue;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.initialValue ?? widget.options.first.value;
    _currentHoverValue = '';
  }

  @override
  void dispose() {
    _buttonFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      menuChildren: _buildMenuChildren(context),
      animated: true,
      onAnimationStatusChanged: (AnimationStatus status) {
        _animationStatus = status;
        if (status == AnimationStatus.dismissed &&
            _currentHoverValue.isNotEmpty) {
          setState(() => _currentHoverValue = '');
        }
      },
      style: _createMenuStyle(context),
      childFocusNode: _buttonFocusNode,
      builder: (context, controller, child) => _buildEntry(
        () {
          if (_animationStatus.isForwardOrCompleted) {
            controller.close();
          } else {
            controller.open();
          }
        },
        widget.initialValue ?? widget.options.first.label,
        _animationStatus.isForwardOrCompleted,
        context,
      ),
    );
  }

  MenuStyle _createMenuStyle(BuildContext context) {
    return MenuStyle(
      backgroundColor: WidgetStateProperty.resolveWith(
        (Set<WidgetState> states) =>
            Theme.of(context).colorScheme.primaryContainer,
      ),
      shape: WidgetStateProperty.resolveWith(
        (Set<WidgetState> states) => RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: BorderSide(
            width: 1,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
      shadowColor: WidgetStateProperty.resolveWith(
        (Set<WidgetState> states) => Colors.transparent,
      ),
      padding: WidgetStateProperty.resolveWith(
        (Set<WidgetState> states) => EdgeInsets.zero,
      ),
    );
  }

  Widget _buildEntry(
    void Function() onTap,
    String? title,
    bool opened,
    BuildContext context,
  ) {
    return Container(
      height: 32,
      width: 128,
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.primary,
          width: 1,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Row(
          children: [
            Text(
              title ?? '',
              style: bodyTextStyle.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            Expanded(child: Container()),
            Icon(
              opened ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_left,
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildMenuChildren(BuildContext context) {
    List<Widget> children = [];
    for (int i = 0; i < widget.options.length; i++) {
      children.add(_buildMenuChild(i, context));
      if (i != widget.options.length - 1) {
        children.add(
          AnimatedCustomDivider(
            thickness: 1,
            color:
                ((_currentHoverIndex() == i) || (_currentHoverIndex() - 1 == i))
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.primaryFixed,
          ),
        );
      }
    }
    return children;
  }

  Widget _buildMenuChild(int index, BuildContext context) {
    final option = widget.options[index];
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) {
        if (_currentHoverValue == option.value) return;
        setState(() => _currentHoverValue = option.value);
      },
      onExit: (_) {
        // Only clear if we haven't already entered another item.
        if (_currentHoverValue != option.value) return;
        setState(() => _currentHoverValue = '');
      },
      child: GestureDetector(
        behavior: .opaque,
        onTap: () {
          setState(() => _currentValue = option.value);
          widget.onSelected?.call(option.value);
        },
        child: SizedBox(
          width: widget.width,
          height: 32,
          child: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: AnimatedDefaultTextStyle(
              duration: kAnimatedListDuration,
              curve: kAnimatedListCurve,
              style: bodyTextStyle.copyWith(
                color: (_currentHoverIndex() == index)
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.secondary,
                height: 1.5,
              ),
              textAlign: .left,
              child: Text(option.label),
            ),
          ),
        ),
      ),
    );
  }

  int _currentHoverIndex() {
    for (int i = 0; i < widget.options.length; i++) {
      if (widget.options[i].value == _currentHoverValue) {
        return i;
      }
    }
    return -1;
  }
}
