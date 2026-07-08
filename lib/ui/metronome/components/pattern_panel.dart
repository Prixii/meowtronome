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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          CustomIconButton(
            icon: Icons.remove,
            activeColor: Colors.grey,
            color: Colors.black,
            padding: const EdgeInsets.all(0),
            onTap: () => {notifier.removeNoteForAllBeats()},
          ),
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
          CustomIconButton(
            icon: Icons.add,
            activeColor: Colors.grey,
            color: Colors.black,
            padding: const EdgeInsets.all(0),
            onTap: () => {notifier.addNoteForAllBeats()},
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
    final beatCount = pattern.beats.length;
    final noteWidgetSize =
        LayoutHelper.getNoteSize(context) + AnimatedNote.paddingSize * 2;
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
          color: Colors.black,
          padding: const EdgeInsets.all(4),
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
                          width: noteWidgetSize,
                          child: Column(
                            children: [
                              CustomIconButton(
                                icon: Icons.remove,
                                activeColor: Colors.grey,
                                color: Colors.black,
                                padding: const EdgeInsets.all(
                                  beatButtonPadding,
                                ),
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
                                color: Colors.black,
                                padding: const EdgeInsets.all(
                                  beatButtonPadding,
                                ),
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
          color: Colors.black,
          padding: const EdgeInsets.all(4),
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
    required this.canScroll,
    required this.child,
  });

  final double scrollContentWidth;
  final double scrollContentHeight;
  final bool canScroll;
  final Widget child;

  @override
  State<_PatternScrollArea> createState() => _PatternScrollAreaState();
}

class _PatternScrollAreaState extends State<_PatternScrollArea> {
  final TransformationController _transformController =
      TransformationController();
  Size? _lastContentSize;

  @override
  void initState() {
    super.initState();
    _lastContentSize = Size(
      widget.scrollContentWidth,
      widget.scrollContentHeight,
    );
  }

  @override
  void didUpdateWidget(covariant _PatternScrollArea oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newSize = Size(widget.scrollContentWidth, widget.scrollContentHeight);
    final lastSize = _lastContentSize;
    if (lastSize != null &&
        (newSize.width < lastSize.width ||
            newSize.height < lastSize.height ||
            (oldWidget.canScroll && !widget.canScroll))) {
      _transformController.value = Matrix4.identity();
    }
    _lastContentSize = newSize;
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
