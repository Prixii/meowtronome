import 'dart:math';

import 'package:flutter/material.dart';
import 'package:meowtronome/core/rhythm_pattern.dart';
import 'package:meowtronome/global.dart';
import 'package:meowtronome/ui/components/custom_icon_button.dart';
import 'package:meowtronome/ui/layout_helper.dart';
import 'package:meowtronome/ui/metronome/components/animated_note.dart';
import 'package:meowtronome/ui/metronome/provider/metronome_notifier.dart';

class PatternPanel extends StatelessWidget {
  const PatternPanel({super.key, required this.notifier});

  static const double minSpacing = 12.0;

  final MetronomeNotifier notifier;
  @override
  Widget build(BuildContext context) {
    final noteSize = LayoutHelper.getNoteSize(context);
    const beatButtonPadding = 4.0;
    return Column(
      children: [
        CustomIconButton(
          icon: Icons.remove,
          activeColor: Colors.grey,
          color: iconColor,
          padding: const EdgeInsets.all(beatButtonPadding),
          size: noteSize * 2,
          onTap: () => {notifier.removeNoteForAllBeats()},
        ),
        SizedBox(height: noteSize),
        Expanded(
          child: LayoutBuilder(
            builder: (_, constraints) => Container(
              constraints: BoxConstraints(minWidth: constraints.maxWidth * 0.6),
              child: LayoutBuilder(
                builder: (_, constraints) =>
                    _buildBeatPanel(notifier, constraints, context),
              ),
            ),
          ),
        ),
        SizedBox(height: noteSize),
        CustomIconButton(
          icon: Icons.add,
          activeColor: Colors.grey,
          color: iconColor,
          padding: const EdgeInsets.all(beatButtonPadding),
          size: noteSize * 2,
          onTap: () => {notifier.addNoteForAllBeats()},
        ),
      ],
    );
  }

  Widget _buildBeatPanel(
    MetronomeNotifier notifier,
    BoxConstraints constraints,
    BuildContext context,
  ) {
    final pattern = notifier.state.pattern;
    final beatCount = pattern.beats.length;
    final noteWidgetSize = LayoutHelper.getNoteSize(context) * 2;
    const beatButtonPadding = 4.0;
    final beatButtonHeight = iconButtonSize + beatButtonPadding * 2;

    var maxNoteCount = 0;
    for (final beat in pattern.beats) {
      maxNoteCount = max(maxNoteCount, beat.notes.length);
    }

    final notesMinHeight = maxNoteCount > 0
        ? maxNoteCount * noteWidgetSize + (maxNoteCount - 1) * minSpacing
        : 0.0;

    final beatsMinWidth = beatCount > 0
        ? beatCount * noteWidgetSize + (beatCount - 1) * minSpacing
        : 0.0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CustomIconButton(
          icon: Icons.remove,
          activeColor: Colors.grey,
          color: iconColor,
          padding: const EdgeInsets.all(4),
          size: LayoutHelper.getNoteSize(context) * 2,
          onTap: () => {notifier.removeBeat()},
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, viewportConstraints) {
              final viewportWidth = viewportConstraints.maxWidth;
              final viewportHeight = viewportConstraints.maxHeight;

              final noteAreaHeight = max(
                viewportHeight - 2 * beatButtonHeight,
                notesMinHeight,
              );
              final scrollContentWidth = max(viewportWidth, beatsMinWidth);
              final scrollContentHeight = max(
                viewportHeight,
                2 * beatButtonHeight + noteAreaHeight,
              );
              final canScroll =
                  scrollContentWidth > viewportWidth ||
                  scrollContentHeight > viewportHeight;

              return _PatternScrollArea(
                scrollContentWidth: scrollContentWidth,
                scrollContentHeight: scrollContentHeight,
                viewportWidth: viewportWidth,
                viewportHeight: viewportHeight,
                canScroll: canScroll,
                child: SizedBox(
                  width: scrollContentWidth,
                  height: scrollContentHeight,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      for (int i = 0; i < beatCount; i++)
                        SizedBox(
                          width: noteWidgetSize * 1.5,
                          child: Column(
                            children: [
                              CustomIconButton(
                                icon: Icons.remove,
                                activeColor: Colors.grey,
                                color: iconColor,
                                padding: const EdgeInsets.all(
                                  beatButtonPadding,
                                ),
                                size: noteWidgetSize,
                                onTap: () => {notifier.removeNoteForBeatAt(i)},
                              ),
                              SizedBox(
                                height: noteAreaHeight,
                                child: _buildBeat(
                                  pattern.beats[i],
                                  i,
                                  notifier,
                                ),
                              ),
                              CustomIconButton(
                                icon: Icons.add,
                                activeColor: Colors.grey,
                                color: iconColor,
                                padding: const EdgeInsets.all(
                                  beatButtonPadding,
                                ),
                                size: noteWidgetSize,
                                onTap: () => {notifier.addNoteForBeatAt(i)},
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        CustomIconButton(
          icon: Icons.add,
          activeColor: Colors.grey,
          color: iconColor,
          padding: const EdgeInsets.all(4),
          size: LayoutHelper.getNoteSize(context) * 2,
          onTap: () => {notifier.addBeat()},
        ),
      ],
    );
  }

  Widget _buildBeat(Beat beat, int beatIndex, MetronomeNotifier notifier) {
    final noteWidgets = [
      for (int i = 0; i < beat.notes.length; i++)
        GestureDetector(
          child: AnimatedNote(
            soundType: beat.notes[i].soundType,
            isPlaying: notifier.isCurrentNote(beatIndex, i),
          ),
          onTap: () => {
            notifier.setNoteSoundType(
              beatIndex,
              i,
              beat.notes[i].soundType.getNext(),
            ),
          },
        ),
    ];
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: noteWidgets,
    );
  }
}

class _PatternScrollArea extends StatefulWidget {
  const _PatternScrollArea({
    required this.scrollContentWidth,
    required this.scrollContentHeight,
    required this.viewportWidth,
    required this.viewportHeight,
    required this.canScroll,
    required this.child,
  });

  final double scrollContentWidth;
  final double scrollContentHeight;
  final double viewportWidth;
  final double viewportHeight;
  final bool canScroll;
  final Widget child;

  @override
  State<_PatternScrollArea> createState() => _PatternScrollAreaState();
}

class _PatternScrollAreaState extends State<_PatternScrollArea> {
  final TransformationController _transformController =
      TransformationController();

  @override
  void didUpdateWidget(covariant _PatternScrollArea oldWidget) {
    super.didUpdateWidget(oldWidget);
    final widthIncreased =
        widget.scrollContentWidth > oldWidget.scrollContentWidth;
    final heightIncreased =
        widget.scrollContentHeight > oldWidget.scrollContentHeight;
    final sizeChanged =
        oldWidget.scrollContentWidth != widget.scrollContentWidth ||
        oldWidget.scrollContentHeight != widget.scrollContentHeight;
    final viewportChanged =
        oldWidget.viewportWidth != widget.viewportWidth ||
        oldWidget.viewportHeight != widget.viewportHeight;

    if (!sizeChanged && !viewportChanged) {
      return;
    }

    _updateTransform(
      scrollToEndX: widthIncreased,
      scrollToEndY: heightIncreased,
    );
  }

  void _updateTransform({
    required bool scrollToEndX,
    required bool scrollToEndY,
  }) {
    final matrix = _transformController.value;
    final translation = matrix.getTranslation();
    final x = _resolveTranslationAxis(
      translation.x,
      widget.viewportWidth,
      widget.scrollContentWidth,
      scrollToEnd: scrollToEndX,
    );
    final y = _resolveTranslationAxis(
      translation.y,
      widget.viewportHeight,
      widget.scrollContentHeight,
      scrollToEnd: scrollToEndY,
    );

    if (x == translation.x && y == translation.y) {
      return;
    }

    _transformController.value = matrix.clone()..setTranslationRaw(x, y, 0);
  }

  double _resolveTranslationAxis(
    double translation,
    double viewportSize,
    double contentSize, {
    required bool scrollToEnd,
  }) {
    if (scrollToEnd) {
      return _endTranslationAxis(viewportSize, contentSize);
    }
    if (_isTranslationWithinBounds(translation, viewportSize, contentSize)) {
      return translation;
    }
    return _endTranslationAxis(viewportSize, contentSize);
  }

  bool _isTranslationWithinBounds(
    double translation,
    double viewportSize,
    double contentSize,
  ) {
    final edge = viewportSize - contentSize;
    return translation >= min(edge, 0.0) && translation <= max(edge, 0.0);
  }

  double _endTranslationAxis(double viewportSize, double contentSize) {
    return viewportSize - contentSize;
  }

  @override
  void dispose() {
    _transformController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      transformationController: _transformController,
      constrained: false,
      panEnabled: widget.canScroll,
      scaleEnabled: false,
      child: widget.child,
    );
  }
}
