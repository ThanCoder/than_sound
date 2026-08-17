import 'dart:async';

import 'package:cfb_store/cfb_store.dart';
import 'package:mpv_audio_kit/mpv_audio_kit.dart';
import 'package:than_sound/const_keys.dart';
import 'package:than_sound/core/player_config/loudess_config.dart';

mixin LoudnessConfigListener {
  Player get player;
  final store = CFBStore.getInstance;
  bool _isInit = false;

  void onLoudnessConfigListener() {
    if (_isInit) return;
    _isInit = true;

    store.events.listen((event) {
      if (event is! PutValue) return;
      if (event.key != loudnessConfigKey) return;
      _loudnessListener(LoudessConfig.fromMap(store.getMap(loudnessConfigKey)));
    });
  }

  StreamSubscription? _sub;
  void _loudnessListener(LoudessConfig config) {
    _sub?.cancel();

    if (!config.enabled) {
      player.setVolumeGain(0.0);
      return;
    }
    _sub = player.stream.loudness.listen((scan) {
      if (scan?.state != LoudnessScanState.ready) return;

      final integrated = scan!.integrated;
      if (integrated == null) return;

      final gain = (config.targetLufs - integrated).clamp(
        config.minGain,
        config.maxGain,
      );

      player.setVolumeGain(gain);
    });
  }
}
