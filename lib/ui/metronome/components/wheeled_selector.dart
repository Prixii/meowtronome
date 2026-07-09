import 'dart:math';

import 'package:flutter/material.dart';
import 'package:meowtronome/ui/layout_helper.dart';

class SelectOption {
  final String label;
  final String value;

  SelectOption({required this.label, required this.value});
}

class WheeledSelector extends StatefulWidget {
  const WheeledSelector({
    super.key,
    required this.options,
    required this.value,
    required this.onChange,
  });

  final List<SelectOption> options;
  final String value;
  final void Function(String value) onChange;

  @override
  State<WheeledSelector> createState() => _WheeledSelectorState();
}

class _WheeledSelectorState extends State<WheeledSelector> {
  late final ScrollController _controller;
  var _isSnapping = false;
  @override
  initState() {
    super.initState();
    _controller = ScrollController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final preferredItemHeight = LayoutHelper.getPickerItemHeight(context) + 3;

    return LayoutBuilder(
      builder: (_, constraints) => Stack(
        alignment: .center,
        clipBehavior: .hardEdge,
        children: [
          NotificationListener<ScrollNotification>(
            onNotification: (notification) =>
                onScrollNotification(notification, context),
            child: SingleChildScrollView(
              controller: _controller,
              scrollDirection: Axis.vertical,
              physics: const ClampingScrollPhysics(),
              child: Column(
                children: [
                  SizedBox(
                    height:
                        max(0, constraints.maxHeight - preferredItemHeight) / 2,
                  ),
                  for (final option in widget.options)
                    GestureDetector(
                      child: SizedBox(
                        height: preferredItemHeight,
                        child: Text(option.label),
                      ),
                      onTap: () => debugPrint('click ${option.value}'),
                    ),
                  SizedBox(
                    height:
                        max(0, constraints.maxHeight - preferredItemHeight) / 2,
                  ),
                ],
              ),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: Center(
                child: SizedBox(
                  height: preferredItemHeight,
                  width: double.infinity,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      border: .symmetric(
                        horizontal: BorderSide(
                          color: Theme.of(context).colorScheme.primaryFixed,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool onScrollNotification(
    ScrollNotification notification,
    BuildContext context,
  ) {
    if (notification is! ScrollEndNotification || _isSnapping) {
      return false;
    }

    final itemHeight = LayoutHelper.getPickerItemHeight(context) + 3;
    final currentOffset = _controller.hasClients
        ? _controller.offset
        : notification.metrics.pixels;
    final nearestItemIndex = findNearestItemIndex(
      currentOffset,
      itemHeight,
    ).clamp(0, widget.options.length - 1);
    final target = nearestItemIndex * itemHeight;

    if ((currentOffset - target).abs() < 0.5) {
      return false;
    }

    _isSnapping = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_controller.hasClients) {
        _isSnapping = false;
        return;
      }
      _controller
          .animateTo(
            target,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
          )
          .whenComplete(() {
            if (mounted) {
              _isSnapping = false;
            }
          });
    });

    return false;
  }

  int findNearestItemIndex(double currentY, double itemHeight) {
    return (currentY / itemHeight).round();
  }
}
