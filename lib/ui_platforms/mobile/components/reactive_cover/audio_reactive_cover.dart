import 'dart:async';

import 'package:flutter/material.dart';
import 'package:than_sound/ui_platforms/mobile/content/default_content/reactive_cover_types.dart';

class AudioReactiveCover extends StatefulWidget {
  final Widget child;

  final Stream<double> amplitude;

  final Stream<bool> playing;
  final bool playingState;

  final AudioReactiveCoverConfig config;

  const AudioReactiveCover({
    super.key,
    required this.amplitude,
    required this.playing,
    required this.playingState,
    this.config = const AudioReactiveCoverConfig(),
    required this.child,
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

    _pcmSub = widget.amplitude.listen((nextAmplitude) {
      if (!mounted) return;

      setState(() {
        _amplitude = nextAmplitude;
      });
    });
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
