import 'dart:async';

import 'package:cfb_store/cfb_store.dart';
import 'package:mpv_audio_kit/mpv_audio_kit.dart';
import 'package:than_sound/const_keys.dart';
import 'package:than_sound/core/controllers/player_state/player_state_controller.dart';
import 'package:than_sound/core/controllers/player_state/configs/loudess_config.dart';

mixin LoudnessConfigListener {
  PlayerStateController get controller;
  CFBStore get config => controller.config;

  Future<void> initLoudnessConfigListener() async {
    config.stream.put.where((e) => e.key == loudnessConfigKey).listen((event) {
      _loudnessListener(
        LoudessConfig.fromMap(config.getMap(loudnessConfigKey)),
      );
    });
  }

  StreamSubscription? _sub;
  void _loudnessListener(LoudessConfig config) {
    _sub?.cancel();

    if (!config.enabled) {
      controller.player.setVolumeGain(0.0);
      return;
    }
    _sub = controller.player.stream.loudness.listen((scan) {
      if (scan?.state != LoudnessScanState.ready) return;

      final integrated = scan!.integrated;
      if (integrated == null) return;

      final gain = (config.targetLufs - integrated).clamp(
        config.minGain,
        config.maxGain,
      );

      controller.player.setVolumeGain(gain);
    });
  }
}
