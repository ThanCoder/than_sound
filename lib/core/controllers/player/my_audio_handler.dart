import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:than_sound/const_keys.dart';
import 'package:than_sound/core/controllers/interfaces/i_controller.dart';
import 'package:than_sound/core/controllers/player/extra_mixin.dart';
import 'package:than_sound/core/controllers/player_state/player_state_controller.dart';
import 'package:than_sound/ui_platforms/pages/favourite/favourite_controller.dart';

class MyAudioHandler extends BaseAudioHandler
    with QueueHandler, SeekHandler, ExtraMixin {
  PlayerStateController get stateController =>
      ControllerManager.read<PlayerStateController>();
  FavouriteController get favController =>
      ControllerManager.read<FavouriteController>();

  @override
  MyAudioHandler get audioHandler => this;
  bool _init = false;
  void listenEvents() {
    if (_init) return;
    _init = true;

    stateController.stream.playlist.listen((event) {
      addNotiMediaItem(event.file);
    });
    stateController.stream.position.listen((event) {
      playbackState.add(transformEvent);
    });
    stateController.stream.playbackState.listen((event) {
      playbackState.add(transformEvent);
    });
  }

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
    playbackState.add(playbackState.value.copyWith(processingState: .idle));
  }

  @override
  Future<dynamic> customAction(String name, [Map<String, dynamic>? extras]) {
    if (name == 'favorite') {
      stateController.actions.removeFav();
    }
    if (name == 'favorite_outline') {
      stateController.actions.addFav();
    }

    return super.customAction(name, extras);
  }

  @override
  Future<void> click([MediaButton button = MediaButton.media]) async {
    final useBluetoothControl = stateController.config.getBool(
      audioBluetoothControlKeyName,
      true,
    );
    if (!useBluetoothControl) return;
    if (!stateController.state.playing) {
      await stateController.actions.play();
    }
    return super.click(button);
  }
}
