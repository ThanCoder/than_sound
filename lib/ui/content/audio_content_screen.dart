import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:dart_core_extensions/dart_core_extensions.dart';
import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_sound/core/controllers/interfaces/i_controller.dart';
import 'package:than_sound/exts.dart';
import 'package:than_sound/ui/audio/thumbnail.dart';
import 'package:than_sound/ui/content/c_slider.dart';
import 'package:than_sound/ui/content/player_playlist.dart';
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
  final _waveformController = WaveformController();

  StreamSubscription? _playingSub;
  StreamSubscription? _pcmSub;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initPlayer();
    });
  }

  @override
  void dispose() {
    _playingSub?.cancel();
    _pcmSub?.cancel();
    _waveformController.dispose();
    super.dispose();
  }

  void _initPlayer() {
    final con = ControllerManager.read<PlayerStateController>();

    if (con.state.playing) {
      _waveformController.start();
    }

    _playingSub = con.stream.playing.listen((playing) {
      if (playing) {
        _waveformController.start();
      } else {
        _waveformController.stop();
      }
    });

    _pcmSub = con.stream.pcm.listen((frame) {
      if (frame.samples.isEmpty) return;

      final amplitude = calculateRMS(frame.samples);

      _waveformController.updateAmplitude(amplitude.clamp(0.0, 1.0));
    });
  }

  double calculateRMS(List<double> samples) {
    if (samples.isEmpty) return 0;

    double sum = 0;

    for (final sample in samples) {
      sum += sample * sample;
    }

    return sqrt(sum / samples.length);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Platform.isAndroid ? null : AppBar(title: const Text('Content')),
      body: SafeArea(child: _body),
    );
  }

  Widget get _body {
    final con = ControllerManager.read<PlayerStateController>();

    return ValueListenableBuilder(
      valueListenable: con.current,
      builder: (context, current, child) {
        if (current == null) {
          return const SizedBox.shrink();
        }

        return Stack(
          fit: StackFit.expand,
          children: [_background(current), _playerContent(current)],
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Background
  // ---------------------------------------------------------------------------

  Widget _background(AudioFile current) {
    final isLight = context.isLightMode;

    return Stack(
      fit: StackFit.expand,
      children: [
        Thumbnail(file: current),

        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                isLight
                    ? Colors.white.withValues(alpha: .45)
                    : Colors.black.withValues(alpha: .45),
                isLight
                    ? Colors.white.withValues(alpha: .72)
                    : Colors.black.withValues(alpha: .72),
                isLight
                    ? Colors.white.withValues(alpha: .92)
                    : Colors.black.withValues(alpha: .94),
              ],
            ),
          ),
        ),

        Positioned.fill(
          child: BackdropFilter(
            filter: .blur(sigmaX: 18, sigmaY: 18),
            child: const SizedBox(),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Main Content
  // ---------------------------------------------------------------------------

  Widget _playerContent(AudioFile current) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
      child: Column(
        children: [
          _header(current),

          const SizedBox(height: 12),

          Expanded(child: _mainPlayer(current)),

          const SizedBox(height: 8),

          _controls(),

          const SizedBox(height: 4),

          _actions(),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Header
  // ---------------------------------------------------------------------------

  Widget _header(AudioFile current) {
    final con = ControllerManager.read<PlayerStateController>();

    return SizedBox(
      height: 48,
      child: Row(
        children: [
          const SizedBox(width: 48),

          Expanded(
            child: StreamBuilder(
              stream: con.stream.playing,
              builder: (context, snapshot) {
                final playing = con.state.playing;

                if (playing) {
                  return Marquee(
                    text: current.autoTitle,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                    blankSpace: 30,
                    velocity: 35,
                    pauseAfterRound: const Duration(seconds: 2),
                    accelerationDuration: const Duration(milliseconds: 500),
                    accelerationCurve: Curves.easeOut,
                    decelerationDuration: const Duration(milliseconds: 300),
                    decelerationCurve: Curves.easeOut,
                  );
                }

                return Text(
                  current.autoTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                );
              },
            ),
          ),

          IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert)),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Album + Info + Waveform
  // ---------------------------------------------------------------------------

  Widget _mainPlayer(AudioFile current) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final coverSize = min(
          constraints.maxWidth - 20,
          constraints.maxHeight * .55,
        );

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _cover(current, coverSize),

            const SizedBox(height: 18),

            _songInfo(current),

            const SizedBox(height: 14),

            Expanded(child: _waveform()),
          ],
        );
      },
    );
  }

  Widget _cover(AudioFile current, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            blurRadius: 35,
            spreadRadius: 2,
            offset: const Offset(0, 18),
            color: Colors.black.withValues(alpha: .25),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Thumbnail(file: current),
      ),
    );
  }

  Widget _songInfo(AudioFile current) {
    return Column(
      children: [
        Text(
          current.autoTitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w700),
        ),

        const SizedBox(height: 5),

        Text(
          current.meta.artist.isEmptyOr('Unknown Artist'),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: .65),
          ),
        ),
      ],
    );
  }

  Widget _waveform() {
    return SizedBox(
      height: 65,
      width: double.infinity,
      child: WaveformWidget(
        controller: _waveformController,
        height: 65,
        style: WaveformStyle(
          waveColor: Theme.of(context).colorScheme.primary,
          backgroundColor: Colors.transparent,
          waveformStyle: WaveformDrawStyle.bars,
          showGradient: true,
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Controls
  // ---------------------------------------------------------------------------

  Widget _controls() {
    final con = ControllerManager.read<PlayerStateController>();

    return Column(
      children: [
        _progress(con),

        const SizedBox(height: 8),

        StreamBuilder(
          stream: con.stream.playing,
          builder: (context, snapshot) {
            final playing = con.state.playing;

            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _controlButton(
                  icon: Icons.skip_previous_rounded,
                  size: 48,
                  onPressed: con.prev,
                ),

                const SizedBox(width: 28),

                Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).colorScheme.primary,
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: .25),
                      ),
                    ],
                  ),
                  child: IconButton(
                    onPressed: con.toggle,
                    iconSize: 36,
                    color: Theme.of(context).colorScheme.onPrimary,
                    icon: Icon(
                      playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    ),
                  ),
                ),

                const SizedBox(width: 28),

                _controlButton(
                  icon: Icons.skip_next_rounded,
                  size: 48,
                  onPressed: con.next,
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _controlButton({
    required IconData icon,
    required double size,
    required VoidCallback onPressed,
  }) {
    return IconButton(onPressed: onPressed, iconSize: size, icon: Icon(icon));
  }

  // ---------------------------------------------------------------------------
  // Progress
  // ---------------------------------------------------------------------------

  Widget _progress(PlayerStateController con) {
    return StreamBuilder<Duration>(
      stream: con.stream.position,
      builder: (context, snapshot) {
        final position = con.state.position;
        final duration = con.state.duration;

        final max = maxValue(duration.inMilliseconds.toDouble(), 1);

        final value = position.inMilliseconds.toDouble().clamp(0.0, max);

        return Column(
          children: [
            CSlider(
              max: max,
              value: value,
              onChangeEnd: (value) {
                con.seek(Duration(milliseconds: value.toInt()));
              },
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    position.formatClockLabel(),
                    style: const TextStyle(fontSize: 12),
                  ),
                  Text(
                    duration.formatClockLabel(),
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Bottom Actions
  // ---------------------------------------------------------------------------

  Widget _actions() {
    final con = ControllerManager.read<PlayerStateController>();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        IconButton(
          tooltip: 'Sleep timer',
          onPressed: () {},
          icon: const Icon(Icons.timer_outlined),
        ),

        if (con.current.value != null)
          FavouriteButton(file: con.current.value!),

        IconButton(
          tooltip: 'Playlist',
          onPressed: showPlayList,
          icon: const Icon(Icons.queue_music_rounded),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Playlist
  // ---------------------------------------------------------------------------

  void showPlayList() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return FractionallySizedBox(heightFactor: .82, child: PlayerPlaylist());
      },
    );
  }

  double maxValue(double value, double min) {
    return value < min ? min : value;
  }
}
