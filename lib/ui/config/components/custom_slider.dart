import 'package:flutter/material.dart';

class CustomSlider extends StatefulWidget {
  const CustomSlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max = 1,
    this.valueFormatter,
    this.width = 160,
  });

  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;
  final String Function(double value)? valueFormatter;
  final double width;

  @override
  State<CustomSlider> createState() => _CustomSliderState();
}

class _CustomSliderState extends State<CustomSlider> {
  double? _dragValue;

  double get _effectiveValue =>
      (_dragValue ?? widget.value).clamp(widget.min, widget.max);

  double get _normalizedValue {
    final range = widget.max - widget.min;
    if (range <= 0) return 0;
    return ((_effectiveValue - widget.min) / range).clamp(0.0, 1.0);
  }

  void _updateValue(double normalized, double trackWidth) {
    if (trackWidth <= 0) return;

    final clamped = normalized.clamp(0.0, 1.0);
    final next = widget.min + clamped * (widget.max - widget.min);
    setState(() => _dragValue = next);
  }

  void _commitValue() {
    if (_dragValue == null) return;

    widget.onChanged(_dragValue!.clamp(widget.min, widget.max));
    setState(() => _dragValue = null);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final trackWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : widget.width;

        return _FlatSliderTrack(
          normalizedValue: _normalizedValue,
          trackWidth: trackWidth,
          onDragStart: (normalized) => _updateValue(normalized, trackWidth),
          onDragUpdate: (normalized) => _updateValue(normalized, trackWidth),
          onDragEnd: _commitValue,
        );
      },
    );
  }
}

class _FlatSliderTrack extends StatelessWidget {
  const _FlatSliderTrack({
    required this.normalizedValue,
    required this.trackWidth,
    required this.onDragStart,
    required this.onDragUpdate,
    required this.onDragEnd,
  });

  final double normalizedValue;
  final double trackWidth;
  final ValueChanged<double> onDragStart;
  final ValueChanged<double> onDragUpdate;
  final VoidCallback onDragEnd;

  static const double trackHeight = 8;
  static const double thumbSize = 20;
  static const double hitHeight = 32;

  double _normalizedFromDx(double dx) {
    final usable = trackWidth - thumbSize;
    if (usable <= 0) return 0;
    return ((dx - thumbSize / 2) / usable).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final thumbOffset = normalizedValue * (trackWidth - thumbSize);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onHorizontalDragStart: (details) =>
          onDragStart(_normalizedFromDx(details.localPosition.dx)),
      onHorizontalDragUpdate: (details) =>
          onDragUpdate(_normalizedFromDx(details.localPosition.dx)),
      onHorizontalDragEnd: (_) => onDragEnd(),
      onTapDown: (details) {
        onDragStart(_normalizedFromDx(details.localPosition.dx));
        onDragEnd();
      },
      child: SizedBox(
        height: hitHeight,
        width: trackWidth,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.centerLeft,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                height: trackHeight,
                width: trackWidth,
                color: colorScheme.primaryFixed,
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                height: trackHeight,
                width: thumbOffset + thumbSize / 2,
                color: colorScheme.primary,
              ),
            ),
            Positioned(
              left: thumbOffset,
              top: (hitHeight - thumbSize) / 2,
              child: Container(
                width: thumbSize,
                height: thumbSize,
                color: colorScheme.primary,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: colorScheme.primaryContainer,
                      width: 2,
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
}
