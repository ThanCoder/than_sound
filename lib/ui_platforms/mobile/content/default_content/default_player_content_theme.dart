import 'dart:math';
import 'package:dart_core_extensions/dart_core_extensions.dart';
import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_sound/core/models/audio_file.dart';
import 'package:than_sound/exts.dart';
import 'package:than_sound/ui_platforms/components/reactive_cover/audio_reactive_cover_switcher.dart';
import 'package:than_sound/ui_platforms/components/waveform/waveform_widget/waveform.dart';
import 'package:than_sound/ui_platforms/ui/audio/thumbnail.dart';
import 'package:than_sound/ui_platforms/ui/content/c_slider.dart';
import 'package:than_sound/ui_platforms/ui/favourite/favourite_button.dart';
import 'package:than_sound/ui_platforms/player_theme/interfaces/i_player_theme.dart';
import 'package:than_sound/ui_platforms/player_theme/interfaces/player_ui_context.dart';
import 'package:than_sound/ui_platforms/player_theme/interfaces/player_ui_state.dart';
import 'package:than_sound/ui_platforms/mobile/mobile_player_ui_actions.dart';

class DefaultPlayerContentTheme extends IPlayerTheme {
  @override
  Widget build(BuildContext context, PlayerUiContext ctx) {
    return _DefaultPlayerView(ctx: ctx);
  }
}

class _DefaultPlayerView extends StatefulWidget {
  final PlayerUiContext ctx;

  const _DefaultPlayerView({required this.ctx});

  @override
  State<_DefaultPlayerView> createState() => _DefaultPlayerViewState();
}

class _DefaultPlayerViewState extends State<_DefaultPlayerView> {
  PlayerUiContext get ctx => widget.ctx;
  PlayerUiState get state => widget.ctx.state();
  MobilePlayerUiActions get actions =>
      widget.ctx.actions as MobilePlayerUiActions;

  final double statusbarHeight = 40;

  @override
  Widget build(BuildContext context) {
    return _body();
  }

  Widget _body() {
    final current = state.current;

    if (current == null) {
      return const SizedBox.shrink();
    }
    // final statusBarColor = isLight
    //     ? Colors.white.withValues(alpha: .2)
    //     : Colors.black.withValues(alpha: .4);
    final statusBarColor = context.colorScheme.surface.withValues(alpha: .5);
    return Stack(
      fit: StackFit.expand,
      children: [
        RepaintBoundary(child: _background(current)),

        _playerContent(current),
        Positioned(
          top: 0,
          height: statusbarHeight,
          left: 0,
          right: 0,
          child: Container(decoration: BoxDecoration(color: statusBarColor)),
        ),
      ],
    );
  }

  Widget _background(AudioFile current) {
    final scheme = context.colorScheme;

    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(child: Thumbnail(file: current)),

        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                scheme.surface.withValues(alpha: .45),
                scheme.surface.withValues(alpha: .72),
                scheme.surface.withValues(alpha: .92),
                // isLight
                //     ? Colors.white.withValues(alpha: .45)
                //     : Colors.black.withValues(alpha: .45),

                // isLight
                //     ? Colors.white.withValues(alpha: .72)
                //     : Colors.black.withValues(alpha: .72),

                // isLight
                //     ? Colors.white.withValues(alpha: .92)
                //     : Colors.black.withValues(alpha: .94),
              ],
            ),
          ),
        ),
        // BackdropFilter(filter: .blur(sigmaX: 25, sigmaY: 25)),
      ],
    );
  }

  Widget _playerContent(AudioFile current) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
      child: Column(
        children: [
          // status bar
          SizedBox(height: statusbarHeight),

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

  Widget _header(AudioFile current) {
    return SizedBox(
      height: 48,
      child: Row(
        children: [
          const SizedBox(width: 38),

          Expanded(
            child: StreamBuilder<bool>(
              stream: ctx.streams.playing,
              initialData: state.playing,
              builder: (context, snapshot) {
                final playing = snapshot.data ?? false;

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

          IconButton(
            onPressed: actions.more,
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),
    );
  }

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
    return AudioReactiveCoverSwitcher(
      playerStream: ctx.streams.playerStream,
      playing: ctx.streams.playing,
      playingState: true,
      child: Container(
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
      child: Waveform(
        playingState: state.playing,
        playing: ctx.streams.playing,
        playerStream: ctx.streams.playerStream,
      ),
    );
  }

  Widget _controls() {
    return Column(
      children: [
        _progress(),

        const SizedBox(height: 8),

        StreamBuilder<bool>(
          stream: ctx.streams.playing,
          initialData: state.playing,
          builder: (context, snapshot) {
            final playing = snapshot.data ?? false;

            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _controlButton(
                  icon: Icons.skip_previous_rounded,
                  size: 48,
                  onPressed: actions.previous,
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
                    onPressed: actions.playPause,
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
                  onPressed: actions.next,
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

  Widget _progress() {
    return StreamBuilder<Duration>(
      stream: ctx.streams.position,
      initialData: state.position,
      builder: (context, snapshot) {
        final position = snapshot.data ?? Duration.zero;

        final duration = state.duration;

        final max = maxValue(duration.inMilliseconds.toDouble(), 1);

        final value = position.inMilliseconds.toDouble().clamp(0.0, max);

        return Column(
          children: [
            CSlider(
              max: max,
              value: value,
              onChangeEnd: (value) {
                actions.seek(Duration(milliseconds: value.toInt()));
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

  Widget _actions() {
    final current = state.current;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        IconButton(
          tooltip: 'Volume',
          onPressed: actions.volume,
          icon: const Icon(Icons.volume_up_sharp),
        ),
        IconButton(
          tooltip: 'Sleep timer',
          onPressed: actions.sleepTimer,
          icon: const Icon(Icons.timer_outlined),
        ),

        if (current != null) FavouriteButton(file: current),

        IconButton(
          tooltip: 'Playlist',
          onPressed: actions.playlist,
          icon: const Icon(Icons.queue_music_rounded),
        ),
      ],
    );
  }

  double maxValue(double value, double min) {
    return value < min ? min : value;
  }
}
