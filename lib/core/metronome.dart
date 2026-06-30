import 'package:catrowome/core/enums.dart';
import 'package:catrowome/core/rhythm_pattern.dart';
import 'package:catrowome/core/scheduler/scheduler.dart';
import 'package:catrowome/core/scheduler/model.dart';

class Metronome {
  MetronomeState _state;
  final Scheduler _scheduler;

  Metronome() : _state = MetronomeState.initial(), _scheduler = Scheduler() {
    // Push the initial pattern to the scheduler so its queue is populated.
    _scheduler.setPattern(_state.pattern);
  }

  MetronomeState get state => _state;

  void dispose() {
    _scheduler.dispose();
  }

  // bpm
  void setBpm(int bpm) {
    _scheduler.setBpm(bpm);
  }

  int get bpm => _scheduler.bpm;

  // note management methods
  void addNoteForBeatAt(int beatIndex) {
    if (beatIndex < 0 || beatIndex >= _state.pattern.beats.length) {
      throw ArgumentError('Invalid beat index: $beatIndex');
    }

    final beat = _state.pattern.beats[beatIndex];

    final updatedBeat = beat.copyWith(notes: [...beat.notes, Note.initial()]);

    final beats = [..._state.pattern.beats];

    beats[beatIndex] = updatedBeat;

    _state = _state.copyWith(pattern: _state.pattern.copyWith(beats: beats));
    _scheduler.setPattern(_state.pattern);
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
  }

  void addNoteForAllBeats() {
    final updatedBeats = _state.pattern.beats.map((beat) {
      return beat.copyWith(notes: [...beat.notes, Note.initial()]);
    }).toList();

    _state = _state.copyWith(
      pattern: _state.pattern.copyWith(beats: updatedBeats),
    );
    _scheduler.setPattern(_state.pattern);
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
  }

  // beat management methods
  void addBeat() {
    _state = _state.copyWith(
      pattern: _state.pattern.copyWith(
        beats: [..._state.pattern.beats, Beat.initial()],
      ),
    );
    _scheduler.setPattern(_state.pattern);
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
    updatedNotes[noteIndex] = Note(soundType: soundType);

    final updatedBeat = beat.copyWith(notes: updatedNotes);
    final beats = [..._state.pattern.beats];
    beats[beatIndex] = updatedBeat;

    _state = _state.copyWith(pattern: _state.pattern.copyWith(beats: beats));
    _scheduler.setPattern(_state.pattern);
  }

  // player methods
  void start() {
    _scheduler.start();
  }

  void stop() {
    _scheduler.stop();
  }

  bool get isRunning => _scheduler.state.isRunning;

  /// Expose scheduler state for tests / debugging.
  List<List<SchedulerNote>> get noteQueue => _scheduler.state.noteQueue;
}
