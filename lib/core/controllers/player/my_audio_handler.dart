import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:cfb_store/cfb_store.dart';
import 'package:flutter/material.dart';
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

  List<AudioFile> _files = [];

  List<AudioFile> get files => _files;
  final currentNotifier = ValueNotifier<AudioFile?>(null);

  AudioFile? findFile(AudioFile file) {
    final index = files.indexWhere((e) => e.id == file.id);
    if (index == -1) return null;
    return files[index];
  }

  int get currentIndex {
    if (currentNotifier.value == null) return -1;
    return files.indexWhere((e) => e.id == currentNotifier.value!.id);
  }

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

    _player.stream.playbackState.listen((event) {
      // print('playbackState: $event');
      if (event == .completed) {
        // print('completed');
        skipToNext();
      }
    });
  }

  Future<void> setAll(
    List<AudioFile> files, {
    int index = 0,
    bool play = true,
  }) async {
    _files = files;
    currentNotifier.value = files[index];
    await _player.open(createMedia(currentNotifier.value!), play: play);
    addNotiMediaItem(currentNotifier.value!);
  }

  Future<void> open(AudioFile file) async {
    final index = currentIndex;
    if (index == -1) {
      debugPrint('[MyAudioHandler:open]: index:$index');
      return;
    }
    currentNotifier.value = file;
    await _player.open(createMedia(file), play: true);
    addNotiMediaItem(currentNotifier.value!);
  }

  @override
  Future<void> skipToNext() async {
    final index = currentIndex;
    if (index == -1) return;
    final next = index + 1;
    if (next >= files.length) return;
    currentNotifier.value = files[next];
    await open(files[next]);
  }

  @override
  Future<void> skipToPrevious() async {
    final index = currentIndex;
    if (index == -1) return;
    final prev = index - 1;
    if (prev < 0) return;
    currentNotifier.value = files[prev];
    await open(files[prev]);
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

  void addNotiMediaItem(AudioFile file) {
    mediaItem.add(createMediaItem(file, duration: state.duration));
  }

  Media createMedia(AudioFile file) {
    return Media(
      File(file.path).uri.toString(),
      extras: {
        'id': file.id,
        'title': file.autoTitle,
        'artist': file.meta.artist,
        'album': file.meta.album,
        'duration': file.meta.duration,
      },
    );
  }

  MediaItem createMediaItem(AudioFile file, {Duration? duration}) {
    var item = MediaItem(
      id: file.id,
      title: file.autoTitle,
      album: file.meta.album,
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
