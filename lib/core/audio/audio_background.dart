import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:meowtronome/core/audio/metronome_audio_handler.dart';
import 'package:meowtronome/core/metronome.dart';

MetronomeAudioHandler? metronomeAudioHandler;

bool get supportsAudioBackground =>
    !kIsWeb && (Platform.isAndroid || Platform.isIOS);

Future<void> initAudioBackground() async {
  if (!supportsAudioBackground || metronomeAudioHandler != null) return;

  metronomeAudioHandler = await AudioService.init(
    builder: MetronomeAudioHandler.new,
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.prixii.meowtronome.metronome',
      androidNotificationChannelName: 'MeowTronome',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
      androidNotificationIcon: 'mipmap/ic_launcher',
    ),
  );
}

void attachMetronomeToAudioBackground(
  Metronome metronome, {
  VoidCallback? onChanged,
}) {
  metronomeAudioHandler?.attach(metronome, onChanged: onChanged);
}

void detachMetronomeFromAudioBackground() {
  metronomeAudioHandler?.detach();
}
