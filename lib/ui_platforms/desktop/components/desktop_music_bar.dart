import 'dart:io';

import 'package:dart_core_extensions/dart_core_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:than_sound/core/models/audio_file.dart';
import 'package:than_sound/ui_platforms/ui/audio/thumbnail.dart';
import 'package:than_sound/ui_platforms/ui/content/c_slider.dart';
import 'package:than_sound/ui_platforms/player_theme/interfaces/player_ui_context.dart';
import 'package:than_sound/ui_platforms/player_theme/interfaces/player_ui_state.dart';
import 'package:than_sound/ui_platforms/player_theme/interfaces/player_ui_streams.dart';
import 'package:than_sound/ui_platforms/desktop/desktop_player_ui_actions.dart';

class DesktopMusicBar extends StatefulWidget {
  final PlayerUiContext uiContext;
  final void Function()? closeBar;
  const DesktopMusicBar({super.key, required this.uiContext, this.closeBar});

  @override
  State<DesktopMusicBar> createState() => _DesktopMusicBarState();
}

class _DesktopMusicBarState extends State<DesktopMusicBar> {
  PlayerUiState get state => widget.uiContext.state();
  PlayerUiStreams get streams => widget.uiContext.streams;
  DesktopPlayerUiActions get actions =>
      widget.uiContext.actions as DesktopPlayerUiActions;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }

  final focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return keyboardListener();
  }

  KeyboardListener keyboardListener() {
    return KeyboardListener(
      focusNode: focusNode,
      autofocus: true,
      onKeyEvent: (value) {
        if (value is KeyDownEvent) {
          if (value.logicalKey == .keyF) {}
          if (value.logicalKey == .space) {
            actions.playPause();
          }
        }
      },
      child: streamWidget(),
    );
  }

  StreamBuilder<AudioFile?> streamWidget() {
    final colorScheme = Theme.of(context).colorScheme;
    return StreamBuilder(
      stream: streams.playlist,
      builder: (context, asyncSnapshot) {
        return Container(
          // height: 126,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainer,
            border: Border(top: BorderSide(color: colorScheme.outlineVariant)),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: .end,
                children: [
                  InkWell(
                    onTap: () {
                      widget.closeBar?.call();
                    },
                    child: Icon(Icons.close),
                  ),
                ],
              ),
              Row(
                children: [
                  _cover(colorScheme),
                  const SizedBox(width: 24),
                  Expanded(child: _playerControls()),

                  _extraControls(),
                ],
              ),
              _songInfo(),
            ],
          ),
        );
      },
    );
  }

  ClipRRect _cover(ColorScheme colorScheme) {
    final coverFile = File(state.current?.cacheCoverPath ?? '');
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 52,
        height: 52,
        color: colorScheme.surfaceContainerHighest,
        child: coverFile.existsSync()
            ? Thumbnail(file: state.current!)
            : const Icon(Icons.music_note_rounded, size: 28),
      ),
    );
  }

  Widget _songInfo() {
    // final colorScheme = Theme.of(context).colorScheme;

    return Text(state.current!.autoTitle);
  }

  Widget _playerControls() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              tooltip: 'Previous',
              onPressed: actions.previous,
              icon: const Icon(Icons.skip_previous_rounded),
            ),

            const SizedBox(width: 8),

            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).colorScheme.primary,
              ),
              child: StreamBuilder(
                stream: streams.playing,
                builder: (context, asyncSnapshot) {
                  return IconButton(
                    tooltip: 'Play',
                    onPressed: actions.playPause,
                    icon: Icon(
                      state.playing ? Icons.pause : Icons.play_arrow_rounded,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  );
                },
              ),
            ),

            const SizedBox(width: 8),

            IconButton(
              tooltip: 'Next',
              onPressed: actions.next,
              icon: const Icon(Icons.skip_next_rounded),
            ),
          ],
        ),

        const SizedBox(height: 2),

        Row(
          children: [
            SizedBox(
              width: 35,
              child: StreamBuilder(
                stream: streams.position,
                builder: (context, asyncSnapshot) {
                  return Text(
                    state.position.formatClockLabel(),
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11),
                  );
                },
              ),
            ),

            Expanded(
              child: StreamBuilder(
                stream: streams.position,
                initialData: state.position,
                builder: (context, snapshot) {
                  final position = snapshot.data ?? Duration.zero;

                  final duration = state.duration;

                  final max = maxValue(duration.inMilliseconds.toDouble(), 1);

                  final value = position.inMilliseconds.toDouble().clamp(
                    0.0,
                    max,
                  );
                  return CSlider(
                    max: max,
                    value: value,
                    onChangeEnd: (value) {
                      actions.seek(Duration(milliseconds: value.toInt()));
                    },
                  );
                },
              ),
            ),

            SizedBox(
              width: 35,
              child: Text(
                state.duration.formatClockLabel(),
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _extraControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        IconButton(
          tooltip: 'Repeat',
          onPressed: () {},
          icon: const Icon(Icons.repeat_rounded),
        ),

        IconButton(
          tooltip: 'Shuffle',
          onPressed: () {},
          icon: const Icon(Icons.shuffle_rounded),
        ),

        const Icon(Icons.volume_up_outlined, size: 20),

        RotatedBox(
          quarterTurns: 3,
          child: SizedBox(
            width: 100,
            child: Slider(value: 70, max: 100, onChanged: (_) {}),
          ),
        ),
      ],
    );
  }

  double maxValue(double value, double min) {
    return value < min ? min : value;
  }
}
