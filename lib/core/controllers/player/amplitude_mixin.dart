import 'dart:async';
import 'dart:math';

import 'package:mpv_audio_kit/mpv_audio_kit.dart';

// Visualizer update rate.
//
// 30 FPS = ~33ms
// 60 FPS = ~16ms
// int get amplitudeFps => 30;
mixin AmplitudeMixin {
  PlayerStream get stream;

  /// 30 FPS
  /// const Duration(milliseconds: 33);
  ///
  /// 60 FPS
  /// const Duration(milliseconds: 16);
  ///
  /// 20 FPS
  /// const Duration(milliseconds: 50);
  Duration get amplitudeUpdateInterval => const Duration(milliseconds: 33);

  final _amplitudeController = StreamController<double>.broadcast();

  Stream<double> get amplitude => _amplitudeController.stream;

  StreamSubscription<PcmFrame>? _pcmSub;

  DateTime _lastAmplitudeUpdate = DateTime.fromMillisecondsSinceEpoch(0);

  void onListenPcmFrame() {
    _pcmSub ??= stream.pcm.listen(_onPcm);
  }

  void _onPcm(PcmFrame frame) {
    if (frame.samples.isEmpty) return;

    final now = DateTime.now();

    final interval = amplitudeUpdateInterval;

    if (now.difference(_lastAmplitudeUpdate) < interval) {
      return;
    }

    // final intervalMs = 1000 ~/ amplitudeFps;
    // if (now.difference(_lastAmplitudeUpdate).inMilliseconds < intervalMs) {
    //   return;
    // }

    _lastAmplitudeUpdate = now;

    final amplitude = _calculateRms(frame.samples);

    _amplitudeController.add(amplitude.clamp(0.0, 1.0));
  }

  double _calculateRms(List<double> samples) {
    double sum = 0;

    for (final sample in samples) {
      sum += sample * sample;
    }

    return sqrt(sum / samples.length);
  }

  Future<void> disposeAmplitude() async {
    await _pcmSub?.cancel();
    await _amplitudeController.close();
  }
}
