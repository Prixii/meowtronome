import 'dart:async';

import 'package:flutter/material.dart';
import 'package:meowtronome/core/accelerando.dart';
import 'package:meowtronome/core/audio/audio_background.dart';
import 'package:meowtronome/core/enums.dart';
import 'package:meowtronome/core/metronome.dart';
import 'package:meowtronome/core/rhythm_pattern.dart';
import 'package:meowtronome/ui/metronome/provider/metronome_runtime_state.dart';
import 'package:meowtronome/ui/statistics/provider/statistics_notifier.dart';

class MetronomeNotifier extends ChangeNotifier with WidgetsBindingObserver {
  final _metronome = Metronome();
  var _runtimeState = MetronomeRuntimeState();
  StatisticsNotifier? _statistics;

  void Function(int beatIndex, int noteIndex)? onPlayNote;

  final ValueNotifier<PlayPosition> playPosition = ValueNotifier(
    const PlayPosition(),
  );

  bool _isConfigPageOpen = false;

  MetronomeState get state => _metronome.state;
  MetronomeRuntimeState get runtimeState => _runtimeState;
  RhythmPattern get pattern => _metronome.state.pattern;
  int get bpm => _metronome.bpm;
  AccelerandoConfig get accelerando => _metronome.accelerando;
  bool get isRunning => _metronome.isRunning;

  int get currentBeatIndex => playPosition.value.beatIndex;
  int get currentNoteIndex => playPosition.value.noteIndex;

  MetronomeNotifier();

  void attachStatistics(StatisticsNotifier statistics) {
    _statistics = statistics;
  }

  Future<void> init() async {
    await _metronome.init();

    _metronome.onStarted = () => _statistics?.startSession(_metronome.bpm);
    _metronome.onStopped = () {
      _clearPlayPosition();
      _statistics?.endSession();
    };
    _metronome.onBpmChangedWhileRunning = (bpm) {
      _statistics?.onBpmChanged(bpm);
      notifyListeners();
    };

    _metronome.setOnPlayNote((scheduler) {
      final rt = scheduler.runtimeState;
      final next = PlayPosition(
        beatIndex: rt.currentBeatIndex,
        noteIndex: rt.currentNoteIndex,
      );
      playPosition.value = next;
      onPlayNote?.call(next.beatIndex, next.noteIndex);
    });

    attachMetronomeToAudioBackground(_metronome, onChanged: notifyListeners);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
      case AppLifecycleState.detached:
        if (!isBackgroundPlaybackEnabled && isRunning) {
          unawaited(stopPlayback());
        }
      case AppLifecycleState.resumed:
      case AppLifecycleState.inactive:
        break;
    }
  }

  void setOnPlayNoteCallback(
    void Function(int beatIndex, int noteIndex) callback,
  ) {
    onPlayNote = callback;
  }

  bool isCurrentNote(int beatIndex, int noteIndex) {
    return playPosition.value.matches(beatIndex, noteIndex);
  }

  void _clearPlayPosition() {
    playPosition.value = const PlayPosition();
  }

  void setBpm(int value) {
    _metronome.setBpm(value);
    notifyListeners();
  }

  void setAccelerando(AccelerandoConfig config) {
    _metronome.setAccelerando(config);
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

  Future<void> stopPlayback() async {
    if (!isRunning) return;

    if (isBackgroundPlaybackEnabled) {
      final handler = metronomeAudioHandler;
      if (handler != null) {
        await handler.stop();
        return;
      }
    }

    await metronomeAudioHandler?.demoteFromBackground();
    _metronome.stop();
    notifyListeners();
  }

  Future<void> _toggleRunning() async {
    if (isRunning) {
      await stopPlayback();
      return;
    }

    if (isBackgroundPlaybackEnabled) {
      final handler = metronomeAudioHandler;
      if (handler != null) {
        await handler.play();
        return;
      }
    }

    await metronomeAudioHandler?.demoteFromBackground();
    _metronome.start();
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

  void setPattern(RhythmPattern pattern) {
    _metronome.setPattern(pattern);
    notifyListeners();
  }

  bool get isConfigPageOpen => _isConfigPageOpen;

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _statistics?.endSession();
    detachMetronomeFromAudioBackground();
    playPosition.dispose();
    _metronome.dispose();
    super.dispose();
  }
}
