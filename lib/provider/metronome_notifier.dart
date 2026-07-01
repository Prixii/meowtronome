import 'package:flutter/material.dart';
import 'package:meowtronome/core/enums.dart';
import 'package:meowtronome/core/metronome.dart';
import 'package:meowtronome/core/rhythm_pattern.dart';

class MetronomeNotifier extends ChangeNotifier {
  final Metronome _metronome = Metronome();

  int currentBeatIndex = 0;
  int currentNoteIndex = 0;

  MetronomeState get state => _metronome.state;
  RhythmPattern get pattern => _metronome.state.pattern;
  int get bpm => _metronome.bpm;
  bool get isRunning => _metronome.isRunning;

  MetronomeNotifier() {
    _metronome.setOnPlayNote((scheduler) {
      final rt = scheduler.runtimeState;
      currentBeatIndex = rt.currentBeatIndex;
      currentNoteIndex = rt.currentNoteIndex;
      notifyListeners();
    });
  }

  void setBpm(int value) {
    _metronome.setBpm(value);
    notifyListeners();
  }

  void addNoteForBeatAt(int beatIndex) {
    _metronome.addNoteForBeatAt(beatIndex);
    notifyListeners();
  }

  void removeNoteForBeatAt(int beatIndex) {
    _metronome.removeNoteForBeatAt(beatIndex);
    notifyListeners();
  }

  void addNoteForAllBeats() {
    _metronome.addNoteForAllBeats();
    notifyListeners();
  }

  void removeNoteForAllBeats() {
    _metronome.removeNoteForAllBeats();
    notifyListeners();
  }

  void addBeat() {
    _metronome.addBeat();
    notifyListeners();
  }

  void removeBeat() {
    _metronome.removeBeat();
    notifyListeners();
  }

  void setNoteSoundType(int beatIndex, int noteIndex, SoundType soundType) {
    _metronome.setNoteSoundType(beatIndex, noteIndex, soundType);
    notifyListeners();
  }

  void toggleRunning() {
    if (isRunning) {
      _metronome.stop();
    } else {
      _metronome.start();
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _metronome.dispose();
    super.dispose();
  }
}
