import 'dart:async';

import 'package:cfb_store/cfb_store.dart';
import 'package:mpv_audio_kit/mpv_audio_kit.dart';
import 'package:than_sound/const_keys.dart';
import 'package:than_sound/core/controllers/player_state/configs/treble_config.dart';
import 'package:than_sound/core/controllers/player_state/player_state_controller.dart';

mixin TrebleConfigListener {
  PlayerStateController get controller;
  CFBStore get config => controller.config;

  Future<void> initTrebleConfigListener() async {
    config.stream.put.where((e) => e.key == audioTrebleConfigKey).listen((
      event,
    ) {
      _update();
    });
    _update();
  }

  void _update() {
    final cf = TrebleConfig.fromMap(config.getMap(audioTrebleConfigKey));
    controller.player.updateAudioEffects(
      (e) => e.copyWith(
        treble: TrebleSettings(enabled: cf.enable, g: cf.gain, f: cf.frequency),
      ),
    );
  }
}
