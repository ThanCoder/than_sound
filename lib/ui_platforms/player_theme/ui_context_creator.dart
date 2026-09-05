import 'package:than_sound/core/controllers/interfaces/i_controller.dart';
import 'package:than_sound/core/controllers/player_state/player_state_controller.dart';
import 'package:than_sound/ui_platforms/player_theme/interfaces/player_ui_actions.dart';
import 'package:than_sound/ui_platforms/player_theme/interfaces/player_ui_context.dart';

class UiContextCreator {
  static PlayerUiContext create({required PlayerUiActions uiActions}) {
    final pc = ControllerManager.read<PlayerStateController>();
    return .new(
      config: pc.config,
      state: pc.state,
      stream: pc.stream,
      actions: pc.actions,
      uiActions: uiActions,
    );
  }
}

//Stream<double> amplitude
