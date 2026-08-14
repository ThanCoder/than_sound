import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:mpv_audio_kit/mpv_audio_kit.dart';
import 'package:than_sound/core/controllers/interfaces/i_controller.dart';
import 'package:than_sound/core/controllers/player/listener/loudness_config_listener.dart';
import 'package:than_sound/core/controllers/player/my_audio_handler.dart';
import 'package:than_sound/core/models/audio_file.dart';

enum AudioFileSourceType { none, allFileState, favouriteState }

class PlayerStateController extends IController with LoudnessConfigListener {
  ValueNotifier<AudioFile?> get current => _audioHandler.currentNotifier;
  List<AudioFile> get files => _audioHandler.files;

  final MyAudioHandler _audioHandler;
  PlayerStateController(this._audioHandler);

  PlayerState get state => _audioHandler.state;
  @override
  Player get player => _audioHandler.player;

  PlayerStream get stream => _audioHandler.stream;
  AudioFileSourceType get source => _audioHandler.source;
  Stream<AudioFile?> get currentAudioChangeStream =>
      _audioHandler.currentAudioChangeStream;

  @override
  void init() async {
    onLoudnessConfigListener();
  }

  AudioFileSourceType get sourceType => _audioHandler.source;
  final showFloatWidget = ValueNotifier<bool>(false);

  Future<void> setTracks(
    List<AudioFile> files, {
    required AudioFileSourceType source,
  }) async {
    _audioHandler.setTracks(files, source: source);
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

  Future<void> stop() async {
    if (_audioHandler.state.playing) {
      await _audioHandler.stop();
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
}
