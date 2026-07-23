import 'dart:math';

import 'package:flutter/material.dart';
import 'package:meowtronome/core/enums.dart';
import 'package:meowtronome/core/rhythm_pattern.dart';
import 'package:meowtronome/ui/components/animated_list.dart';
import 'package:meowtronome/ui/components/custom_icon_button.dart';
import 'package:meowtronome/ui/haptic_helper.dart';
import 'package:meowtronome/ui/layout_helper.dart';
import 'package:meowtronome/ui/metronome/components/animated_note.dart';
import 'package:meowtronome/ui/metronome/provider/metronome_notifier.dart';
import 'package:provider/provider.dart';

class PatternPanel extends StatelessWidget {
  const PatternPanel({super.key, required this.notifier});

  static const double minSpacing = 8.0;

  final MetronomeNotifier notifier;
  @override
  Widget build(BuildContext context) {
    // Rebuild only when the rhythm pattern changes, not on BPM / play toggles.
    context.select<MetronomeNotifier, RhythmPattern>((n) => n.pattern);
    LayoutHelper.getNoteSize(context);
    return Column(
      children: [
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
      ],
    );
  }

  Widget _buildBeatPanel(
    MetronomeNotifier notifier,
    BoxConstraints constraints,
    BuildContext context,
  ) {
    final metrics = _PatternMetrics(context);

    return Column(
      children: [
        const SizedBox(height: 32),
        Expanded(
          child: _PatternGrid(notifier: notifier, metrics: metrics),
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}

class _PatternGrid extends StatefulWidget {
  const _PatternGrid({required this.notifier, required this.metrics});

  final MetronomeNotifier notifier;
  final _PatternMetrics metrics;

  @override
  State<_PatternGrid> createState() => _PatternGridState();
}

class _PatternGridState extends State<_PatternGrid> {
  late int _hostBeatCount;

  RhythmPattern get _pattern => widget.notifier.state.pattern;

  @override
  void initState() {
    super.initState();
    _hostBeatCount = _pattern.beats.length;
  }

  @override
  void didUpdateWidget(covariant _PatternGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    final beatCount = _pattern.beats.length;
    if (beatCount > _hostBeatCount) {
      _hostBeatCount = beatCount;
    }
  }

  void _onBeatAnimationDone(int count) {
    if (count >= _hostBeatCount) {
      return;
    }
    setState(() => _hostBeatCount = count);
  }

  @override
  Widget build(BuildContext context) {
    final pattern = _pattern;
    final metrics = widget.metrics;
    final notifier = widget.notifier;

    return LayoutBuilder(
      builder: (context, viewportConstraints) {
        final viewportWidth = viewportConstraints.maxWidth;
        final viewportHeight = viewportConstraints.maxHeight;
        final gridMinSize = LayoutHelper.getPatternGridMinSize(
          context,
          parentSize: Size(viewportWidth, viewportHeight),
        );

        final maxNoteCount = _maxNoteCount(pattern);
        final tallestBeatHeight = metrics.stackedExtent(
          maxNoteCount,
          metrics.noteSize.height,
        );
        final gridHeight = max(gridMinSize.height, tallestBeatHeight);

        final hostGridWidth = max(
          gridMinSize.width,
          metrics.stackedExtent(_hostBeatCount, metrics.beatColumnWidth),
        );
        final beatControlsWidth =
            metrics.beatButtonSize.width * 2 + PatternPanel.minSpacing * 2;
        final patternBodyWidth = hostGridWidth + beatControlsWidth;

        final patternHeight = metrics.beatColumnChromeHeight + gridHeight;
        final scrollContentWidth = max(viewportWidth, patternBodyWidth);
        final scrollContentHeight = max(viewportHeight, patternHeight);
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
            child: Center(
              child: AnimatedContainer(
                duration: kAnimatedListDuration,
                curve: kAnimatedListCurve,
                height: patternHeight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CustomIconButton(
                      icon: Icons.remove,
                      size: metrics.iconSize,
                      enableLongPressRepeat: true,
                      onTap: () => notifier.removeBeat(),
                    ),
                    SizedBox(width: PatternPanel.minSpacing),
                    AnimatedColumn(
                      axis: Axis.horizontal,
                      itemExtent: metrics.beatColumnWidth,
                      minMainExtent: gridMinSize.width,
                      spacing: PatternPanel.minSpacing,
                      shrinkWrapMain: true,
                      onDisplayedCountChanged: _onBeatAnimationDone,
                      children: [
                        for (int i = 0; i < pattern.beats.length; i++)
                          _BeatColumn(
                            width: metrics.beatColumnWidth,
                            buttonHeight: metrics.beatButtonHeight,
                            iconSize: metrics.iconSize,
                            gridHeight: gridHeight,
                            beat: pattern.beats[i],
                            beatIndex: i,
                            notifier: notifier,
                            noteExtent: metrics.noteSize.height,
                          ),
                      ],
                    ),
                    SizedBox(width: PatternPanel.minSpacing),
                    CustomIconButton(
                      icon: Icons.add,
                      size: metrics.iconSize,
                      enableLongPressRepeat: true,
                      onTap: () => notifier.addBeat(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  int _maxNoteCount(RhythmPattern pattern) {
    var count = 0;
    for (final beat in pattern.beats) {
      count = max(count, beat.notes.length);
    }
    return count;
  }
}

class _BeatColumn extends StatelessWidget {
  const _BeatColumn({
    required this.width,
    required this.buttonHeight,
    required this.iconSize,
    required this.gridHeight,
    required this.beat,
    required this.beatIndex,
    required this.notifier,
    required this.noteExtent,
  });

  final double width;
  final double buttonHeight;
  final double iconSize;
  final double gridHeight;
  final Beat beat;
  final int beatIndex;
  final MetronomeNotifier notifier;
  final double noteExtent;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: width,
          height: buttonHeight,
          child: Center(
            child: CustomIconButton(
              icon: Icons.remove,
              size: iconSize,
              enableLongPressRepeat: true,
              onTap: () => notifier.removeNoteForBeatAt(beatIndex),
            ),
          ),
        ),
        Expanded(
          child: AnimatedColumn(
            axis: Axis.vertical,
            itemExtent: noteExtent,
            targetMainExtent: gridHeight,
            children: [
              for (int i = 0; i < beat.notes.length; i++)
                SizedBox(
                  width: width,
                  height: noteExtent,
                  child: Center(
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        child: _PlayheadNote(
                          notifier: notifier,
                          beatIndex: beatIndex,
                          noteIndex: i,
                          soundType: beat.notes[i].soundType,
                          size: LayoutHelper.getNoteSize(context),
                        ),
                        onTap: () {
                          notifier.setNoteSoundType(
                            beatIndex,
                            i,
                            beat.notes[i].soundType.getNext(),
                          );
                          triggerLightHaptic();
                        },
                        onSecondaryTap: () {
                          notifier.setNoteSoundType(
                            beatIndex,
                            i,
                            beat.notes[i].soundType.getPrevious(),
                          );
                        },
                        onLongPress: () {
                          notifier.setNoteSoundType(
                            beatIndex,
                            i,
                            beat.notes[i].soundType.getPrevious(),
                          );
                          triggerLightHaptic();
                        },
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        SizedBox(
          width: width,
          height: buttonHeight,
          child: Center(
            child: CustomIconButton(
              icon: Icons.add,
              size: iconSize,
              enableLongPressRepeat: true,
              onTap: () => notifier.addNoteForBeatAt(beatIndex),
            ),
          ),
        ),
      ],
    );
  }
}

/// Rebuilds only when this note's playhead match flips.
class _PlayheadNote extends StatefulWidget {
  const _PlayheadNote({
    required this.notifier,
    required this.beatIndex,
    required this.noteIndex,
    required this.soundType,
    required this.size,
  });

  final MetronomeNotifier notifier;
  final int beatIndex;
  final int noteIndex;
  final SoundType soundType;
  final double size;

  @override
  State<_PlayheadNote> createState() => _PlayheadNoteState();
}

class _PlayheadNoteState extends State<_PlayheadNote> {
  late bool _isPlaying;

  @override
  void initState() {
    super.initState();
    _isPlaying = widget.notifier.isCurrentNote(
      widget.beatIndex,
      widget.noteIndex,
    );
    widget.notifier.playPosition.addListener(_onPlayPosition);
  }

  @override
  void didUpdateWidget(covariant _PlayheadNote oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.notifier.playPosition != widget.notifier.playPosition) {
      oldWidget.notifier.playPosition.removeListener(_onPlayPosition);
      widget.notifier.playPosition.addListener(_onPlayPosition);
    }
    final next = widget.notifier.isCurrentNote(
      widget.beatIndex,
      widget.noteIndex,
    );
    if (next != _isPlaying) {
      _isPlaying = next;
    }
  }

  @override
  void dispose() {
    widget.notifier.playPosition.removeListener(_onPlayPosition);
    super.dispose();
  }

  void _onPlayPosition() {
    final next = widget.notifier.isCurrentNote(
      widget.beatIndex,
      widget.noteIndex,
    );
    if (next != _isPlaying) {
      setState(() => _isPlaying = next);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedNote(
      soundType: widget.soundType,
      isPlaying: _isPlaying,
      size: widget.size,
    );
  }
}

class _PatternMetrics {
  factory _PatternMetrics(BuildContext context) {
    final noteSize = AnimatedNote.layoutSize(context);
    const beatButtonPadding = EdgeInsets.zero;
    final iconSize = LayoutHelper.getNoteSize(context) * 1.5;
    return _PatternMetrics._(
      iconSize: iconSize,
      beatButtonPadding: beatButtonPadding,
      noteSize: noteSize,
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

  /// Column width follows the note; control icons may be wider visually.
  double get beatColumnWidth => noteSize.width;
  double get beatButtonHeight => beatButtonSize.height;
  double get beatColumnChromeHeight => beatButtonHeight * 2;

  /// Content extent so spaceEvenly gaps equal [itemSpacing] on all sides.
  double stackedExtent(int count, double itemExtent) {
    if (count <= 0) {
      return 0;
    }
    return count * itemExtent + (count + 1) * itemSpacing;
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
