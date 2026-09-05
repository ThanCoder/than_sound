import 'dart:async';

import 'package:cfb_store/cfb_store.dart';
import 'package:mpv_audio_kit/mpv_audio_kit.dart';
import 'package:than_sound/const_keys.dart';
import 'package:than_sound/core/controllers/player_state/configs/bass_config.dart';
import 'package:than_sound/core/controllers/player_state/player_state_controller.dart';

mixin BassConfigListener {
  PlayerStateController get controller;
  CFBStore get config => controller.config;

  Future<void> initBassConfigListener() async {
    config.stream.put.where((e) => e.key == audioBassConfigKey).listen((event) {
      _update();
    });
    _update();
  }

  void _update() {
    final cf = BassConfig.fromMap(config.getMap(audioBassConfigKey));
    controller.player.updateAudioEffects(
      (e) => e.copyWith(
        bass: BassSettings(enabled: cf.enable, g: cf.gain, f: cf.frequency),
      ),
    );
  }
}
