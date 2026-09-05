import 'package:flutter/material.dart';
import 'package:than_sound/core/controllers/interfaces/i_controller.dart';
import 'package:than_sound/core/controllers/player_state/player_state_controller.dart';

class AudioShuffleButton extends StatefulWidget {
  const AudioShuffleButton({super.key, this.iconSize = 25});
  final double iconSize;

  @override
  State<AudioShuffleButton> createState() => _AudioShuffleButtonState();
}

class _AudioShuffleButtonState extends State<AudioShuffleButton> {
  final con = ControllerManager.read<PlayerStateController>();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: con.stream.shuffle,
      builder: (context, asyncSnapshot) {
        final isShuffle = con.state.isShuffle;
        return IconButton(
          onPressed: () {
            con.actions.toggleShuffle();
          },
          iconSize: widget.iconSize,
          icon: Icon(isShuffle ? Icons.shuffle_on_rounded : Icons.shuffle),
        );
      },
    );
  }
}
