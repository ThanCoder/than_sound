part of '../player_state_controller.dart';

class PlayerStateConfigListener {
  final Player player;
  final PlayerState state;
  final PlayerStream stream;
  final PlayerActions actions;
  const PlayerStateConfigListener({
    required this.player,
    required this.state,
    required this.stream,
    required this.actions,
  });

  Future<void> init() async {}
}
