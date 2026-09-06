import 'dart:async';
import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:cfb_store/cfb_store.dart';
import 'package:mpv_audio_kit/mpv_audio_kit.dart';
import 'package:than_sound/const_keys.dart';
import 'package:than_sound/core/controllers/interfaces/i_controller.dart';
import 'package:than_sound/core/controllers/player_state/player_config_listener_logic/bass_config_listener.dart';
import 'package:than_sound/core/controllers/player_state/player_config_listener_logic/treble_config_listener.dart';
import 'package:than_sound/core/controllers/player_state/player_fade_controller.dart';
import 'package:than_sound/core/controllers/player_state/player_loop.dart';
import 'package:than_sound/ui_platforms/components/sleep_timer/sleep_timer.dart';
import 'package:than_sound/core/models/audio_file.dart';
import 'package:than_sound/ui_platforms/pages/favourite/favourite_controller.dart';

part 'events.dart';
part 'state.dart';
part 'stream.dart';
part 'actions.dart';
part 'logic/player_state_config_listener.dart';
part 'logic/player_state_event_listener.dart';
part 'logic/player_state_session_listener.dart';

enum AudioFileSourceType { none, allFileState, favouriteState, libState }

class PlayerStateController extends IController {
  PlayerStateController(this.player);
  final Player player;

  final config = CFBStore.instance;
  final sleepTimer = SleepTimer();

  late final state = PlayerState(player);
  late final stream = PlayerStream();
  late final actions = PlayerActions(controller: this);
  late final _configListenr = PlayerStateConfigListener(controller: this);
  late final _eventListenr = PlayerStateEventListener(controller: this);
  late final _sessionListener = PlayerStateSessionListener(controller: this);

  bool _init = false;

  @override
  Future<void> init() async {
    if (_init) return;
    await _configListenr.init();
    await _eventListenr.init();
    await _sessionListener.init();
    _init = true;
  }

  bool isCurrentFile(AudioFile file) {
    if (state.current == null) return false;
    return state.current!.path == file.path;
  }
}
