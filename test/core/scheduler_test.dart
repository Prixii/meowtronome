import 'package:catrowome/core/enums.dart';
import 'package:catrowome/core/rhythm_pattern.dart';
import 'package:catrowome/core/scheduler/model.dart';
import 'package:catrowome/core/scheduler/scheduler.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SchedulerNote', () {
    test('initial() creates a SchedulerNote with defaults', () {
      final note = SchedulerNote.initial();
      expect(note.soundType, SoundType.type1);
      expect(note.timeValueMs, 1000);
    });

    test('copyWith replaces fields', () {
      final note = SchedulerNote.initial();
      final updated = note.copyWith(
        soundType: SoundType.type2,
        timeValueMs: 500,
      );
      expect(updated.soundType, SoundType.type2);
      expect(updated.timeValueMs, 500);
    });

    test('equality works', () {
      expect(
        SchedulerNote(soundType: SoundType.type1, timeValueMs: 500),
        SchedulerNote(soundType: SoundType.type1, timeValueMs: 500),
      );
      expect(
        SchedulerNote(soundType: SoundType.type1, timeValueMs: 500),
        isNot(SchedulerNote(soundType: SoundType.type2, timeValueMs: 500)),
      );
    });
  });

  group('SchedulerState', () {
    test('initial() has empty noteQueue, bpm=120, not running', () {
      final state = SchedulerState.initial();
      expect(state.bpm, 120);
      expect(state.isRunning, false);
      expect(state.noteQueue, isEmpty);
      expect(state.pattern, RhythmPattern.initial());
    });
  });

  group('SchedulerRuntimeState', () {
    test('initial() has beatIndex 0, noteIndex -1, cumulativeTime 0', () {
      final state = SchedulerRuntimeState.initial();
      expect(state.currentBeatIndex, 0);
      expect(state.currentNoteIndex, -1);
      expect(state.expectedCumulativeTimeMs, 0);
    });
  });

  group('Scheduler note queue generation', () {
    late Scheduler scheduler;

    setUp(() {
      scheduler = Scheduler();
    });

    tearDown(() {
      scheduler.dispose();
    });

    test('initial pattern produces correct queue after setPattern', () {
      // By default the scheduler is constructed with an empty queue.
      // The pattern needs to be set explicitly (like Metronome does).
      scheduler.setPattern(RhythmPattern.initial());

      final queue = scheduler.state.noteQueue;
      // 4 beats, each with 4 notes
      expect(queue.length, 4);
      for (final beat in queue) {
        expect(beat.length, 4);
      }
    });

    test('queue notes have correct time values at 120 BPM', () {
      // 120 BPM → 500ms per beat → 4 notes per beat → 125ms per note
      scheduler.setPattern(RhythmPattern.initial());

      final queue = scheduler.state.noteQueue;
      for (final beat in queue) {
        for (final note in beat) {
          expect(note.timeValueMs, closeTo(125, 0.001));
        }
      }
    });

    test('queue notes have correct time values at 60 BPM', () {
      // 60 BPM → 1000ms per beat → 4 notes per beat → 250ms per note
      scheduler.setBpm(60);
      scheduler.setPattern(RhythmPattern.initial());

      final queue = scheduler.state.noteQueue;
      for (final beat in queue) {
        for (final note in beat) {
          expect(note.timeValueMs, closeTo(250, 0.001));
        }
      }
    });

    test(
      'queue note time values adapt when beat has different note counts',
      () {
        // 120 BPM → 500ms per beat
        // beat 0: 4 notes → 125ms each
        // beat 1: 2 notes → 250ms each
        scheduler.setBpm(120);
        scheduler.setPattern(
          RhythmPattern(
            name: 'test',
            beats: [
              Beat(
                notes: List.generate(
                  4,
                  (_) => const Note(soundType: SoundType.type1),
                ),
              ),
              Beat(
                notes: List.generate(
                  2,
                  (_) => const Note(soundType: SoundType.type2),
                ),
              ),
            ],
          ),
        );

        final queue = scheduler.state.noteQueue;
        expect(queue[0][0].timeValueMs, closeTo(125, 0.001));
        expect(queue[1][0].timeValueMs, closeTo(250, 0.001));
      },
    );

    test('regenerating queue after BPM change uses new BPM', () {
      scheduler.setPattern(RhythmPattern.initial());
      scheduler.setBpm(60);

      final queue = scheduler.state.noteQueue;
      for (final beat in queue) {
        for (final note in beat) {
          expect(note.timeValueMs, closeTo(250, 0.001)); // 60 BPM
        }
      }
    });
  });

  group('fetchNextNote', () {
    late Scheduler scheduler;

    setUp(() {
      scheduler = Scheduler();
      // A simple 2-beat pattern, each with 2 notes
      scheduler.setPattern(
        RhythmPattern(
          name: 'test',
          beats: [
            Beat(
              notes: [
                const Note(soundType: SoundType.type1),
                const Note(soundType: SoundType.type2),
              ],
            ),
            Beat(
              notes: [
                const Note(soundType: SoundType.type3),
                const Note(soundType: SoundType.none),
              ],
            ),
          ],
        ),
      );
    });

    tearDown(() {
      scheduler.dispose();
    });

    test('returns notes in order across beats', () {
      expect(scheduler.runtimeState.currentBeatIndex, 0);
      expect(scheduler.runtimeState.currentNoteIndex, -1);

      // Beat 0, note 0
      final note1 = scheduler.fetchNextNote();
      expect(note1.soundType, SoundType.type1);
      expect(scheduler.runtimeState.currentBeatIndex, 0);
      expect(scheduler.runtimeState.currentNoteIndex, 0);

      // Beat 0, note 1
      final note2 = scheduler.fetchNextNote();
      expect(note2.soundType, SoundType.type2);
      expect(scheduler.runtimeState.currentBeatIndex, 0);
      expect(scheduler.runtimeState.currentNoteIndex, 1);

      // Beat 1, note 0 (note index wrapped)
      final note3 = scheduler.fetchNextNote();
      expect(note3.soundType, SoundType.type3);
      expect(scheduler.runtimeState.currentBeatIndex, 1);
      expect(scheduler.runtimeState.currentNoteIndex, 0);

      // Beat 1, note 1
      final note4 = scheduler.fetchNextNote();
      expect(note4.soundType, SoundType.none);
      expect(scheduler.runtimeState.currentBeatIndex, 1);
      expect(scheduler.runtimeState.currentNoteIndex, 1);

      // Beat 0, note 0 (beat wrapped, back to start)
      final note5 = scheduler.fetchNextNote();
      expect(note5.soundType, SoundType.type1);
      expect(scheduler.runtimeState.currentBeatIndex, 0);
      expect(scheduler.runtimeState.currentNoteIndex, 0);
    });

    test('throws StateError when queue is empty', () {
      final emptyScheduler = Scheduler();
      // No pattern set → empty queue
      expect(() => emptyScheduler.fetchNextNote(), throwsStateError);
      emptyScheduler.dispose();
    });
  });

  group('start / stop', () {
    test('start does nothing when pattern has no beats', () {
      final scheduler = Scheduler();
      scheduler.setPattern(RhythmPattern(name: 'empty', beats: []));

      // Should not crash
      scheduler.start();
      expect(scheduler.state.isRunning, isFalse);
      scheduler.dispose();
    });

    test('start and stop transition state correctly', () {
      final scheduler = Scheduler();
      scheduler.setPattern(RhythmPattern.initial());

      scheduler.start();
      expect(scheduler.state.isRunning, isTrue);

      scheduler.stop();
      expect(scheduler.state.isRunning, isFalse);
      scheduler.dispose();
    });
  });

  group('BPM validation', () {
    test('setting BPM to 0 or negative throws', () {
      final scheduler = Scheduler();
      expect(() => scheduler.setBpm(0), throwsArgumentError);
      expect(() => scheduler.setBpm(-10), throwsArgumentError);
      scheduler.dispose();
    });

    test('setting BPM to a valid value updates it', () {
      final scheduler = Scheduler();
      scheduler.setBpm(140);
      expect(scheduler.bpm, 140);
      scheduler.dispose();
    });
  });

  group('pattern change during playback', () {
    test('setPattern resets runtime state when running', () {
      final scheduler = Scheduler();
      scheduler.setPattern(RhythmPattern.initial());

      // Advance to beat 1
      scheduler.fetchNextNote();
      scheduler.fetchNextNote();
      scheduler.fetchNextNote();
      scheduler.fetchNextNote();
      scheduler.fetchNextNote();
      expect(scheduler.runtimeState.currentBeatIndex, 1);
      expect(scheduler.runtimeState.currentNoteIndex, 0);

      // Simulate running state
      scheduler.start(); // This sets isRunning = true
      // Change pattern (smaller)
      scheduler.setPattern(
        RhythmPattern(
          name: 'small',
          beats: [
            Beat(notes: [const Note(soundType: SoundType.type1)]),
          ],
        ),
      );

      // Runtime state should be reset
      expect(scheduler.runtimeState.currentBeatIndex, 0);
      expect(scheduler.runtimeState.currentNoteIndex, -1);
      scheduler.dispose();
    });
  });
}
