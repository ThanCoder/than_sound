import 'package:than_sound/ui/player_theme/interfaces/player_ui_actions.dart';
import 'package:than_sound/ui/player_theme/interfaces/player_ui_state.dart';
import 'package:than_sound/ui/player_theme/interfaces/player_ui_streams.dart';

class PlayerUiContext {
  final PlayerUiState Function() state;
  final PlayerUiStreams streams;
  final PlayerUiActions actions;

  const PlayerUiContext({
    required this.state,
    required this.streams,
    required this.actions,
  });
}
