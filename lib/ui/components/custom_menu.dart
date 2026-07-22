import 'package:flutter/material.dart';
import 'package:meowtronome/global.dart';
import 'package:meowtronome/ui/color_helper.dart';
import 'package:meowtronome/ui/components/animated_list.dart';
import 'package:meowtronome/ui/components/custom_divider.dart';

class CustomMenu extends StatefulWidget {
  const CustomMenu({
    super.key,
    required this.options,
    this.initialValue,
    this.width = 128,
    this.maxHeight = 256,
    this.onSelected,
  });

  final List<OptionData> options;
  final String? initialValue;
  final double width;
  final void Function(String value)? onSelected;
  final double maxHeight;

  @override
  State<CustomMenu> createState() => _CustomMenuState();
}

class _CustomMenuState extends State<CustomMenu> {
  final FocusNode _buttonFocusNode = FocusNode();
  final MenuController _menuController = MenuController();
  final ValueNotifier<int> _hoverIndex = ValueNotifier<int>(-1);

  late String _currentValue;
  String? _pendingSelection;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.initialValue ?? widget.options.first.value;
  }

  @override
  void didUpdateWidget(covariant CustomMenu oldWidget) {
    super.didUpdateWidget(oldWidget);

    final optionsChanged =
        widget.options.length != oldWidget.options.length ||
        !_sameOptionValues(widget.options, oldWidget.options);
    if (optionsChanged && _menuController.isOpen) {
      _pendingSelection = null;
      _menuController.close();
    }

    if (widget.initialValue != oldWidget.initialValue &&
        widget.initialValue != null) {
      _currentValue = widget.initialValue!;
    } else if (!widget.options.any((option) => option.value == _currentValue)) {
      _currentValue = widget.initialValue ?? widget.options.first.value;
    }
  }

  bool _sameOptionValues(List<OptionData> a, List<OptionData> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i].value != b[i].value) return false;
    }
    return true;
  }

  @override
  void dispose() {
    _hoverIndex.dispose();
    _buttonFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      controller: _menuController,
      menuChildren: _buildMenuChildren(context),
      animated: true,
      onAnimationStatusChanged: _onAnimationStatusChanged,
      style: _createMenuStyle(context),
      childFocusNode: _buttonFocusNode,
      builder: (context, controller, child) => _buildEntry(
        () {
          if (controller.isOpen) {
            controller.close();
          } else {
            controller.open();
          }
        },
        _labelForValue(_currentValue),
        controller.isOpen,
        context,
      ),
    );
  }

  void _onAnimationStatusChanged(AnimationStatus status) {
    if (status != AnimationStatus.dismissed) {
      return;
    }

    _hoverIndex.value = -1;
    final pending = _pendingSelection;
    _pendingSelection = null;

    // Safe: menu overlay is gone, rebuilding children won't hit Interval asserts.
    if (pending != null) {
      widget.onSelected?.call(pending);
    }
    if (mounted) {
      setState(() {});
    }
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
      minimumSize: WidgetStateProperty.resolveWith(
        (Set<WidgetState> states) => Size(widget.width, 0),
      ),
      maximumSize: WidgetStateProperty.resolveWith(
        (Set<WidgetState> states) => Size(widget.width, widget.maxHeight),
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
      width: widget.width,
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
    final children = <Widget>[];
    for (var i = 0; i < widget.options.length; i++) {
      children.add(_buildMenuChild(i, context));
      if (i != widget.options.length - 1) {
        final dividerIndex = i;
        children.add(
          ValueListenableBuilder<int>(
            valueListenable: _hoverIndex,
            builder: (context, hoverIndex, _) {
              return AnimatedCustomDivider(
                thickness: 1,
                color: resolveInteractiveColor(
                  context,
                  active:
                      hoverIndex == dividerIndex ||
                      hoverIndex - 1 == dividerIndex,
                  inactive: Theme.of(context).colorScheme.primaryFixed,
                ),
              );
            },
          ),
        );
      }
    }

    return [
      SizedBox(
        width: widget.width,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: widget.maxHeight),
          child: ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: .min,
                crossAxisAlignment: .stretch,
                children: children,
              ),
            ),
          ),
        ),
      ),
    ];
  }

  Widget _buildMenuChild(int index, BuildContext context) {
    final option = widget.options[index];

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) {
        if (_hoverIndex.value == index) return;
        _hoverIndex.value = index;
      },
      onExit: (_) {
        if (_hoverIndex.value != index) return;
        _hoverIndex.value = -1;
      },
      child: GestureDetector(
        behavior: .opaque,
        onTap: () => _select(option.value),
        child: SizedBox(
          height: 32,
          child: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: ValueListenableBuilder<int>(
              valueListenable: _hoverIndex,
              builder: (context, hoverIndex, _) {
                final selected = _currentValue == option.value;
                final hovered = hoverIndex == index;
                return AnimatedDefaultTextStyle(
                  duration: kAnimatedListDuration,
                  curve: kAnimatedListCurve,
                  style: bodyTextStyle.copyWith(
                    color: resolveInteractiveColor(
                      context,
                      active: hovered || selected,
                    ),
                    height: 1.5,
                  ),
                  textAlign: .left,
                  child: Text(option.label),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  void _select(String value) {
    // Avoid setState while the menu close animation is running — rebuilding
    // menuChildren mid-flight trips MenuAnchor's Interval opacity curves.
    _currentValue = value;
    _hoverIndex.value = -1;
    _pendingSelection = value;
    _menuController.close();
  }

  String _labelForValue(String value) {
    for (final option in widget.options) {
      if (option.value == value) {
        return option.label;
      }
    }
    return widget.options.first.label;
  }
}
