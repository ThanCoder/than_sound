import 'package:than_sound/core/controllers/interfaces/i_controller.dart';
import 'package:than_sound/core/controllers/player/player_state_controller.dart';
import 'package:than_sound/ui_platforms/player_theme/interfaces/player_ui_actions.dart';
import 'package:than_sound/ui_platforms/player_theme/interfaces/player_ui_context.dart';

class UiContextCreator {
  static PlayerUiContext create({required PlayerUiActions actions}) {
    final pc = ControllerManager.read<PlayerStateController>();
    return .new(
      state: () => .new(
        current: pc.current.value,
        playing: pc.state.playing,
        position: pc.state.position,
        duration: pc.state.duration,
      ),
      streams: .new(
        playing: pc.stream.playing,
        position: pc.stream.position,
        duration: pc.stream.duration,
        pcm: pc.stream.pcm,
        amplitude: pc.amplitude,
        playlist: pc.currentAudioChangeStream,
      ),
      actions: actions,
    );
  }
}

//Stream<double> amplitude
