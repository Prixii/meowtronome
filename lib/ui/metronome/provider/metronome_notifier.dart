import 'dart:async';

import 'package:flutter/material.dart';
import 'package:meowtronome/core/audio/audio_background.dart';
import 'package:meowtronome/core/enums.dart';
import 'package:meowtronome/core/metronome.dart';
import 'package:meowtronome/core/rhythm_pattern.dart';
import 'package:meowtronome/ui/metronome/provider/metronome_runtime_state.dart';

class MetronomeNotifier extends ChangeNotifier {
  final _metronome = Metronome();
  var _runtimeState = MetronomeRuntimeState();

  void Function(int beatIndex, int noteIndex)? onPlayNote;

  int currentBeatIndex = 0;
  int currentNoteIndex = 0;

  bool _isConfigPageOpen = false;

  MetronomeState get state => _metronome.state;
  MetronomeRuntimeState get runtimeState => _runtimeState;
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

    attachMetronomeToAudioBackground(
      _metronome,
      onChanged: notifyListeners,
    );
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
    unawaited(_toggleRunning());
  }

  Future<void> _toggleRunning() async {
    final handler = metronomeAudioHandler;
    if (handler != null) {
      if (isRunning) {
        await handler.stop();
      } else {
        await handler.play();
      }
      return;
    }

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

  void setSelectedTopTabIndex(int index) {
    _runtimeState = _runtimeState.copyWith(selectedTopTabIndex: index);
    notifyListeners();
  }

  void setPattern(RhythmPattern pattern) => _metronome.setPattern(pattern);

  bool get isConfigPageOpen => _isConfigPageOpen;

  @override
  void dispose() {
    detachMetronomeFromAudioBackground();
    _metronome.dispose();
    super.dispose();
  }
}
