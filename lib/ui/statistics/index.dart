import 'package:flutter/material.dart';
import 'package:meowtronome/global.dart';
import 'package:meowtronome/ui/components/custom_divider.dart';
import 'package:meowtronome/ui/components/custom_menu.dart';
import 'package:meowtronome/ui/components/custom_radio.dart';
import 'package:meowtronome/ui/components/modal_container.dart';
import 'package:meowtronome/ui/layout_helper.dart';
import 'package:meowtronome/ui/statistics/provider/statistics_notifier.dart';
import 'package:provider/provider.dart';

class Statistics extends StatelessWidget {
  const Statistics({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => StatisticsNotifier(),
      child: ModalContainer(child: StatisticsBody()),
    );
  }
}

class StatisticsBody extends StatelessWidget {
  const StatisticsBody({super.key});

  @override
  Widget build(BuildContext context) {
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
                options: [
                  OptionData(label: '周', value: 'week'),
                  OptionData(label: '月', value: 'month'),
                  OptionData(label: '年', value: 'year'),
                ],
                config: RadioItemConfig(
                  size: 32,
                  textStyle: bodyTextStyle.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              Expanded(child: Container()),
              CustomMenu(
                options: [
                  OptionData(label: '菜单', value: 'menu'),
                  OptionData(label: '菜单2', value: 'menu2'),
                ],
              ),
            ],
          ),
        ),
        Expanded(child: Placeholder()),
      ],
    );
  }
}
