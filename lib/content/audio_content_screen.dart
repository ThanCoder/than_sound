import 'dart:async';

import 'package:flutter/material.dart';
import 'package:than_sound/audio/thumbnail.dart';
import 'package:than_sound/core/controllers/i_controller.dart';
import 'package:than_sound/core/controllers/player/player_state_controller.dart';
import 'package:than_sound/core/models/audio_file.dart';
import 'package:waveform_visualizer/waveform_visualizer.dart';

class AudioContentScreen extends StatefulWidget {
  const AudioContentScreen({super.key});

  @override
  State<AudioContentScreen> createState() => _AudioContentScreenState();
}

class _AudioContentScreenState extends State<AudioContentScreen> {
  final _controller = WaveformController();
  StreamSubscription? _sub, _sub2;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => init());
  }

  @override
  void dispose() {
    _sub?.cancel();
    _sub2?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void init() {
    final con = context.read<PlayerStateController>();

    if (con.state.playing) {
      _controller.start();
    }

    _sub2 = con.stream.playing.listen((event) {
      if (con.state.playing) {
        _controller.start();
      } else {
        _controller.stop();
      }
    });

    _sub = con.stream.position.listen((position) {
      final duration = con.state.duration;

      if (duration == Duration.zero) return;

      final progress = position.inMilliseconds / duration.inMilliseconds;

      _controller.updateAmplitude(progress.clamp(0.0, 1.0));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('content')),
      body: bodyWidget,
    );
  }

  Widget get bodyWidget {
    final con = context.read<PlayerStateController>();

    return StreamBuilder(
      stream: con.stream.playlist,
      builder: (context, asyncSnapshot) {
        final current = con.current;
        if (current == null) {
          return SizedBox.shrink();
        }
        final size = MediaQuery.of(context).size;

        return Stack(
          children: [
            Positioned.fill(child: Thumbnail(file: current)),
            Container(
              decoration: BoxDecoration(
                color: const Color.fromARGB(178, 8, 8, 8),
              ),
            ),

            Positioned(
              top: size.height * 0.2,
              right: 0,
              left: 0,
              child: SizedBox(
                height: size.height,
                child: ClipRRect(
                  borderRadius: .circular(10),
                  child: Container(color: const Color.fromARGB(155, 15, 39, 39)),
                ),
              ),
            ),
            Positioned(top: 0, right: 0, left: 0, child: coverWidget),
            Positioned(
              top: size.height * 0.4,
              right: 0,
              left: 0,
              child: mainContentWidget,
            ),
          ],
        );
      },
    );
  }

  Widget get coverWidget {
    final con = context.read<PlayerStateController>();
    return Center(
      child: ClipRRect(
        borderRadius: .circular(8),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420, maxHeight: 230),
          child: Thumbnail(file: con.current!),
        ),
      ),
    );
  }

  Widget get mainContentWidget {
    final con = context.read<PlayerStateController>();
    final current = con.current!;
    final size = MediaQuery.of(context).size;
    return SizedBox(
      width: size.width,
      height: size.height * 0.5,
      child: Column(
        children: [
          Text(current.autoTitle),
          waveformWidget,
          // Spacer(),
          StreamBuilder(
            stream: con.stream.playing,
            builder: (context, asyncSnapshot) {
              return Row(
                mainAxisAlignment: .center,
                children: [
                  IconButton(
                    iconSize: 60,
                    onPressed: () {
                      con.prev();
                    },
                    icon: Icon(Icons.skip_previous),
                  ),
                  IconButton(
                    iconSize: 70,
                    onPressed: () {
                      con.toggle();
                    },
                    icon: Icon(
                      con.state.playing ? Icons.pause : Icons.play_arrow,
                    ),
                  ),
                  IconButton(
                    iconSize: 60,
                    onPressed: () {
                      con.next();
                    },
                    icon: Icon(Icons.skip_next),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget get waveformWidget {
    return WaveformWidget(
      controller: _controller,
      height: 50,
      style: WaveformStyle(
        waveColor: const Color.fromARGB(255, 25, 171, 191),
        backgroundColor: const Color.fromARGB(199, 14, 14, 14),
        waveformStyle: WaveformDrawStyle.bars,
        showGradient: true,
      ),
    );
  }
}
