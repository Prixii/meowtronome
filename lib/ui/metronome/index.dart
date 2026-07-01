import 'package:flutter/material.dart';
import 'package:meowtronome/core/rhythm_pattern.dart';
import 'package:meowtronome/provider/metronome_notifier.dart';
import 'package:meowtronome/ui/components/custom_icon_button.dart';
import 'package:meowtronome/ui/metronome/components/animated_note.dart';
import 'package:provider/provider.dart';

class MetronomePage extends StatelessWidget {
  const MetronomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<MetronomeNotifier>();

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            children: [
              _buildTopButtonGroup(),
              const SizedBox(height: 32),
              _buildBpmPanel(notifier),
              const SizedBox(height: 32),
              Expanded(child: _buildPatternPanel(notifier)),
              const SizedBox(height: 64),
              _buildPlayButton(notifier),
            ],
          ),
        ),
      ),
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
          style: const TextStyle(fontSize: 68, fontWeight: FontWeight.bold),
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
                  max: 360,
                  min: 10,
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
    final pattern = notifier.state.pattern;
    final beats = [
      for (int i = 0; i < pattern.beats.length; i++)
        _buildBeat(pattern.beats[i], i, notifier),
    ];
    return Column(
      children: [
        CustomIconButton(
          icon: Icons.remove,
          size: 24,
          activeColor: Colors.grey,
          color: Colors.black,
          padding: const EdgeInsets.all(0),
          onTap: () => {notifier.removeNoteForAllBeats()},
        ),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CustomIconButton(
                icon: Icons.remove,
                size: 24,
                activeColor: Colors.grey,
                color: Colors.black,
                padding: const EdgeInsets.all(0),
                onTap: () => {notifier.removeBeat()},
              ),
              ...beats,
              CustomIconButton(
                icon: Icons.add,
                size: 24,
                activeColor: Colors.grey,
                color: Colors.black,
                padding: const EdgeInsets.all(0),
                onTap: () => {notifier.addBeat()},
              ),
            ],
          ),
        ),
        CustomIconButton(
          icon: Icons.add,
          size: 24,
          activeColor: Colors.grey,
          color: Colors.black,
          padding: const EdgeInsets.all(0),
          onTap: () => {notifier.addNoteForAllBeats()},
        ),
      ],
    );
  }

  Widget _buildBeat(Beat beat, int beatIndex, MetronomeNotifier notifier) {
    final noteWidgets = [
      for (int i = 0; i < beat.notes.length; i++)
        GestureDetector(
          child: AnimatedNote(soundType: beat.notes[i].soundType),
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
      children: [
        CustomIconButton(
          icon: Icons.remove,
          size: 24,
          activeColor: Colors.grey,
          color: Colors.black,
          padding: const EdgeInsets.all(0),
          onTap: () => {notifier.removeNoteForBeatAt(beatIndex)},
        ),
        ...noteWidgets,
        CustomIconButton(
          icon: Icons.add,
          size: 24,
          activeColor: Colors.grey,
          color: Colors.black,
          padding: const EdgeInsets.all(0),
          onTap: () => {notifier.addNoteForBeatAt(beatIndex)},
        ),
      ],
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
