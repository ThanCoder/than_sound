import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:than_sound/core/controllers/interfaces/i_controller.dart';
import 'package:than_sound/core/controllers/player_state/player_state_controller.dart';

class MyAudioHandler extends BaseAudioHandler with QueueHandler, SeekHandler {
  PlayerStateController get stateController =>
      ControllerManager.read<PlayerStateController>();

  @override
  Future<void> skipToNext() async {
    await stateController.actions.next();
  }

  @override
  Future<void> skipToPrevious() async {
    await stateController.actions.prev();
  }

  @override
  Future<void> play() async {
    await stateController.actions.play();
  }

  @override
  Future<void> pause() async {
    await stateController.actions.pause();
  }

  @override
  Future<void> seek(Duration position) async =>
      await stateController.actions.seek(position);
  @override
  Future<void> skipToQueueItem(int index) async =>
      await stateController.actions.seek(Duration.zero);

  Future<void> dispose() async {
    // stateController.actions.dispose();
  }

  @override
  Future<void> stop() async {
    await stateController.actions.stop();
  }

  @override
  Future<dynamic> customAction(String name, [Map<String, dynamic>? extras]) {
    if (name == 'favorite') {
      stateController.actions.addFav();
    }
    if (name == 'favorite_outline') {
      stateController.actions.removeFav();
    }

    return super.customAction(name, extras);
  }

  @override
  Future<void> click([MediaButton button = MediaButton.media]) async {
    final useBluetoothControl = stateController.state.useBluetoothControl;
    if (!useBluetoothControl) return;
    return super.click(button);
  }
}
