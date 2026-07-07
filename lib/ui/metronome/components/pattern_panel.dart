import 'dart:math';

import 'package:flutter/material.dart';
import 'package:meowtronome/core/rhythm_pattern.dart';
import 'package:meowtronome/global.dart';
import 'package:meowtronome/ui/components/custom_icon_button.dart';
import 'package:meowtronome/ui/metronome/components/animated_note.dart';
import 'package:meowtronome/ui/metronome/provider/metronome_notifier.dart';

class PatternPanel extends StatelessWidget {
  const PatternPanel({super.key, required this.notifier});
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
                      _buildBeatPanel(notifier, constraints),
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
  ) {
    final pattern = notifier.state.pattern;
    var maxNoteCount = 0;

    final maxHeight = constraints.maxHeight;
    var preferredMinHeight = maxHeight * 0.6;

    for (int i = 0; i < pattern.beats.length; i++) {
      maxNoteCount = max(maxNoteCount, pattern.beats[i].notes.length);
    }
    final noteHeight = maxNoteCount * (2 * noteSize);

    final double preferredMaxHeight = min(
      0.9 * maxHeight,
      max(noteHeight, maxHeight),
    );

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
        ...[
          for (int i = 0; i < pattern.beats.length; i++)
            Column(
              children: [
                CustomIconButton(
                  icon: Icons.remove,
                  activeColor: Colors.grey,
                  color: Colors.black,
                  padding: const EdgeInsets.all(4),
                  onTap: () => {notifier.removeNoteForBeatAt(i)},
                ),
                Expanded(
                  child: Container(
                    constraints: BoxConstraints(
                      minHeight: preferredMinHeight,
                      maxHeight: preferredMaxHeight,
                    ),
                    child: _buildBeat(pattern.beats[i], i, notifier),
                  ),
                ),
                CustomIconButton(
                  icon: Icons.add,
                  activeColor: Colors.grey,
                  color: Colors.black,
                  padding: const EdgeInsets.all(4),
                  onTap: () => {notifier.addNoteForBeatAt(i)},
                ),
              ],
            ),
        ],
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
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [...noteWidgets],
    );
  }
}
