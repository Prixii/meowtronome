import 'package:flutter/material.dart';
import 'package:meowtronome/core/update/update_checker.dart';
import 'package:meowtronome/ui/components/app_toast.dart';
import 'package:meowtronome/ui/config/provider/config_notifier.dart';
import 'package:meowtronome/ui/update/update_available_dialog.dart';
import 'package:provider/provider.dart';

Future<void> maybeCheckForUpdates(BuildContext context) async {
  if (!context.read<ConfigNotifier>().autoCheckForUpdates) {
    return;
  }

  try {
    final update = await UpdateChecker().checkForUpdate();
    if (!context.mounted || update == null) return;

    await showDialog<void>(
      context: context,
      builder: (_) => UpdateAvailableDialog(update: update),
    );
  } catch (_) {
    if (!context.mounted) return;
    AppToast.show(context, '版本检查失败');
  }
}
