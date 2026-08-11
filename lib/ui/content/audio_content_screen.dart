import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:dart_core_extensions/dart_core_extensions.dart';
import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_sound/ui/audio/thumbnail.dart';
import 'package:than_sound/ui/content/c_slider.dart';
import 'package:than_sound/ui/content/player_playlist.dart';
import 'package:than_sound/core/controllers/interfaces/i_controller.dart';
import 'package:than_sound/core/controllers/player/player_state_controller.dart';
import 'package:than_sound/core/models/audio_file.dart';
import 'package:than_sound/ui/favourite/favourite_button.dart';
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

    _sub = con.stream.pcm.listen((frame) {
      // frame ထဲက PCM samples → amplitude
      final amplitude = calculateRMS(frame.samples);

      _controller.updateAmplitude(amplitude.clamp(0.0, 1.0));
    });
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
    return Scaffold(
      appBar: Platform.isAndroid ? null : AppBar(title: Text('content')),
      body: SafeArea(child: bodyWidget),
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

            // main background
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: .topStart,
                  end: .bottomEnd,
                  colors: [
                    if (context.isLightMode)
                      Color.fromARGB(116, 255, 255, 255)
                    else
                      Color.fromARGB(116, 0, 0, 0),
                    if (context.isLightMode)
                      Color.fromARGB(181, 255, 255, 255)
                    else
                      Color.fromARGB(181, 0, 0, 0),
                    if (context.isLightMode)
                      Color.fromARGB(132, 222, 222, 222)
                    else
                      Color.fromARGB(132, 0, 0, 0),
                  ],
                ),
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
                  child: BackdropFilter(filter: .blur(sigmaX: 10, sigmaY: 10)),
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
            Positioned(top: 50, right: 0, left: 0, child: coverWidget),
            Positioned(top: 5, right: 0, left: 0, child: headerWidget(current)),
            Positioned(left: 0, right: 0, bottom: 5, child: controlsWiget),
          ],
        );
      },
    );
  }

  Widget headerWidget(AudioFile current) {
    final con = context.read<PlayerStateController>();
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: 50, maxWidth: 200),
      child: Center(
        child: StreamBuilder(
          stream: con.stream.playing,
          builder: (context, asyncSnapshot) {
            if (con.state.playing) {
              return Marquee(
                text: current.autoTitle,
                style: TextStyle(fontWeight: FontWeight.bold),
                scrollAxis: Axis.horizontal,
                crossAxisAlignment: CrossAxisAlignment.center,
                blankSpace: 20.0,
                velocity: 100.0,
                pauseAfterRound: Duration(seconds: 1),
                accelerationDuration: Duration(seconds: 1),
                accelerationCurve: Curves.linear,
                decelerationDuration: Duration(milliseconds: 500),
                decelerationCurve: Curves.easeOut,
              );
            }
            return Text(
              current.autoTitle,
              maxLines: 1,
              overflow: .clip,
              style: TextStyle(fontWeight: .bold, fontSize: 18),
            );
          },
        ),
      ),
    );
  }

  Widget get coverWidget {
    final con = context.read<PlayerStateController>();
    return Center(
      child: ClipRRect(
        borderRadius: .circular(8),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 300, maxHeight: 400),
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
    return Column(
      children: [
        controlButtonWidget(con),
        audioPosiWidget(con),
        specialWidget(con),
      ],
    );
  }

  Row specialWidget(PlayerStateController con) {
    return Row(
      spacing: 4,
      children: [
        Spacer(),
        IconButton(
          // color: const Color.fromARGB(255, 25, 127, 210),
          onPressed: () {},
          icon: Icon(Icons.timer),
        ),
        if (con.current.value != null)
          FavouriteButton(file: con.current.value!),
        IconButton(
          // color: const Color.fromARGB(255, 25, 127, 210),
          onPressed: showPlayList,
          icon: Icon(Icons.list_rounded),
        ),
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
