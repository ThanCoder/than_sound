import 'dart:async';

import 'package:cfb_store/cfb_store.dart';
import 'package:than_sound/const_keys.dart';
import 'package:than_sound/core/controllers/player/my_audio_handler.dart';
import 'package:than_sound/core/utils/tem_storage.dart';
import 'package:than_sound/ui_platforms/components/sleep_timer/sleep_timer_mode.dart';

mixin PlayerSleepTimerListener {
  MyAudioHandler get audioHandler;
  final _cf = TemStorage.store;

  StreamSubscription? _sub;
  bool _isInit = false;

  void onPlayerSleepTimerListener() {
    if (_isInit) return;
    _isInit = true;

    _cf.stream.put.listen((event) {
      if (event.key == playerSleepTimerTypeKey ||
          event.key == playerSleepTimerDurationSecondsKey) {
        _onListen();
      }
    });
  }

  void _onListen() {
    _sub?.cancel();
    _sub = null;
    final type = SleepTimerMode.fromValue(
      _cf.getString(playerSleepTimerTypeKey),
    );
    switch (type) {
      case .none:
        return;
      case .duration:
        return;
      case .endOfPlaylist:
        _endOfPlaylist();
        return;
      case .endOfTrack:
        _endOfTrack();
        return;
    }
  }

  void _endOfTrack() {
    _sub = audioHandler.currentAudioChangeStream.listen((event) {
      audioHandler.pause();
      _setTypeToNone();
    });
  }

  void _endOfPlaylist() {
    _sub = audioHandler.currentAudioChangeStream.listen((event) {
      if (audioHandler.getNextSongIndex == -1) {
        audioHandler.pause();
        _setTypeToNone();
      }
    });
  }

  void _setTypeToNone() {
    _cf.put(playerSleepTimerTypeKey, SleepTimerMode.none.name);
  }
}
