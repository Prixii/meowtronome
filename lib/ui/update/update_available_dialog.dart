import 'package:flutter/material.dart';
import 'package:meowtronome/core/update/update_checker.dart';
import 'package:meowtronome/global.dart';
import 'package:meowtronome/ui/components/custom_divider.dart';
import 'package:meowtronome/ui/components/modal_container.dart';
import 'package:meowtronome/ui/components/selectable_button.dart';
import 'package:meowtronome/ui/layout_helper.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateAvailableDialog extends StatelessWidget {
  const UpdateAvailableDialog({super.key, required this.update});

  final AppUpdateInfo update;

  @override
  Widget build(BuildContext context) {
    final padding = LayoutHelper.getModalContainerTitlePadding(context);
    final primary = Theme.of(context).colorScheme.primary;

    return ModalContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: padding,
            child: Text(
              '发现新版本${update.version}',
              style: titleTextStyle.copyWith(color: primary),
              textAlign: TextAlign.left,
            ),
          ),
          const CustomDivider(),
          Expanded(
            child: ScrollConfiguration(
              behavior: ScrollConfiguration.of(
                context,
              ).copyWith(scrollbars: false),
              child: SingleChildScrollView(
                padding: padding,
                child: Text(
                  update.releaseNotes,
                  style: bodyTextStyle.copyWith(color: primary),
                ),
              ),
            ),
          ),
          const CustomDivider(),
          SizedBox(
            height: 56,
            child: Row(
              children: [
                Expanded(
                  child: SelectableButton(
                    selected: false,
                    text: '关闭',
                    onTap: () => Navigator.of(context).pop(),
                  ),
                ),
                CustomDivider(
                  vertical: true,
                  color: Theme.of(context).colorScheme.primaryFixed,
                ),
                Expanded(
                  child: SelectableButton(
                    selected: true,
                    text: '跳转',
                    onTap: () async {
                      final uri = Uri.parse(update.htmlUrl);
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                      if (context.mounted) {
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
