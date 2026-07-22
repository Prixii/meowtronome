import 'package:meowtronome/global.dart';

enum StatisticsPeriodUnit { week, month, year }

/// Monday of the calendar week containing [date] (local date, time stripped).
DateTime mondayOf(DateTime date) {
  final day = DateTime(date.year, date.month, date.day);
  return day.subtract(Duration(days: day.weekday - DateTime.monday));
}

/// First Monday whose calendar year equals [year].
DateTime firstMondayOfYear(int year) {
  final jan1 = DateTime(year, 1, 1);
  if (jan1.weekday == DateTime.monday) {
    return jan1;
  }
  return jan1.add(Duration(days: (DateTime.monday - jan1.weekday + 7) % 7));
}

/// 1-based week index for [monday] within [monday.year].
int weekNumberOfMonday(DateTime monday) {
  final first = firstMondayOfYear(monday.year);
  return monday.difference(first).inDays ~/ 7 + 1;
}

bool isSameDate(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

String yearPeriodKey(int year) => 'year:$year';

String monthPeriodKey(int year, int month) =>
    'month:$year-${month.toString().padLeft(2, '0')}';

String weekPeriodKey(int year, int week) =>
    'week:$year-W${week.toString().padLeft(2, '0')}';

String labelForYear(int year, DateTime now) {
  if (year == now.year) return '今年';
  if (year == now.year - 1) return '去年';
  return '$year年';
}

String labelForMonth(int year, int month, DateTime now) {
  if (year == now.year && month == now.month) return '本月';
  final lastMonth = DateTime(now.year, now.month - 1);
  if (year == lastMonth.year && month == lastMonth.month) return '上月';
  if (year == now.year) return '$month月';
  return '$year-$month月';
}

String labelForWeek(DateTime monday, DateTime now) {
  final thisMonday = mondayOf(now);
  final lastMonday = thisMonday.subtract(const Duration(days: 7));
  if (isSameDate(monday, thisMonday)) return '本周';
  if (isSameDate(monday, lastMonday)) return '上周';
  final week = weekNumberOfMonday(monday);
  if (monday.year == now.year) return '$week周';
  return '${monday.year}-$week周';
}

/// Newest-first options from [earliestYear] through the current period.
List<OptionData> buildPeriodOptions({
  required StatisticsPeriodUnit unit,
  required int earliestYear,
  DateTime? now,
}) {
  final current = now ?? DateTime.now();
  final startYear = earliestYear <= current.year ? earliestYear : current.year;

  switch (unit) {
    case StatisticsPeriodUnit.year:
      return [
        for (var year = current.year; year >= startYear; year--)
          OptionData(label: labelForYear(year, current), value: yearPeriodKey(year)),
      ];
    case StatisticsPeriodUnit.month:
      return _buildMonthOptions(startYear, current);
    case StatisticsPeriodUnit.week:
      return _buildWeekOptions(startYear, current);
  }
}

List<OptionData> _buildMonthOptions(int earliestYear, DateTime now) {
  final options = <OptionData>[];
  var cursor = DateTime(now.year, now.month);
  final end = DateTime(earliestYear, 1);
  while (!cursor.isBefore(end)) {
    options.add(
      OptionData(
        label: labelForMonth(cursor.year, cursor.month, now),
        value: monthPeriodKey(cursor.year, cursor.month),
      ),
    );
    cursor = DateTime(cursor.year, cursor.month - 1);
  }
  return options;
}

List<OptionData> _buildWeekOptions(int earliestYear, DateTime now) {
  final options = <OptionData>[];
  var monday = mondayOf(now);
  final end = firstMondayOfYear(earliestYear);
  while (!monday.isBefore(end)) {
    final week = weekNumberOfMonday(monday);
    options.add(
      OptionData(
        label: labelForWeek(monday, now),
        value: weekPeriodKey(monday.year, week),
      ),
    );
    monday = monday.subtract(const Duration(days: 7));
  }
  return options;
}
