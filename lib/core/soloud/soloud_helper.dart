import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:meowtronome/core/enums.dart';
import 'package:meowtronome/gen/assets.gen.dart';

final soloudHelper = SoloudHelper();

class SoloudHelper {
  bool _initialized = false;
  final _soloud = SoLoud.instance;
  final _soundTypeMap = <SoundType, String>{};
  final _soloudAudioSourceMap = <String, AudioSource>{};

  Future<void> initialize() async {
    if (_initialized) return;

    await _soloud.init(sampleRate: 48000, bufferSize: 256);
    _soloud.setMaxActiveVoiceCount(16);

    for (final asset in Assets.audio.values) {
      await _loadAudioSource(asset);
    }
    _initialized = true;
  }

  void setSoundTypeMap(Map<SoundType, String> soundTypeMap) =>
      _soundTypeMap.addAll(soundTypeMap);

  Future<void> playSource(SoundType type) async {
    final audioAsset = _soundTypeMap[type]!;
    _soloud.play(_soloudAudioSourceMap[audioAsset]!);
  }

  Future<void> _loadAudioSource(String asset) async {
    if (_soloudAudioSourceMap.containsKey(asset)) return;
    await Future.wait([
      _soloud
          .loadAsset(asset)
          .then((audioSource) => _soloudAudioSourceMap[asset] = audioSource),
    ]);
  }
}
