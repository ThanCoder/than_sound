import 'package:than_sound/core/controllers/player_state/player_state_controller.dart';
import 'package:than_sound/ui_platforms/player_theme/interfaces/player_ui_actions.dart';

class PlayerUiContext {
  final PlayerState state;
  final PlayerStream stream;
  final PlayerActions actions;
  final PlayerUiActions uiActions;

  const PlayerUiContext({
    required this.state,
    required this.stream,
    required this.actions,
    required this.uiActions,
  });
}
