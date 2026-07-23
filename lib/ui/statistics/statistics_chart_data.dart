import 'package:meowtronome/ui/statistics/provider/statistics_state.dart';
import 'package:meowtronome/ui/statistics/statistics_period.dart';

class StatisticsChartBucket {
  const StatisticsChartBucket({
    required this.label,
    required this.durationByBpmMs,
  });

  final String label;
  final Map<int, int> durationByBpmMs;

  int get totalMs =>
      durationByBpmMs.values.fold<int>(0, (sum, value) => sum + value);
}

class StatisticsChartData {
  const StatisticsChartData({
    required this.buckets,
    required this.bpmsAscending,
  });

  static const empty = StatisticsChartData(buckets: [], bpmsAscending: []);

  final List<StatisticsChartBucket> buckets;

  /// Smaller BPM first → drawn at the bottom with lighter color.
  final List<int> bpmsAscending;

  bool get isEmpty =>
      buckets.isEmpty || buckets.every((bucket) => bucket.totalMs <= 0);

  double get maxTotalMinutes {
    var maxMs = 0;
    for (final bucket in buckets) {
      if (bucket.totalMs > maxMs) maxMs = bucket.totalMs;
    }
    return maxMs / 60000.0;
  }
}

class ParsedPeriod {
  const ParsedPeriod({
    required this.unit,
    required this.rangeStart,
    required this.rangeEnd,
    required this.bucketStarts,
    required this.bucketLabels,
  });

  final StatisticsPeriodUnit unit;
  final DateTime rangeStart;
  final DateTime rangeEnd;
  final List<DateTime> bucketStarts;
  final List<String> bucketLabels;
}

ParsedPeriod? parsePeriodKey(String key, {DateTime? now}) {
  if (key.startsWith('year:')) {
    final year = int.tryParse(key.substring(5));
    if (year == null) return null;
    final start = DateTime(year, 1, 1);
    return ParsedPeriod(
      unit: StatisticsPeriodUnit.year,
      rangeStart: start,
      rangeEnd: DateTime(year + 1, 1, 1),
      bucketStarts: [for (var month = 1; month <= 12; month++) DateTime(year, month, 1)],
      bucketLabels: [for (var month = 1; month <= 12; month++) '$month月'],
    );
  }

  if (key.startsWith('month:')) {
    final parts = key.substring(6).split('-');
    if (parts.length != 2) return null;
    final year = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    if (year == null || month == null) return null;
    final start = DateTime(year, month, 1);
    final end = DateTime(year, month + 1, 1);
    final days = end.difference(start).inDays;
    return ParsedPeriod(
      unit: StatisticsPeriodUnit.month,
      rangeStart: start,
      rangeEnd: end,
      bucketStarts: [
        for (var day = 1; day <= days; day++) DateTime(year, month, day),
      ],
      bucketLabels: [for (var day = 1; day <= days; day++) '$day'],
    );
  }

  if (key.startsWith('week:')) {
    // week:2026-W03
    final match = RegExp(r'^week:(\d{4})-W(\d{2})$').firstMatch(key);
    if (match == null) return null;
    final year = int.parse(match.group(1)!);
    final week = int.parse(match.group(2)!);
    final monday = firstMondayOfYear(year).add(Duration(days: (week - 1) * 7));
    const weekdayLabels = ['一', '二', '三', '四', '五', '六', '日'];
    return ParsedPeriod(
      unit: StatisticsPeriodUnit.week,
      rangeStart: monday,
      rangeEnd: monday.add(const Duration(days: 7)),
      bucketStarts: [
        for (var i = 0; i < 7; i++) monday.add(Duration(days: i)),
      ],
      bucketLabels: weekdayLabels,
    );
  }

  return null;
}

/// Builds stacked-bar chart data. Records overlapping bucket boundaries are split.
StatisticsChartData buildStackedChartData({
  required ParsedPeriod period,
  required Iterable<StatisticsRecord> records,
}) {
  final bucketMaps = List.generate(
    period.bucketStarts.length,
    (_) => <int, int>{},
  );

  for (final record in records) {
    _accumulateRecord(record, period, bucketMaps);
  }

  final bpmSet = <int>{};
  for (final map in bucketMaps) {
    bpmSet.addAll(map.keys);
  }
  final bpms = bpmSet.toList()..sort();

  final buckets = <StatisticsChartBucket>[
    for (var i = 0; i < period.bucketStarts.length; i++)
      StatisticsChartBucket(
        label: period.bucketLabels[i],
        durationByBpmMs: Map<int, int>.unmodifiable(bucketMaps[i]),
      ),
  ];

  return StatisticsChartData(buckets: buckets, bpmsAscending: bpms);
}

void _accumulateRecord(
  StatisticsRecord record,
  ParsedPeriod period,
  List<Map<int, int>> bucketMaps,
) {
  var cursor = DateTime.fromMillisecondsSinceEpoch(record.startTimestamp);
  final end = DateTime.fromMillisecondsSinceEpoch(record.endTimestamp);
  if (!end.isAfter(cursor)) return;

  // Clip to selected period.
  if (cursor.isBefore(period.rangeStart)) {
    cursor = period.rangeStart;
  }
  final clippedEnd = end.isAfter(period.rangeEnd) ? period.rangeEnd : end;
  if (!clippedEnd.isAfter(cursor)) return;

  while (cursor.isBefore(clippedEnd)) {
    final bucketIndex = _bucketIndexFor(cursor, period);
    if (bucketIndex < 0) {
      cursor = _nextBucketStart(cursor, period);
      continue;
    }

    final bucketEnd = bucketIndex + 1 < period.bucketStarts.length
        ? period.bucketStarts[bucketIndex + 1]
        : period.rangeEnd;
    final segmentEnd = clippedEnd.isBefore(bucketEnd) ? clippedEnd : bucketEnd;
    final durationMs = segmentEnd.difference(cursor).inMilliseconds;
    if (durationMs > 0) {
      final map = bucketMaps[bucketIndex];
      map[record.bpm] = (map[record.bpm] ?? 0) + durationMs;
    }
    cursor = segmentEnd;
  }
}

int _bucketIndexFor(DateTime instant, ParsedPeriod period) {
  switch (period.unit) {
    case StatisticsPeriodUnit.year:
      if (instant.year != period.rangeStart.year) return -1;
      return instant.month - 1;
    case StatisticsPeriodUnit.month:
      if (instant.year != period.rangeStart.year ||
          instant.month != period.rangeStart.month) {
        return -1;
      }
      return instant.day - 1;
    case StatisticsPeriodUnit.week:
      final day = DateTime(instant.year, instant.month, instant.day);
      final index = day.difference(period.rangeStart).inDays;
      if (index < 0 || index >= period.bucketStarts.length) return -1;
      return index;
  }
}

DateTime _nextBucketStart(DateTime instant, ParsedPeriod period) {
  switch (period.unit) {
    case StatisticsPeriodUnit.year:
      return DateTime(instant.year, instant.month + 1, 1);
    case StatisticsPeriodUnit.month:
      return DateTime(instant.year, instant.month, instant.day + 1);
    case StatisticsPeriodUnit.week:
      return DateTime(
        instant.year,
        instant.month,
        instant.day,
      ).add(const Duration(days: 1));
  }
}

Set<int> yearsTouchedByPeriod(ParsedPeriod period) {
  final years = <int>{period.rangeStart.year};
  final last = period.rangeEnd.subtract(const Duration(milliseconds: 1));
  years.add(last.year);
  return years;
}
