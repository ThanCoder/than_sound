part of '../player_state_controller.dart';

class PlayerStateConfigListener
    with LoudnessConfigListener, BassConfigListener, TrebleConfigListener {
  PlayerStateConfigListener({required this._controller});
  final PlayerStateController _controller;

  @override
  PlayerStateController get controller => _controller;

  bool _init = false;

  Future<void> init() async {
    if (_init) return;
    _init = true;

    await initLoudnessConfigListener();
    await initBassConfigListener();
    await initTrebleConfigListener();
  }
}
