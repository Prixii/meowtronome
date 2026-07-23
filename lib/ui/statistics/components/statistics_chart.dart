import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:meowtronome/global.dart';
import 'package:meowtronome/ui/statistics/statistics_chart_data.dart';

class StatisticsChart extends StatefulWidget {
  const StatisticsChart({super.key, required this.data});

  final StatisticsChartData data;

  @override
  State<StatisticsChart> createState() => _StatisticsChartState();
}

class _StatisticsChartState extends State<StatisticsChart> {
  /// Updated synchronously in [touchCallback] for tooltip stack lookup.
  int _touchedStackIndex = -1;
  final TransformationController _transformationController =
      TransformationController();

  @override
  void didUpdateWidget(covariant StatisticsChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.data, widget.data)) {
      _touchedStackIndex = -1;
      _transformationController.value = Matrix4.identity();
    }
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    final scheme = Theme.of(context).colorScheme;

    if (data.isEmpty) {
      return Center(
        child: Text(
          '暂无练习记录',
          style: bodyTextStyle.copyWith(color: scheme.secondary),
        ),
      );
    }

    final maxY = _niceMaxY(data.maxTotalMinutes);
    final colors = _bpmColors(data.bpmsAscending, scheme);

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 20, 12),
      child: BarChart(
        BarChartData(
          maxY: maxY,
          alignment: BarChartAlignment.spaceEvenly,
          barTouchData: BarTouchData(
            handleBuiltInTouches: true,
            touchCallback: (event, response) {
              if (!event.isInterestedForInteractions ||
                  response?.spot == null) {
                _touchedStackIndex = -1;
                return;
              }
              _touchedStackIndex = response!.spot!.touchedStackItemIndex;
            },
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => scheme.primaryContainer,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final stackIndex = _touchedStackIndex;
                if (stackIndex < 0) return null;

                final bucket = data.buckets[group.x.toInt()];
                final stackBpms = _stackBpms(bucket, data.bpmsAscending);
                if (stackIndex >= stackBpms.length) return null;

                final bpm = stackBpms[stackIndex];
                final minutes =
                    (bucket.durationByBpmMs[bpm] ?? 0) / 60000.0;
                return BarTooltipItem(
                  '$bpm BPM\n${_formatMinutes(minutes)}',
                  bodyTextStyle.copyWith(color: scheme.primary, fontSize: 12),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 36,
                interval: maxY <= 4 ? 1 : maxY / 4,
                getTitlesWidget: (value, meta) {
                  if (value < 0 || value > maxY) return const SizedBox.shrink();
                  return Text(
                    _formatAxisMinutes(value),
                    style: bodyTextStyle.copyWith(
                      color: scheme.secondary,
                      fontSize: 11,
                    ),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= data.buckets.length) {
                    return const SizedBox.shrink();
                  }
                  // Avoid crowding for month charts with many days.
                  if (data.buckets.length > 16 && index % 2 != 0) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      data.buckets[index].label,
                      style: bodyTextStyle.copyWith(
                        color: scheme.secondary,
                        fontSize: 11,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: maxY <= 4 ? 1 : maxY / 4,
            getDrawingHorizontalLine: (value) => FlLine(
              color: scheme.primaryFixed.withValues(alpha: 0.7),
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border(
              left: BorderSide(color: scheme.primary, width: 1),
              bottom: BorderSide(color: scheme.primary, width: 1),
            ),
          ),
          barGroups: [
            for (var i = 0; i < data.buckets.length; i++)
              _buildGroup(
                i,
                data.buckets[i],
                data.bpmsAscending,
                colors,
                barWidth: _barWidth(data.buckets.length),
              ),
          ],
        ),
        transformationConfig: FlTransformationConfig(
          scaleAxis: FlScaleAxis.horizontal,
          minScale: 1,
          maxScale: 4,
          panEnabled: true,
          scaleEnabled: true,
          trackpadScrollCausesScale: true,
          transformationController: _transformationController,
        ),
      ),
    );
  }

  List<int> _stackBpms(
    StatisticsChartBucket bucket,
    List<int> bpmsAscending,
  ) {
    return [
      for (final bpm in bpmsAscending)
        if ((bucket.durationByBpmMs[bpm] ?? 0) > 0) bpm,
    ];
  }

  BarChartGroupData _buildGroup(
    int index,
    StatisticsChartBucket bucket,
    List<int> bpmsAscending,
    Map<int, Color> colors, {
    required double barWidth,
  }) {
    final stackItems = <BarChartRodStackItem>[];
    var fromY = 0.0;
    for (final bpm in bpmsAscending) {
      final minutes = (bucket.durationByBpmMs[bpm] ?? 0) / 60000.0;
      if (minutes <= 0) continue;
      final toY = fromY + minutes;
      stackItems.add(
        BarChartRodStackItem(fromY, toY, colors[bpm] ?? Colors.grey),
      );
      fromY = toY;
    }

    return BarChartGroupData(
      x: index,
      barRods: [
        BarChartRodData(
          toY: fromY,
          width: barWidth,
          borderRadius: BorderRadius.zero,
          rodStackItems: stackItems,
          color: stackItems.isEmpty
              ? Colors.transparent
              : stackItems.last.color,
        ),
      ],
    );
  }

  double _barWidth(int bucketCount) {
    if (bucketCount >= 28) return 12;
    if (bucketCount >= 12) return 18;
    return 28;
  }

  Map<int, Color> _bpmColors(List<int> bpmsAscending, ColorScheme scheme) {
    if (bpmsAscending.isEmpty) return {};
    if (bpmsAscending.length == 1) {
      return {bpmsAscending.first: scheme.primary};
    }
    return {
      for (var i = 0; i < bpmsAscending.length; i++)
        bpmsAscending[i]: Color.lerp(
          scheme.primaryFixed,
          scheme.primary,
          i / (bpmsAscending.length - 1),
        )!,
    };
  }

  double _niceMaxY(double maxMinutes) {
    if (maxMinutes <= 0) return 1;
    if (maxMinutes < 1) return 1;
    final padded = maxMinutes * 1.15;
    if (padded <= 5) return padded.ceilToDouble();
    if (padded <= 30) return (padded / 5).ceilToDouble() * 5;
    if (padded <= 120) return (padded / 10).ceilToDouble() * 10;
    return (padded / 30).ceilToDouble() * 30;
  }

  String _formatAxisMinutes(double minutes) {
    if (minutes < 60) return '${minutes.round()}m';
    final hours = minutes / 60;
    if (hours == hours.roundToDouble()) return '${hours.round()}h';
    return '${hours.toStringAsFixed(1)}h';
  }

  String _formatMinutes(double minutes) {
    if (minutes < 1) {
      final seconds = (minutes * 60).round();
      return '${seconds}s';
    }
    if (minutes < 60) {
      return '${minutes.toStringAsFixed(minutes < 10 ? 1 : 0)}m';
    }
    final hours = minutes ~/ 60;
    final remain = (minutes % 60).round();
    if (remain == 0) return '${hours}h';
    return '${hours}h ${remain}m';
  }
}
