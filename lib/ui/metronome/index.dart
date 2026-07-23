import 'dart:async';

import 'package:flutter/material.dart';
import 'package:meowtronome/ui/components/inline_editable_text.dart';
import 'package:meowtronome/ui/layout_helper.dart';
import 'package:meowtronome/ui/metronome/layouts/metronome_layout_horizontal.dart';
import 'package:meowtronome/ui/metronome/layouts/metronome_layout_square.dart';
import 'package:meowtronome/ui/metronome/layouts/metronome_layout_vertical.dart';
import 'package:meowtronome/ui/metronome/provider/metronome_notifier.dart';
import 'package:meowtronome/ui/update/update_check_helper.dart';
import 'package:provider/provider.dart';

class MetronomePage extends StatefulWidget {
  const MetronomePage({super.key});

  @override
  State<MetronomePage> createState() => _MetronomePageState();
}

class _MetronomePageState extends State<MetronomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(maybeCheckForUpdates(context));
    });
  }

  @override
  Widget build(BuildContext context) {
    final notifier = context.read<MetronomeNotifier>();
    final layoutMode = LayoutHelper.getLayoutMode(context);
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      body: UnfocusOnPointerOutside(
        child: SafeArea(
          child: Center(
            child: layoutMode == LayoutMode.square
                ? MetronomeLayoutSquare(notifier: notifier)
                : layoutMode == LayoutMode.vertical
                ? MetronomeLayoutVertical(notifier: notifier)
                : MetronomeLayoutHorizontal(notifier: notifier),
          ),
        ),
      ),
    );
  }
}
