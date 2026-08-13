import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:than_sound/ui_platforms/mobile/components/waveform/waveform_switcher.dart';
import 'package:waveform_visualizer/waveform_visualizer.dart';

class Waveform extends StatefulWidget {
  final bool playingState;
  final Stream<bool> playing;
  final Stream<double> amplitude;
  const Waveform({
    super.key,
    required this.playing,
    required this.amplitude,
    required this.playingState,
  });

  @override
  State<Waveform> createState() => _WaveformState();
}

class _WaveformState extends State<Waveform> {
  final _waveformController = WaveformController();

  StreamSubscription? _playingSub;
  StreamSubscription? _pcmSub;

  bool _playing = false;

  @override
  void initState() {
    super.initState();

    _playing = widget.playingState;

    _initWaveform();
  }

  @override
  void dispose() {
    _playingSub?.cancel();
    _pcmSub?.cancel();
    _waveformController.dispose();

    super.dispose();
  }

  void _initWaveform() {
    if (_playing) {
      _waveformController.start();
    }

    _playingSub = widget.playing.listen((playing) {
      _playing = playing;

      if (playing) {
        _waveformController.start();
      } else {
        _waveformController.stop();
      }
    });

    _pcmSub = widget.amplitude.listen((nextAmplitude) {
      _waveformController.updateAmplitude(nextAmplitude);
    });
  }

  double calculateRMS(List<double> samples) {
    double sum = 0;

    for (final sample in samples) {
      sum += sample * sample;
    }

    return sqrt(sum / samples.length);
  }

  @override
  Widget build(BuildContext context) {
    return WaveformSwitcher(
      switcher: (style) {
        return WaveformWidget(
          controller: _waveformController,
          height: 65,
          style: WaveformStyle(
            waveColor: Theme.of(context).colorScheme.primary,
            backgroundColor: Colors.transparent,
            waveformStyle: style,
            showGradient: true,
          ),
        );
      },
    );
  }
}
