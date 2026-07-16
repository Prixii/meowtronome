import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:meowtronome/core/metronome.dart';

class MetronomeAudioHandler extends BaseAudioHandler {
  Metronome? _metronome;
  VoidCallback? _onChanged;
  AudioSession? _session;
  StreamSubscription<void>? _becomingNoisySub;
  StreamSubscription<AudioInterruptionEvent>? _interruptionSub;
  bool _wasPlayingBeforeInterruption = false;

  MetronomeAudioHandler() {
    mediaItem.add(
      const MediaItem(
        id: 'meowtronome',
        title: 'MeowTronome',
        album: 'Metronome',
        artist: 'MeowTronome',
      ),
    );
    _setIdleState();
    unawaited(_configureSession());
  }

  void attach(Metronome metronome, {VoidCallback? onChanged}) {
    _metronome = metronome;
    _onChanged = onChanged;
  }

  void detach() {
    _metronome = null;
    _onChanged = null;
  }

  Future<void> _configureSession() async {
    final session = await AudioSession.instance;
    await session.configure(
      const AudioSessionConfiguration(
        avAudioSessionCategory: AVAudioSessionCategory.playback,
        avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.none,
        avAudioSessionMode: AVAudioSessionMode.defaultMode,
        androidAudioAttributes: AndroidAudioAttributes(
          contentType: AndroidAudioContentType.sonification,
          usage: AndroidAudioUsage.media,
        ),
        androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
        androidWillPauseWhenDucked: true,
      ),
    );
    _session = session;
    _handleInterruptions(session);
  }

  void _handleInterruptions(AudioSession session) {
    _becomingNoisySub?.cancel();
    _interruptionSub?.cancel();

    _becomingNoisySub = session.becomingNoisyEventStream.listen((_) {
      unawaited(pause());
    });

    _interruptionSub = session.interruptionEventStream.listen((event) {
      if (event.begin) {
        switch (event.type) {
          case AudioInterruptionType.duck:
            break;
          case AudioInterruptionType.pause:
          case AudioInterruptionType.unknown:
            _wasPlayingBeforeInterruption = _metronome?.isRunning ?? false;
            unawaited(pause());
        }
      } else {
        switch (event.type) {
          case AudioInterruptionType.duck:
            break;
          case AudioInterruptionType.pause:
            if (_wasPlayingBeforeInterruption) {
              unawaited(play());
            }
          case AudioInterruptionType.unknown:
            break;
        }
      }
    });
  }

  @override
  Future<void> play() async {
    final metronome = _metronome;
    if (metronome == null) return;

    await _session?.setActive(true);
    if (!metronome.isRunning) {
      metronome.start();
    }
    _setPlayingState();
    _onChanged?.call();
  }

  @override
  Future<void> pause() async {
    final metronome = _metronome;
    if (metronome == null) return;

    if (metronome.isRunning) {
      metronome.stop();
    }
    _setPausedState();
    _onChanged?.call();
  }

  @override
  Future<void> stop() async {
    final metronome = _metronome;
    if (metronome == null) return;

    if (metronome.isRunning) {
      metronome.stop();
    }
    await _session?.setActive(false);
    _setIdleState();
    _onChanged?.call();
  }

  @override
  Future<void> onTaskRemoved() async {
    await stop();
    await super.onTaskRemoved();
  }

  void _setPlayingState() {
    playbackState.add(
      playbackState.value.copyWith(
        controls: const [MediaControl.pause, MediaControl.stop],
        systemActions: const {},
        processingState: AudioProcessingState.ready,
        playing: true,
      ),
    );
  }

  void _setPausedState() {
    playbackState.add(
      playbackState.value.copyWith(
        controls: const [MediaControl.play, MediaControl.stop],
        systemActions: const {},
        processingState: AudioProcessingState.ready,
        playing: false,
      ),
    );
  }

  void _setIdleState() {
    playbackState.add(
      PlaybackState(
        controls: const [MediaControl.play],
        systemActions: const {},
        processingState: AudioProcessingState.idle,
        playing: false,
      ),
    );
  }
}
