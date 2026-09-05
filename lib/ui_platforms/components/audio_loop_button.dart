import 'package:flutter/material.dart';
import 'package:than_sound/core/controllers/interfaces/i_controller.dart';
import 'package:than_sound/core/controllers/player_state/player_loop.dart';
import 'package:than_sound/core/controllers/player_state/player_state_controller.dart';

class AudioLoopButton extends StatefulWidget {
  const AudioLoopButton({super.key, this.iconSize = 25});

  final double iconSize;

  @override
  State<AudioLoopButton> createState() => _AudioLoopButtonState();
}

class _AudioLoopButtonState extends State<AudioLoopButton> {
  final con = ControllerManager.read<PlayerStateController>();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: con.stream.loop,
      initialData: con.state.loop,
      builder: (context, snapshot) {
        final loop = con.state.loop;

        return IconButton(
          onPressed: con.actions.toggleLoop,
          iconSize: widget.iconSize,
          tooltip: switch (loop) {
            PlayerLoop.off => 'Loop off',
            PlayerLoop.file => 'Loop song',
            PlayerLoop.playlist => 'Loop playlist',
          },
          icon: switch (loop) {
            PlayerLoop.off => const Icon(Icons.repeat),
            PlayerLoop.file => const Icon(Icons.repeat_one),
            PlayerLoop.playlist => const Icon(Icons.repeat_on_outlined),
          },
        );
      },
    );
  }
}
