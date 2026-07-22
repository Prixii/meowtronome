import 'dart:async';

import 'package:flutter/material.dart';
import 'package:meowtronome/ui/statistics/provider/statistics_state.dart';
import 'package:meowtronome/ui/statistics/statistics_storage.dart';

class StatisticsNotifier extends ChangeNotifier {
  StatisticsState _state = const StatisticsState();
  int _currentYear = DateTime.now().year;

  int? _activeBpm;
  int? _activeStartTimestamp;

  /// Ignore accidental taps that start/stop within this window.
  static const minRecordDurationMs = 1000;

  StatisticsState get state => _state;
  bool get hasActiveSession => _activeBpm != null;

  Future<void> init() async {
    await statisticsStorage.init();
    _currentYear = getYear();
    final current = await getYearlyStatistics(_currentYear);
    _state = _state.copyWith(currentStatistics: current);
    notifyListeners();
  }

  Future<YearlyStatistics> getYearlyStatistics(int year) {
    return statisticsStorage.loadYear(year);
  }

  Future<void> addRecord(StatisticsRecord record) async {
    if (record.endTimestamp <= record.startTimestamp) {
      return;
    }
    if (record.endTimestamp - record.startTimestamp < minRecordDurationMs) {
      return;
    }

    for (final segment in _splitByYear(record)) {
      await _appendRecord(segment);
    }
  }

  Future<void> saveCurrentStatistics() async {
    await statisticsStorage.saveYear(_currentYear, _state.currentStatistics);
  }

  void startSession(int bpm) {
    if (bpm <= 0) return;
    // Nested start: close previous segment first.
    if (_activeBpm != null) {
      endSession();
    }
    _activeBpm = bpm;
    _activeStartTimestamp = _nowMs();
  }

  void onBpmChanged(int bpm) {
    if (_activeBpm == null || bpm <= 0 || bpm == _activeBpm) {
      return;
    }
    final now = _nowMs();
    final previousBpm = _activeBpm!;
    final start = _activeStartTimestamp!;
    _activeBpm = bpm;
    _activeStartTimestamp = now;
    unawaited(
      addRecord(
        StatisticsRecord(
          bpm: previousBpm,
          startTimestamp: start,
          endTimestamp: now,
        ),
      ),
    );
  }

  void endSession() {
    final bpm = _activeBpm;
    final start = _activeStartTimestamp;
    _activeBpm = null;
    _activeStartTimestamp = null;
    if (bpm == null || start == null) {
      return;
    }
    unawaited(
      addRecord(
        StatisticsRecord(
          bpm: bpm,
          startTimestamp: start,
          endTimestamp: _nowMs(),
        ),
      ),
    );
  }

  int getYear() => DateTime.now().year;

  Future<void> _appendRecord(StatisticsRecord record) async {
    final year = DateTime.fromMillisecondsSinceEpoch(record.startTimestamp).year;

    if (year == _currentYear) {
      _state = _state.copyWith(
        currentStatistics: _state.currentStatistics.copyWith(
          records: [..._state.currentStatistics.records, record],
        ),
      );
      await saveCurrentStatistics();
      notifyListeners();
      return;
    }

    // Rare: session segment belongs to another year (e.g. New Year crossing).
    final yearly = await getYearlyStatistics(year);
    await statisticsStorage.saveYear(
      year,
      yearly.copyWith(records: [...yearly.records, record]),
    );

    // Keep in-memory "current" year in sync if the calendar year rolled over.
    final nowYear = getYear();
    if (nowYear != _currentYear) {
      _currentYear = nowYear;
      _state = _state.copyWith(
        currentStatistics: await getYearlyStatistics(_currentYear),
      );
      notifyListeners();
    }
  }

  List<StatisticsRecord> _splitByYear(StatisticsRecord record) {
    final start = DateTime.fromMillisecondsSinceEpoch(record.startTimestamp);
    final end = DateTime.fromMillisecondsSinceEpoch(record.endTimestamp);
    if (start.year == end.year) {
      return [record];
    }

    final segments = <StatisticsRecord>[];
    var segmentStart = start;
    while (segmentStart.year < end.year) {
      final yearEnd = DateTime(segmentStart.year + 1).millisecondsSinceEpoch;
      segments.add(
        StatisticsRecord(
          bpm: record.bpm,
          startTimestamp: segmentStart.millisecondsSinceEpoch,
          endTimestamp: yearEnd,
        ),
      );
      segmentStart = DateTime(segmentStart.year + 1);
    }

    segments.add(
      StatisticsRecord(
        bpm: record.bpm,
        startTimestamp: segmentStart.millisecondsSinceEpoch,
        endTimestamp: record.endTimestamp,
      ),
    );
    return segments;
  }

  int _nowMs() => DateTime.now().millisecondsSinceEpoch;

  @override
  void dispose() {
    endSession();
    super.dispose();
  }
}
