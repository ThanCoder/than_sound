import 'dart:async';

import 'package:mpv_audio_kit/mpv_audio_kit.dart';
import 'package:than_sound/core/controllers/interfaces/i_controller.dart';
import 'package:than_sound/core/controllers/player/my_audio_handler.dart';
import 'package:than_sound/core/models/audio_file.dart';
import 'package:than_sound/ui_platforms/pages/favourite/favourite_controller.dart';

part 'events.dart';
part 'state.dart';
part 'stream.dart';
part 'actions.dart';
part 'logic/player_state_config_listener.dart';
part 'logic/player_state_event_listener.dart';

enum AudioFileSourceType { none, allFileState, favouriteState, libState }

class PlayerStateController extends IController {
  final MyAudioHandler _audioHandler;
  PlayerStateController(this._audioHandler);

  final player = Player();
  late final state = PlayerState(player);
  late final stream = PlayerStream();
  late final actions = PlayerActions(controller: this);
  late final _configListenr = PlayerStateConfigListener(
    player: player,
    state: state,
    stream: stream,
    actions: actions,
  );
  late final _eventListenr = PlayerStateEventListener(
    player: player,
    state: state,
    stream: stream,
    actions: actions,
    audioHandler: _audioHandler,
  );

  @override
  Future<void> init() async {
    await _configListenr.init();
    await _eventListenr.init();
  }

  bool isCurrentFile(AudioFile file) {
    if (state.current == null) return false;
    return state.current!.path == file.path;
  }
}
