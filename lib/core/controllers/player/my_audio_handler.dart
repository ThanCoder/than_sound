import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:cfb_store/cfb_store.dart';
import 'package:mpv_audio_kit/mpv_audio_kit.dart' hide MediaAction;
import 'package:than_sound/core/const_keys.dart';
import 'package:than_sound/core/models/audio_file.dart';

class MyAudioHandler extends BaseAudioHandler with QueueHandler, SeekHandler {
  final _player = Player();

  MyAudioHandler() {
    _listen();
  }

  PlayerState get state => _player.state;
  PlayerStream get stream => _player.stream;
  bool audioPaused = false;

  void _listen() {
    _player.stream.position.listen((pos) {
      playbackState.add(_transformEvent());
    });

    _player.stream.duration.listen((duration) {
      playbackState.add(_transformEvent());
    });

    _player.stream.playbackState.listen((event) {
      playbackState.add(_transformEvent());
    });
  }

  Future<void> openByIndex(int index) async {
    await _player.jump(index);
    await _player.play();
  }

  Future<void> openAll(
    List<AudioFile> files, {
    int index = 0,
    bool play = true,
  }) async {
    final medias = files.map((e) => createMedia(e)).toList();
    // final chapters = files.map((e) => createChapter(e)).toList();

    // await _player.setChapters(chapters);
    await _player.openAll(medias, index: index, play: play);

    mediaItem.add(createMediaItem(files[index], duration: state.duration));
  }

  // The most common callbacks:
  @override
  Future<void> play() async {
    _player.play();
    audioPaused = false;
  }

  @override
  Future<void> pause() async {
    _player.pause();
    audioPaused = true;
  }

  @override
  Future<void> seek(Duration position) => _player.seek(position);
  @override
  Future<void> skipToQueueItem(int index) => _player.seek(Duration.zero);

  @override
  Future<void> skipToNext() async {
    await _player.next();
  }

  @override
  Future<void> skipToPrevious() async {
    await _player.previous();
  }

  Future<void> dispose() async {
    _player.dispose();
  }

  @override
  Future<void> stop() async {
    audioPaused = false;
    await _player.stop();
    playbackState.add(
      playbackState.value.copyWith(playing: false, processingState: .idle),
    );
  }

  @override
  Future<dynamic> customAction(String name, [Map<String, dynamic>? extras]) {
    // final current = AudioStateController.instance.currentAudioFile;
    // if (name == 'favorite' && current != null) {
    //   AudioBookmarkController.instance.remove(current.id);
    // }
    // if (name == 'favorite_outline' && current != null) {
    //   AudioBookmarkController.instance.add(current.id);
    // }

    return super.customAction(name, extras);
  }

  @override
  Future<void> click([MediaButton button = MediaButton.media]) async {
    final useBluetoothControl = CFBStore.getInstance.getBool(
      audioBluetoothControlKeyName,
      true,
    );
    if (!useBluetoothControl) return;

    return super.click(button);
  }

  Chapter createChapter(AudioFile file) {
    return Chapter(time: .new(), title: file.id);
  }

  Media createMedia(AudioFile file) {
    return Media(
      File(file.path).uri.toString(),
      extras: {
        'title': file.meta.title,
        'artist': file.meta.artist,
        'album': file.meta.album,
        'duration': file.meta.duration,
      },
    );
  }

  MediaItem createMediaItem(AudioFile file, {Duration? duration}) {
    var item = MediaItem(
      id: file.id,
      album: file.meta.album,
      title: file.meta.title,
      artist: file.meta.artist,
      genre: file.meta.genre,
      duration: duration ?? file.meta.duration,
      artUri: File(file.cacheCoverPath).uri,
    );
    return item;
  }

  PlaybackState _transformEvent() => .new(
    controls: [
      MediaControl.skipToPrevious,
      state.playing ? MediaControl.pause : .play,
      MediaControl.stop,
      MediaControl.skipToNext,
      // if (true)
      MediaControl.custom(
        androidIcon: "drawable/favorite",
        label: 'Favorite',
        name: 'favorite',
      ),
      // else
      //   MediaControl.custom(
      //     androidIcon: "drawable/favorite_outline",
      //     label: 'UnFavorite',
      //     name: 'favorite_outline',
      //   ),
    ],
    systemActions: {
      MediaAction.seek,
      MediaAction.seekForward,
      MediaAction.seekBackward,
    },
    androidCompactActionIndices: const [0, 1, 2],
    processingState: processingState,
    playing: state.playing,
    updatePosition: state.position,
    bufferedPosition: state.buffer,
    // speed: state.cacheSpeed
  );
  AudioProcessingState get processingState {
    if (state.completed) return .completed;
    if (state.buffering) return .buffering;
    if (state.playWhenReady || state.playing) return .ready;
    // if (!state.playing) return .ready;
    if (audioPaused) return .ready;
    return .idle;
  }
}
