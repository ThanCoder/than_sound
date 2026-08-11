import 'dart:async';
import 'dart:io';

import 'package:dart_core_extensions/dart_core_extensions.dart';
import 'package:flutter/material.dart';
import 'package:than_sound/audio/thumbnail.dart';
import 'package:than_sound/content/c_slider.dart';
import 'package:than_sound/content/player_playlist.dart';
import 'package:than_sound/core/controllers/interfaces/i_controller.dart';
import 'package:than_sound/core/controllers/player/player_state_controller.dart';
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
    return Theme(
      data: .dark(),
      child: Scaffold(
        appBar: Platform.isAndroid ? null : AppBar(title: Text('content')),
        body: SafeArea(child: bodyWidget),
      ),
    );
  }

  Widget get bodyWidget {
    final con = context.read<PlayerStateController>();

    return ValueListenableBuilder(
      valueListenable: con.current,
      builder: (context, current, child) {
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
              top: size.height * 0.13,
              right: 0,
              left: 0,
              child: SizedBox(
                height: size.height,
                child: ClipRRect(
                  borderRadius: .circular(10),
                  child: Container(
                    color: const Color.fromARGB(155, 18, 20, 20),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              top: size.height * 0.2,
              // height: size.height,
              child: Center(child: waveformWidget),
            ),
            Positioned(top: 0, right: 0, left: 0, child: coverWidget),
            Positioned(
              top: size.height * 0.43,
              right: 0,
              left: 0,
              child: mainContentWidget,
            ),
            Positioned(
              left: 0,
              right: 0,
              // width: size.width,
              bottom: 5,
              child: controlsWiget,
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
          child: Thumbnail(file: con.current.value!),
        ),
      ),
    );
  }

  Widget get mainContentWidget {
    final con = context.read<PlayerStateController>();
    final current = con.current.value!;
    final size = MediaQuery.of(context).size;
    return SizedBox(
      width: size.width,
      height: size.height * 0.5,
      child: Column(
        children: [
          Text(current.autoTitle),
          // waveformWidget,
          // Spacer(),
          controlButtonWidget(con),
        ],
      ),
    );
  }

  StreamBuilder<bool> controlButtonWidget(PlayerStateController con) {
    return StreamBuilder(
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
              icon: Icon(con.state.playing ? Icons.pause : Icons.play_arrow),
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
    );
  }

  Widget get waveformWidget {
    return WaveformWidget(
      controller: _controller,
      height: 400,
      style: WaveformStyle(
        waveColor: const Color.fromARGB(255, 98, 238, 238),
        backgroundColor: const Color.fromARGB(47, 37, 34, 34),
        waveformStyle: WaveformDrawStyle.bars,
        showGradient: true,
      ),
    );
  }

  // slider controls
  Widget get controlsWiget {
    final con = context.read<PlayerStateController>();
    return Column(children: [audioPosiWidget(con), specialWidget()]);
  }

  Row specialWidget() {
    return Row(
      spacing: 4,
      children: [
        Spacer(),
        IconButton(onPressed: () {}, icon: Icon(Icons.timer)),
        IconButton(onPressed: () {}, icon: Icon(Icons.favorite)),
        IconButton(onPressed: showPlayList, icon: Icon(Icons.list_rounded)),
      ],
    );
  }

  StreamBuilder<Duration> audioPosiWidget(PlayerStateController con) {
    return StreamBuilder(
      stream: con.stream.position,
      builder: (context, asyncSnapshot) {
        return Column(
          children: [
            CSlider(
              max: con.state.duration.inSeconds.toDouble(),
              value: con.state.position.inSeconds.toDouble(),
              onChangeEnd: (value) {
                con.seek(Duration(seconds: value.toInt()));
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  Text(
                    '${con.state.position.formatClockLabel()}/${con.state.duration.formatClockLabel()}',
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  void showPlayList() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) =>
          FractionallySizedBox(heightFactor: 0.8, child: PlayerPlaylist()),
    );
  }
}
