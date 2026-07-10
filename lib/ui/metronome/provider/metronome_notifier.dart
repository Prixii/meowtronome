import 'package:flutter/material.dart';
import 'package:meowtronome/core/enums.dart';
import 'package:meowtronome/core/metronome.dart';
import 'package:meowtronome/core/rhythm_pattern.dart';

class MetronomeNotifier extends ChangeNotifier {
  final Metronome _metronome = Metronome();

  void Function(int beatIndex, int noteIndex)? onPlayNote;

  int currentBeatIndex = 0;
  int currentNoteIndex = 0;

  bool _isConfigPageOpen = false;

  MetronomeState get state => _metronome.state;
  RhythmPattern get pattern => _metronome.state.pattern;
  int get bpm => _metronome.bpm;
  bool get isRunning => _metronome.isRunning;

  MetronomeNotifier();

  Future<void> init() async {
    await _metronome.init();

    _metronome.setOnPlayNote((scheduler) {
      final rt = scheduler.runtimeState;
      currentBeatIndex = rt.currentBeatIndex;
      currentNoteIndex = rt.currentNoteIndex;
      onPlayNote?.call(currentBeatIndex, currentNoteIndex);
      notifyListeners();
    });
  }

  void setOnPlayNoteCallback(
    void Function(int beatIndex, int noteIndex) callback,
  ) {
    onPlayNote = callback;
  }

  bool isCurrentNote(int beatIndex, int noteIndex) {
    return currentBeatIndex == beatIndex && currentNoteIndex == noteIndex;
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

  void openConfigPage() {
    _isConfigPageOpen = true;
    notifyListeners();
  }

  void closeConfigPage() {
    _isConfigPageOpen = false;
    notifyListeners();
  }

  void setToneForSoundType(SoundType soundType, String tone) {
    _metronome.setToneForSoundType(soundType, tone);
    notifyListeners();
  }

  bool get isConfigPageOpen => _isConfigPageOpen;

  @override
  void dispose() {
    _metronome.dispose();
    super.dispose();
  }
}
