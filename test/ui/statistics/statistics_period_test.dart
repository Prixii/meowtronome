import 'package:flutter_test/flutter_test.dart';
import 'package:meowtronome/ui/statistics/statistics_period.dart';

void main() {
  group('statistics period labels', () {
    final now = DateTime(2026, 7, 22); // Wednesday

    test('year labels', () {
      expect(labelForYear(2026, now), '今年');
      expect(labelForYear(2025, now), '去年');
      expect(labelForYear(2024, now), '2024年');
    });

    test('month labels', () {
      expect(labelForMonth(2026, 7, now), '本月');
      expect(labelForMonth(2026, 6, now), '上月');
      expect(labelForMonth(2026, 3, now), '3月');
      expect(labelForMonth(2025, 12, now), '2025-12月');
    });

    test('week labels use Monday year', () {
      // 2026-01-01 is Thursday → Monday is 2025-12-29 → belongs to 2025
      final weekOfNewYear = mondayOf(DateTime(2026, 1, 1));
      expect(weekOfNewYear.year, 2025);

      expect(labelForWeek(mondayOf(now), now), '本周');
      expect(
        labelForWeek(mondayOf(now).subtract(const Duration(days: 7)), now),
        '上周',
      );
      expect(labelForWeek(DateTime(2026, 1, 5), now), isNot(contains('-')));
      expect(labelForWeek(DateTime(2025, 12, 29), now), contains('2025-'));
    });

    test('buildPeriodOptions are newest first and cover earliest year', () {
      final years = buildPeriodOptions(
        unit: StatisticsPeriodUnit.year,
        earliestYear: 2024,
        now: now,
      );
      expect(years.first.label, '今年');
      expect(years.last.value, yearPeriodKey(2024));

      final months = buildPeriodOptions(
        unit: StatisticsPeriodUnit.month,
        earliestYear: 2025,
        now: now,
      );
      expect(months.first.label, '本月');
      expect(months.last.value, monthPeriodKey(2025, 1));

      final weeks = buildPeriodOptions(
        unit: StatisticsPeriodUnit.week,
        earliestYear: 2026,
        now: now,
      );
      expect(weeks.first.label, '本周');
      expect(weeks[1].label, '上周');
    });
  });
}
