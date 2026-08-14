import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mpv_audio_kit/mpv_audio_kit.dart';
import 'package:than_sound/ui_platforms/components/reactive_cover/reactive_cover_types.dart';

class AudioReactiveCover extends StatefulWidget {
  final Widget child;

  final PlayerStream playerStream;

  final Stream<bool> playing;
  final bool playingState;

  final ReactiveCoverType type;

  const AudioReactiveCover({
    super.key,
    required this.playing,
    required this.playingState,
    required this.type,
    required this.child,
    required this.playerStream,
  });

  @override
  State<AudioReactiveCover> createState() => _AudioReactiveCoverState();
}

class _AudioReactiveCoverState extends State<AudioReactiveCover> {
  StreamSubscription? _playingSub;

  bool _playing = false;

  @override
  void initState() {
    super.initState();

    _playing = widget.playingState;

    _playingSub = widget.playing.listen((playing) {
      if (!mounted) return;

      setState(() {
        _playing = playing;
      });
    });
  }

  @override
  void dispose() {
    _playingSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_playing) {
      return widget.child;
    }

    return StreamBuilder(
      stream: widget.playing,
      builder: (context, asyncSnapshot) {
        if (!_playing) {
          return widget.child;
        }
        return StreamBuilder(
          stream: widget.playerStream.fft,
          builder: (context, snapshot) {
            final frame = snapshot.data;
            if (frame == null) {
              return widget.child;
            }

            final bass = fftToBass(frame);
            final scale = 1.0 + bass * widget.type.scaleFactor;

            // print(
            //   'bass=${bass.toStringAsFixed(3)} '
            //   'scale=${scale.toStringAsFixed(3)}',
            // );

            // return widget.child;
            return Transform.scale(
              scale: scale,
              alignment: Alignment.topCenter,
              child: widget.child,
            );
          },
        );
      },
    );
  }

  double fftToBass(FftFrame frame) {
    final bands = frame.bands;
    final count = min(8, bands.length);

    if (count == 0) return 0;

    var energy = 0.0;
    var weight = 0.0;

    for (var i = 0; i < count; i++) {
      final w = 1.0 - (i / count) * 0.5;

      energy += bands[i] * bands[i] * w;
      weight += w;
    }

    final bass = sqrt(energy / weight);

    // Low bass values ကိုပို sensitive ဖြစ်စေ
    return pow(bass, 0.7).toDouble();
  }
}



  /*
    const SpectrumSettings(
        minDb: -80,
        maxDb: 0,
        attackSmoothing: 0.7,
        releaseSmoothing: 0.15,
        emitInterval: Duration(milliseconds: 33),
        overlapFactor: 4,
      ),
// final bass = fftToBass(frame);
// final scale = 1.0 + bass * 0.04;



      double fftToBass(FftFrame frame) {
    final bands = frame.bands;
    final count = min(8, bands.length);

    if (count == 0) return 0;

    var energy = 0.0;
    var weight = 0.0;

    for (var i = 0; i < count; i++) {
      // ပထမ bands ကို ပိုအလေးပေး
      final w = 1.0 - (i / count) * 0.5;

      energy += bands[i] * bands[i] * w;
      weight += w;
    }

    return sqrt(energy / weight);
  }
   */

/**************Nice****************** */
// final bass = fftToBass(frame);
// final scale = 1.0 + bass * 0.04;
/////////////////////////////

//   double _pulse = 0.0;
//   double _previousBass = 0.0;

//   double fftToBass(FftFrame frame) {
//     final bands = frame.bands;
//     final count = min(4, bands.length);

//     print(bands.take(8).toList());

//     if (count == 0) return 0.0;

//     var energy = 0.0;

//     for (var i = 0; i < count; i++) {
//       energy += bands[i] * bands[i];
//     }

//     final bass = sqrt(energy / count);

//     final rise = bass - _previousBass;
//     _previousBass = bass;

//     // rise ဖြစ်တဲ့အချိန်မှာပဲ pulse
//     if (rise > 0.01) {
//       _pulse = (_pulse + rise * 4).clamp(0.0, 1.0);
//     }

//     // decay
//     _pulse *= 0.82;

//     return _pulse;
//   }
// }

/**************Nice****************** */


    /********old************** */
    // var bass = 0.0;
    // for (var i = 0; i < count; i++) {
    //   bass += bands[i];
    // }
    // bass /= count;
    /********old************** */
