part of '../player_state_controller.dart';

class PlayerStateConfigListener {
  PlayerStateConfigListener({
    required this.player,
    required this.state,
    required this.stream,
    required this.actions,
  });

  final Player player;
  final PlayerState state;
  final PlayerStream stream;
  final PlayerActions actions;

  bool _init = false;

  Future<void> init() async {
    if (_init) return;
    _init = true;
  }
}
