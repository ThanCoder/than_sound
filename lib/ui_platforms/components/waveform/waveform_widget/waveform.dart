import 'dart:async';
import 'dart:math';

import 'package:cfb_store/cfb_store.dart';
import 'package:flutter/material.dart';
import 'package:mpv_audio_kit/mpv_audio_kit.dart';
import 'package:than_sound/const_keys.dart';
import 'package:than_sound/ui_platforms/components/reactive_cover/reactive_cover_types.dart';
import 'package:than_sound/ui_platforms/components/waveform/waveform_widget/wave_form_chooser.dart';
import 'package:waveform_visualizer/waveform_visualizer.dart';

class Waveform extends StatefulWidget {
  final bool playingState;
  final Stream<bool> playing;
  final PlayerStream playerStream;
  const Waveform({
    super.key,
    required this.playing,
    required this.playingState,
    required this.playerStream,
  });

  @override
  State<Waveform> createState() => _WaveformState();
}

class _WaveformState extends State<Waveform> {
  final _waveformController = WaveformController();

  StreamSubscription? _playingSub;
  StreamSubscription? _pcmSub;
  StreamSubscription? _configSub;

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
    _configSub?.cancel();
    _waveformController.dispose();

    super.dispose();
  }

  final config = CFBStore.getInstance;
  WaveFormType get currentType =>
      WaveFormType.fromValue(config.getString(audioContentWaveFormTypeKey));

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

    _configSub = config.stream.put.listen((event) {
      if (event.key != audioContentUseReactiveCoverTypeKey) return;
      final reactiveCoverType = ReactiveCoverType.fromValue(
        CFBStore.getInstance.getString(audioContentUseReactiveCoverTypeKey),
      );
      if (reactiveCoverType == .none) {
        _pcmSub?.cancel();
        _waveformController.stop();
        return;
      }
      _listenPcm();
    });
  }

  void _listenPcm() {
    _pcmSub?.cancel();
    _pcmSub = widget.playerStream.pcm.listen((pcm) => onAudioData(pcm.samples));
  }

  // Example with a hypothetical audio package
  void onAudioData(List<double> audioSamples) {
    // Calculate RMS amplitude from audio samples
    double amplitude = calculateRMS(audioSamples);

    // Update the waveform (amplitude should be 0.0 to 1.0)
    _waveformController.updateAmplitude(amplitude);
  }

  double calculateRMS(List<double> samples) {
    double sum = 0.0;
    for (double sample in samples) {
      sum += sample * sample;
    }
    return sqrt(sum / samples.length);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: config.events.where(
        (e) => e is PutValue && e.key == audioContentWaveFormTypeKey,
      ),
      builder: (context, snapshot) {
        if (currentType == .none) {
          return SizedBox.shrink();
        }
        return WaveformWidget(
          controller: _waveformController,
          height: 65,
          style: WaveformStyle(
            waveColor: Theme.of(context).colorScheme.primary,
            backgroundColor: Colors.transparent,
            waveformStyle: currentStyle,
            // showGradient: true,
          ),
        );
      },
    );
  }

  WaveformDrawStyle get currentStyle {
    if (currentType == .bars) return .bars;
    if (currentType == .circular) return .circular;
    if (currentType == .filled) return .filled;
    if (currentType == .line) return .line;
    return .bars;
  }
}
