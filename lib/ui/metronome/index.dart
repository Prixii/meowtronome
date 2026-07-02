import 'dart:math';

import 'package:flutter/material.dart';
import 'package:meowtronome/core/rhythm_pattern.dart';
import 'package:meowtronome/global.dart';
import 'package:meowtronome/provider/metronome_notifier.dart';
import 'package:meowtronome/ui/components/custom_icon_button.dart';
import 'package:meowtronome/ui/metronome/components/animated_note.dart';
import 'package:provider/provider.dart';

class MetronomePage extends StatelessWidget {
  const MetronomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<MetronomeNotifier>();
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: screenWidth > screenHeight
              ? _buildBodyWide(notifier)
              : _buildBody(notifier),
        ),
      ),
    );
  }

  Widget _buildBody(MetronomeNotifier notifier) {
    return Column(
      children: [
        _buildTopButtonGroup(),
        _buildBpmPanel(notifier),
        const SizedBox(height: 32),
        Expanded(child: _buildPatternPanel(notifier)),
        const SizedBox(height: 64),
        _buildPlayButton(notifier),
      ],
    );
  }

  Widget _buildBodyWide(MetronomeNotifier notifier) {
    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              Expanded(child: _buildBpmPanel(notifier)),
              const SizedBox(height: 64),
              _buildPlayButton(notifier),
            ],
          ),
        ),
        const SizedBox(width: 32),
        Expanded(
          child: Column(
            children: [
              _buildTopButtonGroup(),
              const SizedBox(height: 32),
              Expanded(child: _buildPatternPanel(notifier)),
            ],
          ),
        ),
      ],
    );
  }

  //=======================
  Widget _buildTopButtonGroup() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        CustomIconButton(
          onTap: () => {},
          icon: Icons.list,
          size: 24,
          activeColor: Colors.grey,
          color: Colors.black,
        ),
        CustomIconButton(
          onTap: () => {},
          icon: Icons.music_note,
          size: 24,
          activeColor: Colors.grey,
          color: Colors.black,
        ),
        CustomIconButton(
          onTap: () => {},
          icon: Icons.settings,
          size: 24,
          activeColor: Colors.grey,
          color: Colors.black,
        ),
      ],
    );
  }

  //=======================
  Widget _buildBpmPanel(MetronomeNotifier notifier) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          notifier.bpm.toString(),
          style: const TextStyle(fontSize: 98, fontWeight: FontWeight.bold),
        ),
        SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CustomIconButton(
                icon: Icons.remove,
                size: 24,
                padding: const EdgeInsets.all(0),
                activeColor: Colors.grey,
                color: Colors.black,
                onTap: () => notifier.setBpm(notifier.bpm - 1),
              ),
              Expanded(
                child: Slider(
                  value: notifier.bpm.toDouble(),
                  max: 300,
                  min: 10,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 0,
                  ),
                  onChanged: (newValue) => {
                    notifier.setBpm((newValue).toInt()),
                  },
                  // ignore: deprecated_member_use
                  year2023: false,
                ),
              ),
              CustomIconButton(
                icon: Icons.add,
                size: 24,
                activeColor: Colors.grey,
                color: Colors.black,
                padding: const EdgeInsets.all(0),
                onTap: () => notifier.setBpm(notifier.bpm + 1),
              ),
            ],
          ),
        ),
      ],
    );
  }

  //=======================
  Widget _buildPatternPanel(MetronomeNotifier notifier) {
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
            size: noteSize,
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
            size: noteSize,
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
          size: noteSize,
          activeColor: Colors.grey,
          color: Colors.black,
          padding: const EdgeInsets.all(0),
          onTap: () => {notifier.removeBeat()},
        ),
        ...[
          for (int i = 0; i < pattern.beats.length; i++)
            Column(
              children: [
                CustomIconButton(
                  icon: Icons.remove,
                  size: noteSize,
                  activeColor: Colors.grey,
                  color: Colors.black,
                  padding: const EdgeInsets.all(0),
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
                  size: noteSize,
                  activeColor: Colors.grey,
                  color: Colors.black,
                  padding: const EdgeInsets.all(0),
                  onTap: () => {notifier.addNoteForBeatAt(i)},
                ),
              ],
            ),
        ],
        CustomIconButton(
          icon: Icons.add,
          size: noteSize,
          activeColor: Colors.grey,
          color: Colors.black,
          padding: const EdgeInsets.all(0),
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

  //=======================
  Widget _buildPlayButton(MetronomeNotifier notifier) {
    return Container(
      height: 60,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.pink,
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      child: IconButton(
        icon: const Icon(Icons.play_arrow),
        color: Colors.white,
        onPressed: () => notifier.toggleRunning(),
      ),
    );
  }
}
