import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mpv_audio_kit/mpv_audio_kit.dart';

part 'waveform_painter.dart';

class WaveformSeekbar extends StatefulWidget {
  const WaveformSeekbar({
    super.key,
    required this.playerStream,
    this.height = 48,
  });

  final PlayerStream playerStream;
  final double height;

  @override
  State<WaveformSeekbar> createState() => _WaveformSeekbarState();
}

class _WaveformSeekbarState extends State<WaveformSeekbar> {
  StreamSubscription? _waveformSub;
  StreamSubscription? _positionSub;

  WaveformData? _waveform;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();

    _waveformSub = widget.playerStream.waveform.listen((wave) {
      if (!mounted) return;

      setState(() {
        _waveform = wave;
      });
    });

    _positionSub = widget.playerStream.position.listen((position) {
      if (!mounted) return;

      setState(() {
        _position = position;
      });
    });
  }

  @override
  void dispose() {
    _waveformSub?.cancel();
    _positionSub?.cancel();
    super.dispose();
  }

  Future<void> _seek(double progress) async {
    final wave = _waveform;
    if (wave == null) return;

    final position = wave.duration * progress;

    // await widget.player.seek(position);
  }

  @override
  Widget build(BuildContext context) {
    final wave = _waveform;

    if (wave == null) {
      return SizedBox(height: widget.height);
    }

    final duration = wave.duration;

    final progress = duration.inMicroseconds == 0
        ? 0.0
        : (_position.inMicroseconds / duration.inMicroseconds).clamp(0.0, 1.0);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (details) {
        final box = context.findRenderObject() as RenderBox;
        final x = details.localPosition.dx;
        final progress = (x / box.size.width).clamp(0.0, 1.0);

        _seek(progress);
      },
      onHorizontalDragUpdate: (details) {
        final box = context.findRenderObject() as RenderBox;
        final x = details.localPosition.dx;
        final progress = (x / box.size.width).clamp(0.0, 1.0);

        _seek(progress);
      },
      child: CustomPaint(
        size: Size(double.infinity, widget.height),
        painter: _WaveformPainter(
          waveform: wave,
          progress: progress,
          colorScheme: Theme.of(context).colorScheme,
        ),
      ),
    );
  }
}
