import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:meowtronome/ui/statistics/provider/statistics_notifier.dart';
import 'package:meowtronome/ui/statistics/provider/statistics_state.dart';
import 'package:meowtronome/ui/statistics/statistics_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late StatisticsNotifier notifier;

  setUp(() async {
    statisticsStorage.resetForTest();
    tempDir = await Directory.systemTemp.createTemp('meowtronome_stats_');
    await statisticsStorage.init(directory: tempDir);
    notifier = StatisticsNotifier();
    await notifier.init();
  });

  tearDown(() async {
    notifier.dispose();
    statisticsStorage.resetForTest();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('saves records to the year file', () async {
    final year = DateTime.now().year;
    final start = DateTime(year, 3, 1, 10).millisecondsSinceEpoch;
    final end = start + 5000;

    await notifier.addRecord(
      StatisticsRecord(bpm: 120, startTimestamp: start, endTimestamp: end),
    );

    final file = File('${tempDir.path}${Platform.pathSeparator}$year.json');
    expect(await file.exists(), isTrue);

    final loaded = await statisticsStorage.loadYear(year);
    expect(loaded.records, hasLength(1));
    expect(loaded.records.single.bpm, 120);
    expect(loaded.records.single.startTimestamp, start);
    expect(loaded.records.single.endTimestamp, end);
  });

  test('ignores records shorter than one second', () async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await notifier.addRecord(
      StatisticsRecord(
        bpm: 100,
        startTimestamp: now,
        endTimestamp: now + 500,
      ),
    );

    expect(notifier.state.currentStatistics.records, isEmpty);
  });

  test('splits a session across bpm changes', () async {
    notifier.startSession(100);
    await Future<void>.delayed(const Duration(milliseconds: 1100));
    notifier.onBpmChanged(120);
    await Future<void>.delayed(const Duration(milliseconds: 1100));
    notifier.endSession();

    // Allow async persistence to settle.
    await Future<void>.delayed(const Duration(milliseconds: 50));

    final records = notifier.state.currentStatistics.records;
    expect(records.length, greaterThanOrEqualTo(2));
    expect(records.first.bpm, 100);
    expect(records.last.bpm, 120);
  });

  test('splits a record that crosses the year boundary', () async {
    final start = DateTime(2025, 12, 31, 23, 50).millisecondsSinceEpoch;
    final end = DateTime(2026, 1, 1, 0, 10).millisecondsSinceEpoch;

    await notifier.addRecord(
      StatisticsRecord(bpm: 90, startTimestamp: start, endTimestamp: end),
    );

    final stats2025 = await statisticsStorage.loadYear(2025);
    final stats2026 = await statisticsStorage.loadYear(2026);

    expect(stats2025.records, hasLength(1));
    expect(stats2026.records, hasLength(1));
    expect(stats2025.records.single.endTimestamp, DateTime(2026).millisecondsSinceEpoch);
    expect(stats2026.records.single.startTimestamp, DateTime(2026).millisecondsSinceEpoch);
  });
}
