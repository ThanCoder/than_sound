import 'dart:io';
import 'dart:math';
import 'package:dart_core_extensions/dart_core_extensions.dart';
import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_sound/const_keys.dart';
import 'package:than_sound/core/controllers/player_state/player_state_controller.dart';
import 'package:than_sound/core/models/audio_file.dart';
import 'package:than_sound/exts.dart';
import 'package:than_sound/ui_platforms/components/audio_loop_button.dart';
import 'package:than_sound/ui_platforms/components/reactive_cover/audio_reactive_cover_switcher.dart';
import 'package:than_sound/ui_platforms/components/waveform/waveform_widget/waveform.dart';
import 'package:than_sound/ui_platforms/components/audio_thumbnail.dart';
import 'package:than_sound/ui_platforms/components/c_slider.dart';
import 'package:than_sound/ui_platforms/pages/favourite/favourite_button.dart';
import 'package:than_sound/ui_platforms/player_theme/interfaces/i_player_theme.dart';
import 'package:than_sound/ui_platforms/player_theme/interfaces/player_ui_context.dart';
import 'package:than_sound/ui_platforms/mobile/mobile_player_ui_actions.dart';
import 'package:than_sound/ui_platforms/ui_config/config/ui_content_blur_config.dart';

class MobileDefaultPlayerContentTheme extends IPlayerTheme {
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
  PlayerState get state => ctx.state;
  MobilePlayerUiActions get actions => ctx.uiActions as MobilePlayerUiActions;

  final double statusbarHeight = Platform.isLinux ? 0 : 40;

  @override
  Widget build(BuildContext context) {
    final current = state.current;

    if (current == null) {
      return const SizedBox.shrink();
    }
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

    return StreamBuilder(
      stream: ctx.config.stream.put.where((e) => e.key == audioContentBlurKey),
      builder: (context, asyncSnapshot) {
        final contentBur = UiContentBlurConfig.fromMap(
          ctx.config.getMap(audioContentBlurKey),
        );
        return Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fill(child: AudioThumbnail(file: current)),

            if (contentBur.enable)
              Positioned.fill(
                child: ClipRect(
                  child: BackdropFilter(
                    filter: .blur(
                      sigmaX: contentBur.sigmaX,
                      sigmaY: contentBur.sigmaY,
                    ),
                    child: const SizedBox.expand(),
                  ),
                ),
              ),

            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    scheme.surface.withValues(
                      alpha: contentBur.enable ? .30 : .45,
                    ),
                    scheme.surface.withValues(
                      alpha: contentBur.enable ? .65 : .72,
                    ),
                    scheme.surface.withValues(
                      alpha: contentBur.enable ? .95 : .92,
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
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
            child: StreamBuilder(
              stream: ctx.stream.playing,
              builder: (context, snapshot) {
                final playing = ctx.state.playing;
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
      playerStream: ctx.state.player.stream,
      playing: ctx.state.player.stream.playing,
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
          child: AudioThumbnail(file: current),
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
    if (Platform.isLinux) {
      return SizedBox.shrink();
    }
    return SizedBox(
      height: 65,
      width: double.infinity,
      child: Waveform(
        playingState: state.playing,
        playing: ctx.state.player.stream.playing,
        playerStream: ctx.state.player.stream,
      ),
    );
  }

  Widget _controls() {
    final col = context.colorScheme;

    return Column(
      children: [
        _progress(),

        const SizedBox(height: 8),

        StreamBuilder(
          stream: ctx.stream.playing,
          initialData: state.playing,
          builder: (context, snapshot) {
            final playing = state.playing;

            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                StreamBuilder(
                  stream: ctx.stream.shuffle,
                  builder: (context, asyncSnapshot) {
                    final isShuffle = state.isShuffle;
                    return _controlButton(
                      icon: isShuffle
                          ? Icons.shuffle_on_rounded
                          : Icons.shuffle,
                      size: 25,
                      onPressed: () {
                        ctx.actions.toggleShuffle();
                      },
                    );
                  },
                ),
                _controlButton(
                  icon: Icons.skip_previous_rounded,
                  size: 48,
                  onPressed: actions.previous,
                ),

                const SizedBox(width: 20),

                Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: col.primary,
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                        color: col.primary.withValues(alpha: .35),
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: IconButton(
                    onPressed: actions.playPause,
                    iconSize: 36,
                    color: col.onPrimary,
                    icon: Icon(
                      playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    ),
                  ),
                ),

                const SizedBox(width: 20),
                _controlButton(
                  icon: Icons.skip_next_rounded,
                  size: 48,
                  onPressed: actions.next,
                ),
                AudioLoopButton(),

                // _controlButton(icon: Icons.replay, size: 25),
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
    VoidCallback? onPressed,
  }) {
    return IconButton(onPressed: onPressed, iconSize: size, icon: Icon(icon));
  }

  Widget _progress() {
    return StreamBuilder(
      stream: ctx.stream.position,
      initialData: state.position,
      builder: (context, snapshot) {
        final position = state.position;

        final duration = state.duration;

        final max = maxValue(duration.inMilliseconds.toDouble(), 1);

        final value = position.inMilliseconds.toDouble().clamp(0.0, max);

        return Column(
          children: [
            SliderTheme(
              data: SliderThemeData(thumbShape: .noThumb),
              child: CSlider(
                min: 0,
                max: max,
                value: value,
                onChangeEnd: (value) {
                  actions.seek(Duration(milliseconds: value.toInt()));
                },
              ),
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
