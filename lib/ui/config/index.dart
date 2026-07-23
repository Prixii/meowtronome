import 'package:flutter/material.dart';
import 'package:meowtronome/global.dart';
import 'package:meowtronome/ui/components/custom_divider.dart';
import 'package:meowtronome/ui/components/modal_container.dart';
import 'package:meowtronome/ui/config/components/config_item.dart';
import 'package:meowtronome/ui/config/components/custom_slider.dart';
import 'package:meowtronome/ui/config/components/custom_switch.dart';
import 'package:meowtronome/ui/config/provider/config_notifier.dart';
import 'package:meowtronome/ui/layout_helper.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ConfigPage extends StatelessWidget {
  const ConfigPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ModalContainer(child: ConfigBody());
  }
}

class ConfigBody extends StatelessWidget {
  const ConfigBody({super.key});

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
                  _buildDivider(context),
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
                  _buildDivider(context),
                  _buildRepoLink(context),
                  _buildDivider(context),
                  VersionLabel(),
                  CustomDivider(),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDivider(BuildContext context) => CustomDivider(
    indent: 1,
    endIndent: 1,
    color: Theme.of(context).colorScheme.primaryFixed,
  );

  Widget _buildRepoLink(BuildContext context) => MouseRegion(
    cursor: SystemMouseCursors.click,
    child: GestureDetector(
      onTap: () => launchUrl(Uri.parse(repoUrl)),
      child: ConfigItem(
        title: 'Github仓库',
        trailing: Icon(
          Icons.arrow_forward,
          color: Theme.of(context).colorScheme.primary,
        ),
        padding: LayoutHelper.getModalContainerTitlePadding(context),
      ),
    ),
  );
}

class VersionLabel extends StatefulWidget {
  const VersionLabel({super.key});

  @override
  State<VersionLabel> createState() => _VersionLabelState();
}

class _VersionLabelState extends State<VersionLabel> {
  var version = '1.0.0';
  @override
  void initState() {
    super.initState();

    PackageInfo.fromPlatform().then(
      (info) => setState(() => version = info.version),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ConfigItem(
      title: '当前版本',
      trailing: Text(
        version,
        style: bodyTextStyle.copyWith(
          color: Theme.of(context).colorScheme.primaryFixedDim,
        ),
      ),
      padding: LayoutHelper.getModalContainerTitlePadding(context),
    );
  }
}
