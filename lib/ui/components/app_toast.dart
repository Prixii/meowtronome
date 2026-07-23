import 'package:flutter/material.dart';
import 'package:meowtronome/global.dart';

class AppToast {
  AppToast._();

  static void show(BuildContext context, String message) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: bodyTextStyle.copyWith(
              color: Theme.of(context).colorScheme.primaryContainer,
            ),
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
  }
}
