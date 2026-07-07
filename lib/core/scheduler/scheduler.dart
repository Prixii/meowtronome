import 'dart:async';

import 'package:meowtronome/core/soloud/soloud_helper.dart';
import 'package:meowtronome/core/rhythm_pattern.dart';
import 'package:meowtronome/core/scheduler/model.dart';

class Scheduler {
  SchedulerState _state;
  SchedulerRuntimeState _runtimeState;
  final Stopwatch _stopwatch;
  void Function(Scheduler)? _onPlayNote;

  Timer? _timer;

  Scheduler()
    : _state = SchedulerState(),
      _runtimeState = SchedulerRuntimeState(),
      _stopwatch = Stopwatch();

  void start() {
    if (_state.pattern.beats.isEmpty) return;
    if (_state.noteQueue.isEmpty) {
      _generateNoteQueue();
    }
    _state = _state.copyWith(isRunning: true);
    _runtimeState = SchedulerRuntimeState();
    _stopwatch.start();

    _schedule();
  }

  void stop() {
    _state = _state.copyWith(isRunning: false);
    _timer?.cancel();
    _timer = null;
    _stopwatch
      ..stop()
      ..reset();
  }

  void dispose() {
    stop();
  }

  void setOnPlayNote(void Function(Scheduler) onPlayNote) {
    _onPlayNote = onPlayNote;
  }

  SchedulerState get state => _state;
  SchedulerRuntimeState get runtimeState => _runtimeState;

  void setBpm(int bpm) {
    if (bpm <= 0) {
      throw ArgumentError('BPM must be positive, got: $bpm');
    }
    if (bpm != _state.bpm) {
      _state = _state.copyWith(bpm: bpm);
      _generateNoteQueue();
      if (_state.isRunning) {
        _stopwatch
          ..reset()
          ..start();
        _runtimeState = _runtimeState.copyWith(expectedCumulativeTimeMs: 0);
      }
    }
  }

  int get bpm => _state.bpm;

  void setPattern(RhythmPattern pattern) {
    _state = _state.copyWith(pattern: pattern);
    _generateNoteQueue();
  }

  void _generateNoteQueue() {
    final bpm = _state.bpm;
    if (bpm <= 0) return;

    final beatTime = 60_000 / bpm;
    final beats = _state.pattern.beats;
    final List<List<SchedulerNote>> queue = beats.map((beat) {
      if (beat.notes.isEmpty) {
        return <SchedulerNote>[];
      }
      final noteTime = beatTime / beat.notes.length;
      return beat.notes
          .map(
            (note) =>
                SchedulerNote(soundType: note.soundType, timeValueMs: noteTime),
          )
          .toList();
    }).toList();

    _state = _state.copyWith(noteQueue: queue);
  }

  void _schedule() {
    final note = fetchNextNote();

    final expectedTime =
        _runtimeState.expectedCumulativeTimeMs + note.timeValueMs;
    final remainingTime = expectedTime - _stopwatch.elapsedMilliseconds;

    _runtimeState = _runtimeState.copyWith(
      expectedCumulativeTimeMs: expectedTime,
    );

    _timer?.cancel();

    soloudHelper.playSource(note.soundType);
    _onPlayNote?.call(this);

    _timer = Timer(Duration(milliseconds: remainingTime.toInt()), () {
      if (!_state.isRunning) {
        return;
      }
      _schedule();
    });
  }

  SchedulerNote fetchNextNote() {
    final noteQueueSnapshot = _state.noteQueue;

    if (noteQueueSnapshot.isEmpty) {
      throw StateError('Cannot fetch note from empty queue');
    }

    var beatIndex = _runtimeState.currentBeatIndex;
    var noteIndex = _runtimeState.currentNoteIndex + 1;

    // If the current beat index is out of range (e.g., after pattern change), wrap around.
    if (beatIndex >= noteQueueSnapshot.length) {
      beatIndex = 0;
      noteIndex = 0;
    }
    // If we've exhausted the notes in the current beat, move to the next beat.
    else if (noteIndex >= noteQueueSnapshot[beatIndex].length) {
      beatIndex = (beatIndex + 1) % noteQueueSnapshot.length;
      noteIndex = 0;
    }

    _runtimeState = _runtimeState.copyWith(
      currentBeatIndex: beatIndex,
      currentNoteIndex: noteIndex,
    );

    return noteQueueSnapshot[beatIndex][noteIndex];
  }
}
