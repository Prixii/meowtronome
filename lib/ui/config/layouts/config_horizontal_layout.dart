import 'package:flutter/material.dart';
import 'package:meowtronome/global.dart';
import 'package:meowtronome/ui/components/custom_divider.dart';
import 'package:meowtronome/ui/config/components/config_item.dart';
import 'package:meowtronome/ui/config/components/custom_slider.dart';
import 'package:meowtronome/ui/config/components/custom_switch.dart';
import 'package:meowtronome/ui/config/provider/config_notifier.dart';
import 'package:meowtronome/ui/layout_helper.dart';
import 'package:provider/provider.dart';

class ConfigHorizontalLayout extends StatelessWidget {
  const ConfigHorizontalLayout({super.key});

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<ConfigNotifier>();
    return Column(
      crossAxisAlignment: .start,
      children: [
        Padding(
          padding: LayoutHelper.getModalContainerTitlePadding(context),
          child: Text(
            '设置',
            style: titleTextStyle.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
            textAlign: .left,
          ),
        ),
        CustomDivider(),
        Expanded(
          child: ScrollConfiguration(
            behavior: ScrollConfiguration.of(
              context,
            ).copyWith(scrollbars: false),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: .start,
                children: [
                  ConfigItem(
                    title: '全局音量',
                    trailing: CustomSlider(
                      onChanged: (value) =>
                          notifier.setSoloudGlobalVolume(value),
                      value: notifier.soloudGlobalVolume,
                      min: 0,
                      max: 1,
                      width: LayoutHelper.getConfigSliderWidth(context),
                    ),
                    padding: LayoutHelper.getModalContainerTitlePadding(
                      context,
                    ),
                  ),
                  CustomDivider(
                    indent: 1,
                    endIndent: 1,
                    color: Theme.of(context).colorScheme.primaryFixed,
                  ),
                  ConfigItem(
                    title: '自动检查更新',
                    trailing: CustomSwitch(
                      value: notifier.autoCheckForUpdates,
                      onChanged: (value) =>
                          notifier.setAutoCheckForUpdates(value),
                    ),
                    padding: LayoutHelper.getModalContainerTitlePadding(
                      context,
                    ),
                  ),
                  CustomDivider(
                    indent: 1,
                    endIndent: 1,
                    color: Theme.of(context).colorScheme.primaryFixed,
                  ),
                  CustomDivider(),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
