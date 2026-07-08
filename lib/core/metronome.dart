import 'dart:convert';

import 'package:meowtronome/core/enums.dart';
import 'package:meowtronome/core/rhythm_pattern.dart';
import 'package:meowtronome/core/scheduler/scheduler.dart';
import 'package:meowtronome/core/scheduler/model.dart';
import 'package:meowtronome/core/soloud/soloud_helper.dart';
import 'package:meowtronome/global.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Metronome {
  MetronomeState _state;
  final Scheduler _scheduler;
  late final SharedPreferences prefs;

  Metronome() : _state = MetronomeState(), _scheduler = Scheduler();

  Future<void> init() async {
    prefs = await SharedPreferences.getInstance();

    final metronomeState = prefs.getString('metronomeState');
    if (metronomeState != null) {
      _state = MetronomeState.fromJson(jsonDecode(metronomeState));
    }

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
    _state = _state.copyWith(bpm: bpm);
    _scheduler.setBpm(bpm);
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
    _scheduler.start();
  }

  void stop() {
    _scheduler.stop();
  }

  void saveState() {
    prefs.setString('metronomeState', jsonEncode(_state.toJson()));
  }

  MetronomeState get state => _state;
  int get bpm => _state.bpm;

  bool get isRunning => _scheduler.state.isRunning;

  /// Expose scheduler state for tests / debugging.
  List<List<SchedulerNote>> get noteQueue => _scheduler.state.noteQueue;
}
