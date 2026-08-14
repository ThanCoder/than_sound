import 'dart:async';

import 'package:cfb_store/cfb_store.dart';
import 'package:mpv_audio_kit/mpv_audio_kit.dart';
import 'package:than_sound/const_keys.dart';
import 'package:than_sound/core/controllers/player/amplitude/amplitude_type.dart';

mixin AmplitudeMixin {
  PlayerStream get stream;

  ///
  /// Use for:
  /// - waveform
  /// - VU meter
  /// - oscilloscope
  final _amplitudeController = StreamController<double>.broadcast();

  Stream<double> get amplitude => _amplitudeController.stream;
  // ===========================================================================
  // TIMERS
  // ===========================================================================

  // ===========================================================================
  // SUBSCRIPTIONS
  // ===========================================================================

  StreamSubscription? _configStoreSub;
  StreamSubscription? _pcmSub;

  CFBStore get configStore => CFBStore.getInstance;

  // ===========================================================================
  // INITIALIZATION
  // ===========================================================================

  void onListenAmplitude() {
    _configStoreSub?.cancel();

    _configStoreSub = configStore.events.listen((event) {
      if (event is! PutValue) return;

      if (event.key != audioAmplitudeAnimationTypeKey) {
        return;
      }

      _onListenAmplitude();
    });

    _onListenAmplitude();
  }

  // ===========================================================================
  // CONFIGURE
  // ===========================================================================

  void _onListenAmplitude() {
    final type = AmplitudeType.fromValue(
      configStore.getString(
        audioAmplitudeAnimationTypeKey,
        audioAmplitudeAnimationDefaultType.name,
      ),
    );

    // Disable.
    if (type == .none) {
      _pcmSub?.cancel();
      _pcmSub = null;

      return;
    }

    // _amplitudeUpdateInterval = type.toDuration;

    _pcmSub ??= stream.waveform.listen(_onWaveData);
  }

  // ===========================================================================
  // PCM
  // ===========================================================================

  void _onWaveData(WaveformData? wave) {
    if (wave == null) return;

    // wave.min
    // wave.max
    // wave.filled
    // wave.duration
    // wave.bins
    for (var i = 0; i < wave.bins; i++) {
      if (wave.filled[i] == 0) continue;

      // final min = wave.min[i];
      // final max = wave.max[i];

      // min → max vertical line
    }
  }

  // ===========================================================================
  // DISPOSE
  // ===========================================================================

  Future<void> disposeAmplitude() async {
    await _configStoreSub?.cancel();
    await _pcmSub?.cancel();

    await _amplitudeController.close();
  }
}
