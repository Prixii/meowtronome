import 'package:flutter/material.dart';
import 'package:meowtronome/ui/components/modal_container.dart';
import 'package:meowtronome/ui/config/layouts/config_horizontal_layout.dart';
import 'package:meowtronome/ui/config/provider/config_notifier.dart';
import 'package:provider/provider.dart';

class ConfigPage extends StatelessWidget {
  const ConfigPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ConfigNotifier(),
      child: ModalContainer(child: const ConfigHorizontalLayout()),
    );
  }
}
