import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

class AudioReactiveCoverConfig {
  /// Overall effect strength.
  ///
  /// 1.0 = normal
  /// 2.0 = strong
  /// 3.0 = very strong
  final double intensity;

  /// Maximum scale amount.
  ///
  /// 0.05 = maximum 5% larger
  /// 0.10 = maximum 10% larger
  final double maxScale;

  /// PCM sensitivity.
  ///
  /// Higher = reacts more easily to small sounds.
  final double amplitudeMultiplier;

  /// Smoothing factor.
  ///
  /// 0.0 = very responsive
  /// 0.9 = very smooth
  final double smoothing;

  /// Animation duration when scale changes.
  final Duration animationDuration;

  const AudioReactiveCoverConfig({
    this.intensity = 1.4,
    this.maxScale = 0.07,
    this.amplitudeMultiplier = 3.0,
    this.smoothing = 0.65,
    this.animationDuration = const Duration(milliseconds: 80),
  });

  /// Subtle effect.
  const AudioReactiveCoverConfig.subtle({
    this.intensity = 1.0,
    this.maxScale = 0.035,
    this.amplitudeMultiplier = 2.0,
    this.smoothing = 0.75,
    this.animationDuration = const Duration(milliseconds: 100),
  });

  /// Strong effect.
  const AudioReactiveCoverConfig.strong({
    this.intensity = 2.0,
    this.maxScale = 0.10,
    this.amplitudeMultiplier = 3.5,
    this.smoothing = 0.55,
    this.animationDuration = const Duration(milliseconds: 65),
  });

  /// Very strong / visualizer-like effect.
  const AudioReactiveCoverConfig.extreme({
    this.intensity = 2.5,
    this.maxScale = 0.14,
    this.amplitudeMultiplier = 4.0,
    this.smoothing = 0.45,
    this.animationDuration = const Duration(milliseconds: 45),
  });
}

class AudioReactiveCover extends StatefulWidget {
  final Widget child;

  final Stream<List<double>> pcm;

  final Stream<bool> playing;
  final bool playingState;

  final AudioReactiveCoverConfig config;

  const AudioReactiveCover({
    super.key,
    required this.child,
    required this.pcm,
    required this.playing,
    required this.playingState,
    this.config = const AudioReactiveCoverConfig(),
  });

  @override
  State<AudioReactiveCover> createState() => _AudioReactiveCoverState();
}

class _AudioReactiveCoverState extends State<AudioReactiveCover> {
  StreamSubscription? _pcmSub;
  StreamSubscription? _playingSub;

  bool _playing = false;

  double _amplitude = 0.0;

  AudioReactiveCoverConfig get config => widget.config;

  @override
  void initState() {
    super.initState();
    _playing = widget.playingState;

    _playingSub = widget.playing.listen((playing) {
      if (!mounted) return;

      setState(() {
        _playing = playing;

        if (!playing) {
          _amplitude = 0.0;
        }
      });
    });

    DateTime lastUpdate = DateTime.fromMillisecondsSinceEpoch(0);

    _pcmSub = widget.pcm.listen((samples) {
      if (!_playing || samples.isEmpty) return;

      final now = DateTime.now();

      // Max ~30 updates/sec
      if (now.difference(lastUpdate).inMilliseconds < 33) {
        return;
      }

      lastUpdate = now;

      final rms = _calculateRms(samples);

      final smoothing = config.smoothing.clamp(0.0, 0.95);

      final nextAmplitude =
          (_amplitude * smoothing) + (rms * (1.0 - smoothing));

      if (!mounted) return;

      setState(() {
        _amplitude = nextAmplitude;
      });
    });

    setState(() {});
  }

  double _calculateRms(List<double> samples) {
    double sum = 0;

    for (final sample in samples) {
      sum += sample * sample;
    }

    return sqrt(sum / samples.length);
  }

  @override
  void dispose() {
    _pcmSub?.cancel();
    _playingSub?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final amplitude = (_amplitude * config.amplitudeMultiplier).clamp(0.0, 1.0);

    final scale = _playing
        ? 1.0 + (amplitude * config.maxScale * config.intensity)
        : 1.0;

    return AnimatedScale(
      scale: scale,
      duration: config.animationDuration,
      curve: Curves.easeOut,
      child: widget.child,
    );
  }
}
