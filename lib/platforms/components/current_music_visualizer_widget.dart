import 'package:material_ui/material_ui.dart';
import 'package:mini_music_visualizer/mini_music_visualizer.dart';

import 'package:than_sound/core/controllers/interfaces/i_controller.dart';
import 'package:than_sound/core/controllers/player_state/player_state_controller.dart';
import 'package:than_sound/ui/build_context_x.dart';

class CurrentMusicVisualizerWidget extends StatelessWidget {
  const CurrentMusicVisualizerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final con = ControllerManager.read<PlayerStateController>();
    return StreamBuilder(
      stream: con.stream.playing,
      builder: (context, asyncSnapshot) {
        return MiniMusicVisualizer(
          color: context.colorScheme.primary,
          width: 4,
          height: 15,
          animate: con.state.playing,
        );
      },
    );
  }
}
