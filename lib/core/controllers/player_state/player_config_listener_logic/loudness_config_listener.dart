import 'dart:async';

import 'package:cfb_store/cfb_store.dart';
import 'package:mpv_audio_kit/mpv_audio_kit.dart';
import 'package:than_sound/const_keys.dart';
import 'package:than_sound/core/controllers/player_state/configs/loudess_config.dart';
import 'package:than_sound/core/controllers/player_state/player_state_controller.dart';

mixin LoudnessConfigListener {
  PlayerStateController get controller;

  CFBStore get config => controller.config;

  StreamSubscription? _configSub;
  StreamSubscription? _loudnessSub;

  LoudessConfig _loudnessConfig = const LoudessConfig();

  Future<void> initLoudnessConfigListener() async {
    // Initial config
    _loudnessConfig = LoudessConfig.fromMap(config.getMap(loudnessConfigKey));

    // Listen config changes
    _configSub = config.stream.put
        .where((e) => e.key == loudnessConfigKey)
        .listen((event) {
          _loudnessConfig = LoudessConfig.fromMap(
            config.getMap(loudnessConfigKey),
          );

          if (!_loudnessConfig.enabled) {
            controller.player.setVolumeGain(0.0);
          }
        });

    // Subscribe only once.
    _loudnessSub = controller.player.stream.loudness.listen(_onLoudness);
  }

  void _onLoudness(LoudnessScan? scan) {
    if (!_loudnessConfig.enabled) {
      return;
    }

    if (scan?.state != LoudnessScanState.ready) {
      return;
    }

    final integrated = scan?.integrated;

    if (integrated == null) {
      return;
    }

    final gain = (_loudnessConfig.targetLufs - integrated).clamp(
      _loudnessConfig.minGain,
      _loudnessConfig.maxGain,
    );

    controller.player.setVolumeGain(gain);
  }

  Future<void> disposeLoudnessConfigListener() async {
    await _configSub?.cancel();
    await _loudnessSub?.cancel();

    _configSub = null;
    _loudnessSub = null;
  }
}
