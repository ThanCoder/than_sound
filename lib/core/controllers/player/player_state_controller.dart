import 'package:audio_service/audio_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:mpv_audio_kit/mpv_audio_kit.dart';
import 'package:than_sound/core/controllers/i_controller.dart';
import 'package:than_sound/core/controllers/player/my_audio_handler.dart';
import 'package:than_sound/core/models/audio_file.dart';

enum AudioFileSourceType { allFileState, singleState }

class PlayerStateController extends IController {
  AudioFile? _current;
  AudioFile? get current => _current;
  List<AudioFile> _files = [];
  List<AudioFile> get files => _files;

  late final MyAudioHandler _audioHandler;

  PlayerState get state => _audioHandler.state;
  PlayerStream get stream => _audioHandler.stream;

  @override
  void init() async {
    _audioHandler = await AudioService.init(
      builder: () => MyAudioHandler(),
      config: AudioServiceConfig(
        androidNotificationChannelId: 'thancoder.myapp.channel.audio',
        androidNotificationChannelName: 'Music playback',
        androidNotificationIcon: 'mipmap/launcher_icon',
      ),
    );
    stream.playlist.listen((event) {
      try {
        final index = event.index;
        if (index == -1) {
          _current = null;
          return;
        }
        if (index >= files.length) return;
        _current = files[index];
      } catch (e) {
        debugPrint('[PlayerStateController:stream.playlist]: $e');
      }
    });
  }

  AudioFileSourceType _sourceType = .allFileState;
  AudioFileSourceType get sourceType => _sourceType;
  final showFloatWidget = ValueNotifier<bool>(false);

  Future<void> setTracks(List<AudioFile> files) async {
    if (state.playing) {
      debugPrint('[PlayerStateController:setTracks]: Audio is Playing...');
      return;
    }
    _files = files;
    await _audioHandler.openAll(files, index: 0, play: false);
  }

  // Future<void> open(
  //   AudioFile file, {
  //   AudioFileSourceType sourceType = .singleState,
  // }) async {
  //   _sourceType = sourceType;
  //   _current = file;
  //   await _audioHandler.open(file);
  // }

  Future<void> openAll(
    List<AudioFile> files, {
    AudioFileSourceType sourceType = .allFileState,
    int index = 0,
  }) async {
    _sourceType = sourceType;
    _files = files;
    _current = files[index];
    await _audioHandler.openAll(files, index: index);
  }

  Future<void> openById(String id) async {
    final index = _files.indexWhere((e) => e.id == id);
    if (index == -1) {
      debugPrint('[PlayerStateController:openById]: index:$index');
      return;
    }
    // print('index: $index - id: $id');
    _current = files[index];
    await _audioHandler.openByIndex(index);
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

  @override
  void dispose() {
    _audioHandler.dispose();
  }
}
