import 'dart:async';

import 'package:flutter/material.dart';
import 'package:meowtronome/global.dart';
import 'package:meowtronome/ui/components/custom_divider.dart';
import 'package:meowtronome/ui/components/custom_menu.dart';
import 'package:meowtronome/ui/components/custom_radio.dart';
import 'package:meowtronome/ui/components/modal_container.dart';
import 'package:meowtronome/ui/layout_helper.dart';
import 'package:meowtronome/ui/statistics/components/statistics_chart.dart';
import 'package:meowtronome/ui/statistics/provider/statistics_notifier.dart';
import 'package:meowtronome/ui/statistics/statistics_period.dart';
import 'package:provider/provider.dart';

class Statistics extends StatelessWidget {
  const Statistics({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final notifier = StatisticsNotifier();
        unawaited(notifier.init());
        return notifier;
      },
      child: const ModalContainer(child: StatisticsBody()),
    );
  }
}

class StatisticsBody extends StatelessWidget {
  const StatisticsBody({super.key});

  static const _unitOptions = [
    OptionData(label: '周', value: 'week'),
    OptionData(label: '月', value: 'month'),
    OptionData(label: '年', value: 'year'),
  ];

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<StatisticsNotifier>();

    return Column(
      crossAxisAlignment: .start,
      children: [
        Padding(
          padding: LayoutHelper.getModalContainerTitlePadding(context),
          child: Text(
            '统计',
            style: titleTextStyle.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
            textAlign: .left,
          ),
        ),
        CustomDivider(),
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              CustomRadio(
                options: _unitOptions,
                initialValue: notifier.periodUnit.name,
                onSelected: (value) {
                  notifier.setPeriodUnit(_unitFromValue(value));
                },
                config: RadioItemConfig(
                  size: 32,
                  textStyle: bodyTextStyle.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              Expanded(child: Container()),
              if (notifier.periodOptions.isNotEmpty)
                CustomMenu(
                  key: ValueKey(notifier.periodUnit.name),
                  width: 140,
                  options: notifier.periodOptions,
                  initialValue: notifier.selectedPeriodKey,
                  onSelected: notifier.setSelectedPeriod,
                ),
            ],
          ),
        ),
        Expanded(
          child: notifier.chartLoading
              ? const Center(child: CircularProgressIndicator())
              : StatisticsChart(data: notifier.chartData),
        ),
      ],
    );
  }

  StatisticsPeriodUnit _unitFromValue(String value) {
    return switch (value) {
      'month' => StatisticsPeriodUnit.month,
      'year' => StatisticsPeriodUnit.year,
      _ => StatisticsPeriodUnit.week,
    };
  }
}
