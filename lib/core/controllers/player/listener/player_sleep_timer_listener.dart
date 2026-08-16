import 'dart:async';

import 'package:cfb_store/cfb_store.dart';
import 'package:than_sound/const_keys.dart';
import 'package:than_sound/core/controllers/player/player_state_controller.dart';
import 'package:than_sound/ui_platforms/components/sleep_timer/sleep_timer_mode.dart';

mixin PlayerSleepTimerListener {
  PlayerStateController get playerState;

  final cf = CFBStore.getInstance;
  StreamSubscription? _sub;
  bool _isInit = false;

  void onSleepTimerListener() {
    if (_isInit) return;
    _isInit = true;

    cf.stream.put.listen((event) {
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
      cf.getString(playerSleepTimerTypeKey),
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
    _sub = playerState.currentAudioChangeStream.listen((event) {
      playerState.pause();
      _setTypeToNone();
    });
  }

  void _endOfPlaylist() {
    _sub = playerState.currentAudioChangeStream.listen((event) {
      if (playerState.getNextSongIndex == -1) {
        playerState.pause();
        _setTypeToNone();
      }
    });
  }

  void _setTypeToNone() {
    cf.put(playerSleepTimerTypeKey, SleepTimerMode.none.name);
  }
}
