import 'dart:math';

import 'package:flutter/material.dart';

const kAnimatedListDuration = Duration(milliseconds: 250);
const kAnimatedListCurve = Curves.easeInOut;

/// Lays children out with spaceEvenly-style main-axis offsets and interpolates
/// those offsets (and optionally its own main-axis size) on insert/remove.
class AnimatedColumn extends StatefulWidget {
  const AnimatedColumn({
    super.key,
    required this.children,
    required this.axis,
    required this.itemExtent,
    this.minMainExtent = 0,
    this.spacing = 0,
    this.shrinkWrapMain = false,
    this.targetMainExtent,
    this.duration = kAnimatedListDuration,
    this.curve = kAnimatedListCurve,
    this.onDisplayedCountChanged,
  });

  final List<Widget> children;
  final Axis axis;
  final double itemExtent;

  /// Minimum main-axis size when [shrinkWrapMain] is true.
  final double minMainExtent;

  /// Gap used when computing content size for [shrinkWrapMain].
  final double spacing;

  /// If true, this widget animates its own main-axis size from count changes.
  final bool shrinkWrapMain;

  /// When not shrink-wrapping, end offsets are computed against this extent.
  final double? targetMainExtent;

  final Duration duration;
  final Curve curve;

  /// Fired after an exit animation finishes (remaining child count).
  final ValueChanged<int>? onDisplayedCountChanged;

  @override
  State<AnimatedColumn> createState() => _AnimatedColumnState();
}

class _AnimatedColumnState extends State<AnimatedColumn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final CurvedAnimation _animation;

  final List<_Entry> _entries = [];
  double _laidOutMainExtent = 0;
  double _startMainSize = 0;
  double _endMainSize = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..value = 1;
    _animation = CurvedAnimation(parent: _controller, curve: widget.curve);
    for (var i = 0; i < widget.children.length; i++) {
      _entries.add(_Entry(child: widget.children[i], index: i));
    }
    _startMainSize = _mainSizeForCount(widget.children.length);
    _endMainSize = _startMainSize;
  }

  double _mainSizeForCount(int count) {
    if (count <= 0) {
      return widget.minMainExtent;
    }
    // Match spaceEvenly: leading + trailing + between gaps all use [spacing].
    final content =
        count * widget.itemExtent + (count + 1) * widget.spacing;
    return max(widget.minMainExtent, content);
  }

  int get _settledCount => _entries.where((e) => !e.removing).length;

  @override
  void didUpdateWidget(covariant AnimatedColumn oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.duration != widget.duration) {
      _controller.duration = widget.duration;
    }

    final active = [
      for (final entry in _entries)
        if (!entry.removing) entry,
    ];
    final oldCount = active.length;
    final newCount = widget.children.length;

    final shared = min(oldCount, newCount);
    for (var i = 0; i < shared; i++) {
      active[i].child = widget.children[i];
      active[i].index = i;
    }

    if (newCount == oldCount) {
      return;
    }

    if (widget.shrinkWrapMain) {
      _startMainSize = _mainSizeForCount(oldCount);
      _endMainSize = _mainSizeForCount(newCount);
    } else {
      _startMainSize = _laidOutMainExtent > 0
          ? _laidOutMainExtent
          : (widget.targetMainExtent ?? 0);
      _endMainSize = widget.targetMainExtent ?? _startMainSize;
    }

    final startExtent = _startMainSize;
    final endExtent = _endMainSize;

    if (newCount > oldCount) {
      for (var i = 0; i < oldCount; i++) {
        active[i]
          ..startOffset = _evenOffset(i, oldCount, startExtent)
          ..endOffset = _evenOffset(i, newCount, endExtent)
          ..startOpacity = 1
          ..endOpacity = 1;
      }
      for (var i = oldCount; i < newCount; i++) {
        _entries.add(
          _Entry(child: widget.children[i], index: i)
            ..startOffset = startExtent
            ..endOffset = _evenOffset(i, newCount, endExtent)
            ..startOpacity = 0
            ..endOpacity = 1,
        );
      }
    } else {
      for (var i = 0; i < newCount; i++) {
        active[i]
          ..startOffset = _evenOffset(i, oldCount, startExtent)
          ..endOffset = _evenOffset(i, newCount, endExtent)
          ..startOpacity = 1
          ..endOpacity = 1;
      }
      for (var i = oldCount - 1; i >= newCount; i--) {
        active[i]
          ..removing = true
          ..startOffset = _evenOffset(i, oldCount, startExtent)
          ..endOffset = endExtent
          ..startOpacity = 1
          ..endOpacity = 0;
      }
    }

    _controller.forward(from: 0).whenComplete(_onAnimationDone);
  }

  void _onAnimationDone() {
    if (!mounted) {
      return;
    }
    final hadRemovals = _entries.any((e) => e.removing);
    if (hadRemovals) {
      setState(() {
        _entries.removeWhere((e) => e.removing);
      });
      widget.onDisplayedCountChanged?.call(_entries.length);
    }
    for (var i = 0; i < _entries.length; i++) {
      _entries[i]
        ..index = i
        ..removing = false
        ..startOpacity = 1
        ..endOpacity = 1;
    }
    _startMainSize = _endMainSize;
  }

  double _evenOffset(int index, int count, double mainExtent) {
    if (count <= 0 || mainExtent <= 0) {
      return 0;
    }
    final freeSpace = mainExtent - count * widget.itemExtent;
    final gap = freeSpace / (count + 1);
    return gap + index * (widget.itemExtent + gap);
  }

  double get _animatedMainSize {
    if (!_controller.isAnimating) {
      return widget.shrinkWrapMain
          ? _mainSizeForCount(_settledCount)
          : _laidOutMainExtent;
    }
    final t = _animation.value;
    return _startMainSize + (_endMainSize - _startMainSize) * t;
  }

  @override
  void dispose() {
    _animation.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.shrinkWrapMain) {
      return AnimatedBuilder(
        animation: _animation,
        builder: (context, _) {
          final mainSize = _animatedMainSize;
          return SizedBox(
            width: widget.axis == Axis.horizontal ? mainSize : null,
            height: widget.axis == Axis.vertical ? mainSize : null,
            child: _buildStack(mainSize),
          );
        },
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final mainExtent = widget.axis == Axis.horizontal
            ? constraints.maxWidth
            : constraints.maxHeight;
        if (mainExtent.isFinite && mainExtent > 0) {
          _laidOutMainExtent = mainExtent;
        }
        return AnimatedBuilder(
          animation: _animation,
          builder: (context, _) => _buildStack(mainExtent),
        );
      },
    );
  }

  Widget _buildStack(double layoutMainExtent) {
    final t = _animation.value;
    final animating = _controller.isAnimating;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        for (final entry in _entries)
          _positionedChild(
            key: entry.key,
            entry: entry,
            t: t,
            animating: animating,
            settledCount: _settledCount,
            layoutMainExtent: layoutMainExtent,
          ),
      ],
    );
  }

  Widget _positionedChild({
    required Key key,
    required _Entry entry,
    required double t,
    required bool animating,
    required int settledCount,
    required double layoutMainExtent,
  }) {
    final double mainOffset;
    final double opacity;

    if (!animating && !entry.removing) {
      mainOffset = _evenOffset(entry.index, settledCount, layoutMainExtent);
      opacity = 1;
    } else {
      mainOffset =
          entry.startOffset + (entry.endOffset - entry.startOffset) * t;
      opacity =
          (entry.startOpacity + (entry.endOpacity - entry.startOpacity) * t)
              .clamp(0.0, 1.0);
    }

    final child = Opacity(
      opacity: opacity,
      child: IgnorePointer(
        ignoring: entry.removing || opacity < 0.05,
        child: entry.child,
      ),
    );

    if (widget.axis == Axis.horizontal) {
      return Positioned(
        key: key,
        left: mainOffset,
        top: 0,
        bottom: 0,
        width: widget.itemExtent,
        child: child,
      );
    }

    return Positioned(
      key: key,
      top: mainOffset,
      left: 0,
      right: 0,
      height: widget.itemExtent,
      child: child,
    );
  }
}

class _Entry {
  _Entry({required this.child, required this.index});

  final GlobalKey key = GlobalKey();
  Widget child;
  int index;
  bool removing = false;
  double startOffset = 0;
  double endOffset = 0;
  double startOpacity = 1;
  double endOpacity = 1;
}
