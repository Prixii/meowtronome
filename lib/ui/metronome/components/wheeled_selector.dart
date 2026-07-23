import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:meowtronome/gen/fonts.gen.dart';
import 'package:meowtronome/global.dart';
import 'package:meowtronome/ui/layout_helper.dart';

class WheeledSelector extends StatefulWidget {
  const WheeledSelector({
    super.key,
    required this.options,
    required this.value,
    required this.onChange,
    this.showCount = 7,
  });

  final List<OptionData> options;
  final String value;
  final int showCount;
  final void Function(String value) onChange;

  @override
  State<WheeledSelector> createState() => _WheeledSelectorState();
}

class _WheeledSelectorState extends State<WheeledSelector> {
  late final ScrollController _controller;
  var _isSnapping = false;

  var _initialized = false; // HACK 初始化的时候也会触发onChange，所以第一次尝试播放声音应当屏蔽

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();

    final index = widget.options.indexWhere(
      (option) => option.value == widget.value,
    );
    if (index < 0) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_controller.hasClients) return;
      _controller.jumpTo(index * LayoutHelper.getPickerItemHeight(context));
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final preferredItemHeight = LayoutHelper.getPickerItemHeight(context);

    return SizedBox(
      height: preferredItemHeight * widget.showCount,
      child: LayoutBuilder(
        builder: (_, constraints) => Stack(
          alignment: .center,
          clipBehavior: .hardEdge,
          children: [
            NotificationListener<ScrollNotification>(
              onNotification: (notification) =>
                  onScrollNotification(notification, context),
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  final scrollOffset = _controller.hasClients
                      ? _controller.offset
                      : 0.0;
                  final viewportCenter =
                      scrollOffset + constraints.maxHeight / 2;
                  final topPadding =
                      max(0, constraints.maxHeight - preferredItemHeight) / 2;

                  return ScrollConfiguration(
                    behavior: const _WheeledSelectorScrollBehavior().copyWith(
                      scrollbars: false,
                    ),
                    child: SingleChildScrollView(
                      controller: _controller,
                      scrollDirection: Axis.vertical,

                      physics: const ClampingScrollPhysics(),
                      child: SizedBox(
                        width: constraints.maxWidth,
                        child: Column(
                          crossAxisAlignment: .stretch,
                          children: [
                            SizedBox(height: topPadding),
                            for (var i = 0; i < widget.options.length; i++)
                              _buildWheelItem(
                                context,
                                option: widget.options[i],
                                itemHeight: preferredItemHeight,
                                distanceFromCenter:
                                    (topPadding +
                                            i * preferredItemHeight +
                                            preferredItemHeight / 2 -
                                            viewportCenter)
                                        .abs(),
                                index: i,
                              ),
                            SizedBox(height: topPadding),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: Center(
                  child: SizedBox(
                    height: preferredItemHeight,
                    width: constraints.maxWidth * 0.8,
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
      ),
    );
  }

  Widget _buildWheelItem(
    BuildContext context, {
    required OptionData option,
    required double itemHeight,
    required double distanceFromCenter,
    required int index,
  }) {
    final opacity = _opacityForDistance(distanceFromCenter, itemHeight);
    final color = Theme.of(
      context,
    ).colorScheme.primary.withValues(alpha: opacity);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => _scrollToItemAt(index, itemHeight, true),
        child: SizedBox(
          height: itemHeight,
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              option.label,
              textAlign: .center,
              style: TextStyle(
                color: color,
                fontSize: LayoutHelper.getPickerItemHeight(context) - 10,
                height: 1,
                fontFamily: FontFamily.doHyeon,
              ),
            ),
          ),
        ),
      ),
    );
  }

  double _opacityForDistance(double distance, double itemHeight) {
    const minOpacity = 0.25;
    const fadeSpan = 2.5;
    final t = (distance / (itemHeight * fadeSpan)).clamp(0.0, 1.0);
    return 1.0 - t * (1.0 - minOpacity);
  }

  bool onScrollNotification(
    ScrollNotification notification,
    BuildContext context,
  ) {
    if (notification is! ScrollEndNotification || _isSnapping) {
      return false;
    }

    final itemHeight = LayoutHelper.getPickerItemHeight(context);
    final currentOffset = _controller.hasClients
        ? _controller.offset
        : notification.metrics.pixels;
    final nearestItemIndex = findNearestItemIndex(
      currentOffset,
      itemHeight,
    ).clamp(0, widget.options.length - 1);

    _scrollToItemAt(nearestItemIndex, itemHeight);

    return false;
  }

  void _scrollToItemAt(
    int nearestItemIndex,
    double itemHeight, [
    bool instant = false,
  ]) {
    final target = nearestItemIndex * itemHeight;

    _isSnapping = true;

    if (instant) {
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
            if (!_initialized) {
              _initialized = true;
            } else {
              widget.onChange(widget.options[nearestItemIndex].value);
            }
          });
      return;
    }

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
            if (!_initialized) {
              _initialized = true;
            } else {
              widget.onChange(widget.options[nearestItemIndex].value);
            }
          });
    });
  }

  int findNearestItemIndex(double currentY, double itemHeight) {
    return (currentY / itemHeight).round();
  }
}

class _WheeledSelectorScrollBehavior extends MaterialScrollBehavior {
  const _WheeledSelectorScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.stylus,
    PointerDeviceKind.trackpad,
  };
}
