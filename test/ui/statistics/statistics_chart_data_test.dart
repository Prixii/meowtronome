import 'package:flutter_test/flutter_test.dart';
import 'package:meowtronome/ui/statistics/provider/statistics_state.dart';
import 'package:meowtronome/ui/statistics/statistics_chart_data.dart';
import 'package:meowtronome/ui/statistics/statistics_period.dart';

void main() {
  group('buildStackedChartData', () {
    test('stacks bpm durations by month for a year period', () {
      final period = parsePeriodKey('year:2026')!;
      final start = DateTime(2026, 3, 10, 10).millisecondsSinceEpoch;
      final records = [
        StatisticsRecord(
          bpm: 100,
          startTimestamp: start,
          endTimestamp: start + 10 * 60000,
        ),
        StatisticsRecord(
          bpm: 120,
          startTimestamp: start + 10 * 60000,
          endTimestamp: start + 25 * 60000,
        ),
      ];

      final chart = buildStackedChartData(period: period, records: records);
      expect(chart.bpmsAscending, [100, 120]);
      expect(chart.buckets[2].label, '3月');
      expect(chart.buckets[2].durationByBpmMs[100], 10 * 60000);
      expect(chart.buckets[2].durationByBpmMs[120], 15 * 60000);
    });

    test('splits a record across day buckets in a week', () {
      final monday = DateTime(2026, 7, 20);
      final key = weekPeriodKey(monday.year, weekNumberOfMonday(monday));
      final period = parsePeriodKey(key)!;
      expect(period.rangeStart, monday);

      final start = DateTime(2026, 7, 21, 23, 50).millisecondsSinceEpoch;
      final end = DateTime(2026, 7, 22, 0, 10).millisecondsSinceEpoch;
      final chart = buildStackedChartData(
        period: period,
        records: [
          StatisticsRecord(bpm: 90, startTimestamp: start, endTimestamp: end),
        ],
      );

      expect(chart.buckets[1].durationByBpmMs[90], 10 * 60000); // Tue
      expect(chart.buckets[2].durationByBpmMs[90], 10 * 60000); // Wed
    });
  });
}
