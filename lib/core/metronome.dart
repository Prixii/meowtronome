import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:meowtronome/core/accelerando.dart';
import 'package:meowtronome/core/enums.dart';
import 'package:meowtronome/core/rhythm_pattern.dart';
import 'package:meowtronome/core/scheduler/scheduler.dart';
import 'package:meowtronome/core/scheduler/model.dart';
import 'package:meowtronome/core/soloud/soloud_helper.dart';
import 'package:meowtronome/gen/assets.gen.dart';
import 'package:meowtronome/global.dart';
import 'package:meowtronome/ui/shared_preferences_helper.dart';

class Metronome {
  MetronomeState _state;
  final Scheduler _scheduler;
  int _barsSinceLastStep = 0;

  Metronome() : _state = MetronomeState(), _scheduler = Scheduler() {
    _scheduler.setOnBarCompleted(_onBarCompleted);
    _scheduler.setPattern(_state.pattern);
    _scheduler.setBpm(_state.bpm);
  }

  Future<void> init() async {
    final json = sharedPreferencesHelper.getJsonAndDecode<Map<String, dynamic>>(
      .metronomeState,
    );
    _state = json == null ? MetronomeState() : MetronomeState.fromJson(json);

    if (_state.soundTypeMap.isEmpty) {
      _state = _state.copyWith(soundTypeMap: defaultSoundMap);
    }

    _scheduler.setPattern(_state.pattern);
    _scheduler.setBpm(_state.bpm);
    soloudHelper.setSoundTypeMap(_state.soundTypeMap);

    saveState();
  }

  void dispose() {
    _scheduler.dispose();
  }

  void setPattern(RhythmPattern pattern) {
    _state = _state.copyWith(pattern: pattern);
    _scheduler.setPattern(_state.pattern);
    saveState();
  }

  void setOnPlayNote(void Function(Scheduler) onPlayNote) {
    _scheduler.setOnPlayNote(onPlayNote);
  }

  // bpm
  void setBpm(int bpm) {
    if (bpm <= 0) {
      throw ArgumentError('BPM must be positive, got: $bpm');
    }
    _state = _state.copyWith(bpm: bpm);
    _scheduler.setBpm(bpm);
    saveState();
  }

  void setAccelerando(AccelerandoConfig config) {
    _state = _state.copyWith(accelerando: _normalizeAccelerando(config));
    saveState();
  }

  // note management methods
  void addNoteForBeatAt(int beatIndex) {
    if (beatIndex < 0 || beatIndex >= _state.pattern.beats.length) {
      throw ArgumentError('Invalid beat index: $beatIndex');
    }

    final beat = _state.pattern.beats[beatIndex];
    final newNote = beat.notes.last;
    final updatedBeat = beat.copyWith(notes: [...beat.notes, newNote]);

    final beats = [..._state.pattern.beats];

    beats[beatIndex] = updatedBeat;

    _state = _state.copyWith(pattern: _state.pattern.copyWith(beats: beats));
    _scheduler.setPattern(_state.pattern);
    saveState();
  }

  void removeNoteForBeatAt(int beatIndex) {
    if (beatIndex < 0 || beatIndex >= _state.pattern.beats.length) {
      throw ArgumentError('Invalid beat index: $beatIndex');
    }

    final beat = _state.pattern.beats[beatIndex];

    if (beat.notes.length < 2) {
      return;
    }

    final updatedBeat = beat.copyWith(
      notes: [...beat.notes.sublist(0, beat.notes.length - 1)],
    );

    final beats = [..._state.pattern.beats];

    beats[beatIndex] = updatedBeat;

    _state = _state.copyWith(pattern: _state.pattern.copyWith(beats: beats));
    _scheduler.setPattern(_state.pattern);
    saveState();
  }

  void addNoteForAllBeats() {
    final updatedBeats = _state.pattern.beats.map((beat) {
      return beat.copyWith(notes: [...beat.notes, Note()]);
    }).toList();

    _state = _state.copyWith(
      pattern: _state.pattern.copyWith(beats: updatedBeats),
    );
    _scheduler.setPattern(_state.pattern);
    saveState();
  }

  void removeNoteForAllBeats() {
    final updatedBeats = _state.pattern.beats.map((beat) {
      if (beat.notes.length < 2) {
        return beat; // Skip removing note if there's only one note left
      }

      return beat.copyWith(
        notes: [...beat.notes.sublist(0, beat.notes.length - 1)],
      );
    }).toList();

    _state = _state.copyWith(
      pattern: _state.pattern.copyWith(beats: updatedBeats),
    );
    _scheduler.setPattern(_state.pattern);
    saveState();
  }

  // beat management methods
  void addBeat() {
    final newBeat = _state.pattern.beats.last;
    _state = _state.copyWith(
      pattern: _state.pattern.copyWith(
        beats: [..._state.pattern.beats, newBeat],
      ),
    );
    _scheduler.setPattern(_state.pattern);
    saveState();
  }

  void removeBeat() {
    if (_state.pattern.beats.length < 2) {
      return;
    }

    _state = _state.copyWith(
      pattern: _state.pattern.copyWith(
        beats: [
          ..._state.pattern.beats.sublist(0, _state.pattern.beats.length - 1),
        ],
      ),
    );
    _scheduler.setPattern(_state.pattern);
    saveState();
  }

  // note sound type modification
  void setNoteSoundType(int beatIndex, int noteIndex, SoundType soundType) {
    if (beatIndex < 0 || beatIndex >= _state.pattern.beats.length) {
      throw ArgumentError('Invalid beat index: $beatIndex');
    }
    final beat = _state.pattern.beats[beatIndex];
    if (noteIndex < 0 || noteIndex >= beat.notes.length) {
      throw ArgumentError('Invalid note index: $noteIndex');
    }

    final updatedNotes = [...beat.notes];
    updatedNotes[noteIndex] = beat.notes[noteIndex].copyWith(
      soundType: soundType,
    );

    final updatedBeat = beat.copyWith(notes: updatedNotes);
    final beats = [..._state.pattern.beats];
    beats[beatIndex] = updatedBeat;

    _state = _state.copyWith(pattern: _state.pattern.copyWith(beats: beats));
    _scheduler.setPattern(_state.pattern);

    saveState();
  }

  // player methods
  void start() {
    _prepareStart();
    _scheduler.start();
  }

  void _prepareStart() {
    _barsSinceLastStep = 0;
    if (_state.accelerando.enabled) {
      final startBpm = _state.accelerando.startBpm;
      _state = _state.copyWith(bpm: startBpm);
      _scheduler.setBpm(startBpm);
    }
  }

  void stop() {
    final shouldPersist = _state.accelerando.enabled;
    _scheduler.stop();
    _barsSinceLastStep = 0;
    if (shouldPersist) {
      saveState();
    }
  }

  void setToneForSoundType(SoundType soundType, String tone) {
    if (Assets.audio.values.contains(tone)) {
      _state = _state.copyWith(
        soundTypeMap: {..._state.soundTypeMap, soundType: tone},
      );
      soloudHelper.setSoundTypeMap(_state.soundTypeMap);
      saveState();
    }
  }

  void saveState() {
    sharedPreferencesHelper.setString(
      .metronomeState,
      jsonEncode(_state.toJson()),
    );
  }

  void _onBarCompleted() {
    final config = _state.accelerando;
    if (!config.enabled) {
      return;
    }

    _barsSinceLastStep++;
    if (_barsSinceLastStep < config.barsPerStep) {
      return;
    }
    _barsSinceLastStep = 0;

    final next = nextAccelerandoBpm(_state.bpm, config);
    if (next == _state.bpm) {
      return;
    }

    _state = _state.copyWith(bpm: next);
    _scheduler.setBpm(next);
  }

  static AccelerandoConfig _normalizeAccelerando(AccelerandoConfig config) {
    return config.copyWith(
      startBpm: max(1, config.startBpm),
      endBpm: max(1, config.endBpm),
      barsPerStep: max(1, config.barsPerStep),
      bpmStep: max(1, config.bpmStep),
    );
  }

  /// Moves [current] toward [config.endBpm] by [config.bpmStep].
  static int nextAccelerandoBpm(int current, AccelerandoConfig config) {
    if (config.startBpm <= config.endBpm) {
      if (current >= config.endBpm) return config.endBpm;
      return min(current + config.bpmStep, config.endBpm);
    }
    if (current <= config.endBpm) return config.endBpm;
    return max(current - config.bpmStep, config.endBpm);
  }

  MetronomeState get state => _state;
  int get bpm => _state.bpm;
  AccelerandoConfig get accelerando => _state.accelerando;

  bool get isRunning => _scheduler.state.isRunning;

  /// Expose scheduler state for tests / debugging.
  List<List<SchedulerNote>> get noteQueue => _scheduler.state.noteQueue;

  @visibleForTesting
  void handleBarCompletedForTest() => _onBarCompleted();

  @visibleForTesting
  void prepareStartForTest() => _prepareStart();
}
