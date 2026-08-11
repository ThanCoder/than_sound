import 'package:flutter/cupertino.dart';
import 'package:mpv_audio_kit/mpv_audio_kit.dart';
import 'package:than_sound/core/controllers/interfaces/i_controller.dart';
import 'package:than_sound/core/controllers/player/my_audio_handler.dart';
import 'package:than_sound/core/models/audio_file.dart';

enum AudioFileSourceType { allFileState, singleState }

class PlayerStateController extends IController {
  ValueNotifier<AudioFile?> get current => _audioHandler.currentNotifier;
  List<AudioFile> get files => _audioHandler.files;

  final MyAudioHandler _audioHandler;
  PlayerStateController(this._audioHandler);

  PlayerState get state => _audioHandler.state;
  PlayerStream get stream => _audioHandler.stream;
  bool _serviceInit = false;

  @override
  void init() async {
    if (_serviceInit) return;

    _serviceInit = true;
  }

  AudioFileSourceType _sourceType = .allFileState;
  AudioFileSourceType get sourceType => _sourceType;
  final showFloatWidget = ValueNotifier<bool>(false);

  Future<void> setTracks(List<AudioFile> files, {int index = 0}) async {
    if (state.playing) {
      debugPrint('[PlayerStateController:setTracks]: Audio is Playing...');
      return;
    }
    await _audioHandler.setAll(files, index: index, play: false);
  }

  Future<void> openAll(
    List<AudioFile> files, {
    AudioFileSourceType sourceType = .allFileState,
    int index = 0,
  }) async {
    _sourceType = sourceType;
    await _audioHandler.setAll(files, index: index);
  }

  Future<void> open(AudioFile file) async {
    await _audioHandler.open(file);
    showFloatWidget.value = true;
  }

  Future<void> pause() async {
    if (_audioHandler.state.playing) {
      await _audioHandler.pause();
    }
  }

  Future<void> play() async {
    if (_audioHandler.state.playing) return;
    await _audioHandler.play();
  }

  Future<void> toggle() async {
    if (_audioHandler.state.playing) {
      await _audioHandler.pause();
    } else {
      await _audioHandler.play();
    }
  }

  Future<void> next() async {
    await _audioHandler.skipToNext();
  }

  Future<void> prev() async {
    await _audioHandler.skipToPrevious();
  }

  Future<void> seek(Duration position) async {
    await _audioHandler.seek(position);
  }

  @override
  void dispose() {
    _audioHandler.dispose();
  }
}
