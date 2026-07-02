import 'package:meowtronome/core/enums.dart';
import 'package:meowtronome/core/metronome.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Metronome', () {
    late Metronome metronome;

    setUp(() {
      metronome = Metronome();
    });

    tearDown(() {
      metronome.dispose();
    });

    group('constructor', () {
      test('initial state has the default pattern', () {
        final pattern = metronome.state.pattern;
        expect(pattern.name, 'Default Pattern');
        expect(pattern.beats.length, 4);
        for (final beat in pattern.beats) {
          expect(beat.notes.length, 4);
          for (final note in beat.notes) {
            expect(note.soundType, SoundType.type1);
          }
        }
      });

      test('initial BPM is 120', () {
        expect(metronome.bpm, 120);
      });

      test('initial note queue is populated from pattern', () {
        // The constructor calls setPattern, which generates the queue.
        expect(metronome.noteQueue, isNotEmpty);
        expect(metronome.noteQueue.length, 4); // 4 beats
      });
    });

    group('addNoteForBeatAt', () {
      test('adds a note to the specified beat', () {
        final initialNoteCount = metronome.state.pattern.beats[1].notes.length;

        metronome.addNoteForBeatAt(1);

        final updatedBeat = metronome.state.pattern.beats[1];
        expect(updatedBeat.notes.length, initialNoteCount + 1);
      });

      test('throws for invalid beat index', () {
        expect(() => metronome.addNoteForBeatAt(-1), throwsArgumentError);
        expect(() => metronome.addNoteForBeatAt(100), throwsArgumentError);
      });
    });

    group('removeNoteForBeatAt', () {
      test('removes a note from the specified beat', () {
        final initialNoteCount = metronome.state.pattern.beats[1].notes.length;

        metronome.removeNoteForBeatAt(1);

        final updatedBeat = metronome.state.pattern.beats[1];
        expect(updatedBeat.notes.length, initialNoteCount - 1);
      });

      test('does nothing when beat has only 1 note', () {
        // First remove notes until only 1 remains
        metronome.removeNoteForBeatAt(0);
        metronome.removeNoteForBeatAt(0);
        metronome.removeNoteForBeatAt(0);

        expect(metronome.state.pattern.beats[0].notes.length, 1);

        // This should not reduce to 0
        metronome.removeNoteForBeatAt(0);
        expect(metronome.state.pattern.beats[0].notes.length, 1);
      });

      test('throws for invalid beat index', () {
        expect(() => metronome.removeNoteForBeatAt(-1), throwsArgumentError);
        expect(() => metronome.removeNoteForBeatAt(100), throwsArgumentError);
      });
    });

    group('addNoteForAllBeats', () {
      test('adds a note to every beat', () {
        final initialCounts = metronome.state.pattern.beats
            .map((b) => b.notes.length)
            .toList();

        metronome.addNoteForAllBeats();

        for (var i = 0; i < initialCounts.length; i++) {
          expect(
            metronome.state.pattern.beats[i].notes.length,
            initialCounts[i] + 1,
          );
        }
      });
    });

    group('removeNoteForAllBeats', () {
      test('removes a note from every beat that has more than 1 note', () {
        // Add one extra note to beat 0 so it has 5
        metronome.addNoteForBeatAt(0);

        metronome.removeNoteForAllBeats();

        // Beat 0 had 5 → 4
        expect(metronome.state.pattern.beats[0].notes.length, 4);
        // Beat 1 had 4 → 3
        expect(metronome.state.pattern.beats[1].notes.length, 3);
      });

      test('does not reduce any beat below 1 note', () {
        // Remove notes until all beats have 1 note
        metronome.removeNoteForAllBeats();
        metronome.removeNoteForAllBeats();
        metronome.removeNoteForAllBeats();

        for (final beat in metronome.state.pattern.beats) {
          expect(beat.notes.length, 1);
        }

        // This should not reduce further
        metronome.removeNoteForAllBeats();

        for (final beat in metronome.state.pattern.beats) {
          expect(beat.notes.length, 1);
        }
      });
    });

    group('addBeat', () {
      test('adds a new beat with default notes', () {
        final initialCount = metronome.state.pattern.beats.length;

        metronome.addBeat();

        expect(metronome.state.pattern.beats.length, initialCount + 1);
        // New beat has the default 4 notes
        expect(metronome.state.pattern.beats.last.notes.length, 4);
      });
    });

    group('removeBeat', () {
      test('removes the last beat', () {
        final initialCount = metronome.state.pattern.beats.length;

        metronome.removeBeat();

        expect(metronome.state.pattern.beats.length, initialCount - 1);
      });

      test('does nothing when only 1 beat remains', () {
        metronome.removeBeat();
        metronome.removeBeat();
        metronome.removeBeat(); // Down to 1 beat from initial 4

        expect(metronome.state.pattern.beats.length, 1);

        metronome.removeBeat(); // Should not reduce further

        expect(metronome.state.pattern.beats.length, 1);
      });
    });

    group('setNoteSoundType', () {
      test('throws for invalid beat index', () {
        expect(
          () => metronome.setNoteSoundType(-1, 0, SoundType.type2),
          throwsArgumentError,
        );
        expect(
          () => metronome.setNoteSoundType(100, 0, SoundType.type2),
          throwsArgumentError,
        );
      });

      test('throws for invalid note index', () {
        expect(
          () => metronome.setNoteSoundType(0, -1, SoundType.type2),
          throwsArgumentError,
        );
        expect(
          () => metronome.setNoteSoundType(0, 100, SoundType.type2),
          throwsArgumentError,
        );
      });
    });

    group('BPM', () {
      test('setBpm updates the BPM value', () {
        metronome.setBpm(140);
        expect(metronome.bpm, 140);
      });

      test('setBpm throws for invalid values', () {
        expect(() => metronome.setBpm(0), throwsArgumentError);
        expect(() => metronome.setBpm(-10), throwsArgumentError);
      });
    });

    group('start / stop', () {
      test('initially is not running', () {
        expect(metronome.isRunning, isFalse);
      });

      test('start makes isRunning true', () {
        metronome.start();
        expect(metronome.isRunning, isTrue);
      });

      test('stop makes isRunning false', () {
        metronome.start();
        metronome.stop();
        expect(metronome.isRunning, isFalse);
      });
    });

    group('pattern changes propagate to scheduler queue', () {
      test('adding a note updates the scheduler queue', () {
        metronome.addNoteForBeatAt(0);
        // Queue should have been regenerated with new note count
        final beat0Notes = metronome.noteQueue[0];
        expect(beat0Notes.length, 5); // 4 initial + 1 added
      });

      test('changing note sound type updates the scheduler queue', () {
        metronome.setNoteSoundType(2, 1, SoundType.type2);
        final beatQueue = metronome.noteQueue[2];
        expect(beatQueue[1].soundType, SoundType.type2);
      });
    });
  });
}
