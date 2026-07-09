import 'dart:math';

import 'package:flutter/material.dart';
import 'package:meowtronome/core/rhythm_pattern.dart';
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
    LayoutHelper.getNoteSize(context);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Expanded(
            child: LayoutBuilder(
              builder: (_, constraints) => Container(
                constraints: BoxConstraints(
                  minWidth: constraints.maxWidth * 0.6,
                ),
                child: LayoutBuilder(
                  builder: (_, constraints) =>
                      _buildBeatPanel(notifier, constraints, context),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBeatPanel(
    MetronomeNotifier notifier,
    BoxConstraints constraints,
    BuildContext context,
  ) {
    final pattern = notifier.state.pattern;
    final metrics = _PatternMetrics(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CustomIconButton(
          icon: Icons.remove,
          size: metrics.iconSize,
          onTap: () => {notifier.removeBeat()},
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, viewportConstraints) {
              final viewportWidth = viewportConstraints.maxWidth;
              final viewportHeight = viewportConstraints.maxHeight;

              final noteAreaHeight = max(
                viewportHeight - metrics.beatColumnChromeHeight,
                metrics.notesMinHeight(pattern),
              );
              final scrollContentWidth = max(
                viewportWidth,
                metrics.beatsMinWidth(pattern),
              );
              final scrollContentHeight = max(
                viewportHeight,
                metrics.beatColumnChromeHeight + noteAreaHeight,
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
                      for (int i = 0; i < pattern.beats.length; i++)
                        SizedBox(
                          width: metrics.beatColumnWidth,
                          child: Column(
                            children: [
                              CustomIconButton(
                                icon: Icons.remove,
                                size: metrics.iconSize,
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
                                size: metrics.iconSize,
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
          size: metrics.iconSize,
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
          onSecondaryTap: () => {
            notifier.setNoteSoundType(
              beatIndex,
              i,
              beat.notes[i].soundType.getPrevious(),
            ),
          },
          onLongPress: () => {
            notifier.setNoteSoundType(
              beatIndex,
              i,
              beat.notes[i].soundType.getPrevious(),
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

class _PatternMetrics {
  factory _PatternMetrics(BuildContext context) {
    final iconSize = LayoutHelper.getNoteSize(context) * 2;
    const beatButtonPadding = EdgeInsets.all(4);
    return _PatternMetrics._(
      iconSize: iconSize,
      beatButtonPadding: beatButtonPadding,
      noteSize: AnimatedNote.layoutSize(context),
      beatButtonSize: CustomIconButton.layoutSize(
        iconSize: iconSize,
        padding: beatButtonPadding,
      ),
    );
  }

  const _PatternMetrics._({
    required this.iconSize,
    required this.beatButtonPadding,
    required this.noteSize,
    required this.beatButtonSize,
  });

  static const double itemSpacing = PatternPanel.minSpacing;

  final double iconSize;
  final EdgeInsets beatButtonPadding;
  final Size noteSize;
  final Size beatButtonSize;

  double get beatColumnWidth => beatButtonSize.width;
  double get beatButtonHeight => beatButtonSize.height;
  double get beatColumnChromeHeight => beatButtonHeight * 2;

  int _maxNoteCount(RhythmPattern pattern) {
    var count = 0;
    for (final beat in pattern.beats) {
      count = max(count, beat.notes.length);
    }
    return count;
  }

  double _stackedExtent(int count, double itemExtent) {
    if (count <= 0) {
      return 0;
    }
    return count * itemExtent + (count - 1) * itemSpacing;
  }

  double notesMinHeight(RhythmPattern pattern) =>
      _stackedExtent(_maxNoteCount(pattern), noteSize.height);

  double beatsMinWidth(RhythmPattern pattern) =>
      _stackedExtent(pattern.beats.length, beatColumnWidth);
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
