import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:meowtronome/core/enums.dart';
import 'package:meowtronome/gen/assets.gen.dart';

final soloudHelper = SoloudHelper();

class SoloudHelper {
  bool _initialized = false;
  final _soloud = SoLoud.instance;
  final _soundTypeMap = <SoundType, String>{};
  final _soloudAudioSourceMap = <String, AudioSource>{};
  SoundHandle? _whiteNoiseHandle;

  bool get isInitialized => _initialized;

  String getSoundAssetOf(SoundType type) => _soundTypeMap[type]!;

  Future<void> init() async {
    if (_initialized) return;

    await _soloud.init(sampleRate: 48000, bufferSize: 256);
    _soloud.setMaxActiveVoiceCount(16);

    for (final asset in Assets.audio.values) {
      await _loadAudioSource(asset);
    }
    _initialized = true;
  }

  void setSoundTypeMap(Map<SoundType, String> soundTypeMap) {
    _soundTypeMap
      ..clear()
      ..addAll(soundTypeMap);
  }

  Future<void> playSourceBySoundType(SoundType type) async {
    if (!_initialized) return;

    final audioAsset = _soundTypeMap[type]!;
    _soloud.play(_soloudAudioSourceMap[audioAsset]!);
  }

  Future<void> playSource(String asset) async {
    if (!_initialized) return;
    if (!_soloudAudioSourceMap.containsKey(asset)) return;
    _soloud.play(_soloudAudioSourceMap[asset]!);
  }

  /// Quiet looping white noise to keep Bluetooth audio devices awake.
  void playWhiteNoise({double volume = 0.05}) {
    if (!_initialized) return;

    final current = _whiteNoiseHandle;
    if (current != null && _soloud.getIsValidVoiceHandle(current)) {
      _soloud.setVolume(current, volume);
      return;
    }

    final source = _soloudAudioSourceMap[Assets.audio.whiteNoise];
    if (source == null) return;

    final handle = _soloud.play(source, looping: true, volume: volume);
    _soloud.setProtectVoice(handle, true);
    _whiteNoiseHandle = handle;
  }

  void setWhiteNoiseVolume(double volume) {
    final handle = _whiteNoiseHandle;
    if (!_initialized || handle == null) return;
    if (!_soloud.getIsValidVoiceHandle(handle)) return;
    _soloud.setVolume(handle, volume.clamp(0.0, 1.0));
  }

  Future<void> stopWhiteNoise() async {
    final handle = _whiteNoiseHandle;
    _whiteNoiseHandle = null;
    if (!_initialized || handle == null) return;
    if (!_soloud.getIsValidVoiceHandle(handle)) return;
    await _soloud.stop(handle);
  }

  Future<void> dispose() async {
    if (!_initialized) return;

    await stopWhiteNoise();
    await _soloud.disposeAllSources();
    _soloud.deinit();
    _soundTypeMap.clear();
    _soloudAudioSourceMap.clear();
    _initialized = false;
  }

  Future<void> _loadAudioSource(String asset) async {
    if (_soloudAudioSourceMap.containsKey(asset)) return;
    final audioSource = await _soloud.loadAsset(asset);
    _soloudAudioSourceMap[asset] = audioSource;
  }

  double getGlobalVolume() => _soloud.getGlobalVolume();
  void setGlobalVolume(double volume) => _soloud.setGlobalVolume(volume);
}
