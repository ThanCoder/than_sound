// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cfb_store/cfb_store.dart';

import 'package:than_sound/core/controllers/player_state/player_state_controller.dart';
import 'package:than_sound/ui_platforms/player_theme/interfaces/player_ui_actions.dart';

class PlayerUiContext {
  const PlayerUiContext({
    required this.state,
    required this.stream,
    required this.actions,
    required this.uiActions,
    required this.config,
  });

  final PlayerState state;
  final PlayerStream stream;
  final PlayerActions actions;
  final PlayerUiActions uiActions;
  final CFBStore config;
}
