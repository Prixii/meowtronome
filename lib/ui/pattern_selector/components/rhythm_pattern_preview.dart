import 'package:flutter/material.dart';
import 'package:meowtronome/core/rhythm_pattern.dart';
import 'package:meowtronome/ui/layout_helper.dart';
import 'package:meowtronome/ui/metronome/components/animated_note.dart';

class RhythmPatternPreview extends StatelessWidget {
  const RhythmPatternPreview({super.key, required this.pattern, this.color});
  final RhythmPattern pattern;
  final Color? color;

  static final notePadding = 5.0;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: .center,
      children: [for (final beat in pattern.beats) _buildBeat(beat, context)],
    );
  }

  Widget _buildBeat(Beat beat, BuildContext context) {
    return Column(
      children: [for (final note in beat.notes) _buildNote(note, context)],
    );
  }

  Widget _buildNote(Note note, BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(notePadding),
      child: AnimatedNote(
        soundType: note.soundType,
        isPlaying: false,
        size: LayoutHelper.getPreviewNoteSize(context),
        strokeWidth: LayoutHelper.getPreviewNoteStrokeWidth(context),
        color: color,
      ),
    );
  }
}
