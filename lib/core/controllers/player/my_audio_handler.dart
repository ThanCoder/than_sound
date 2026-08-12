import 'dart:async';
import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:cfb_store/cfb_store.dart';
import 'package:flutter/material.dart';
import 'package:mpv_audio_kit/mpv_audio_kit.dart' hide MediaAction;
import 'package:than_sound/core/const_keys.dart';
import 'package:than_sound/core/controllers/all_file_event.dart';
import 'package:than_sound/core/controllers/all_file_state_controller.dart';
import 'package:than_sound/core/controllers/interfaces/i_controller.dart';
import 'package:than_sound/core/controllers/player/player_state_controller.dart';
import 'package:than_sound/core/models/audio_file.dart';
import 'package:than_sound/ui/favourite/favourite_controller.dart';

class MyAudioHandler extends BaseAudioHandler with QueueHandler, SeekHandler {
  final _player = Player();
  FavouriteController get favouriteController =>
      ControllerManager.read<FavouriteController>();
  AllFileStateController get allFileStateController =>
      ControllerManager.read<AllFileStateController>();

  PlayerState get state => _player.state;
  PlayerStream get stream => _player.stream;
  bool audioPaused = false;

  AudioFileSourceType _source = .none;
  AudioFileSourceType get source => _source;
  List<AudioFile> _files = [];

  List<AudioFile> get files => _files;
  final currentNotifier = ValueNotifier<AudioFile?>(null);
  final _currentAudioChangeContrller = StreamController<AudioFile?>.broadcast();
  Stream<AudioFile?> get currentAudioChangeStream =>
      _currentAudioChangeContrller.stream;

  void startListen() {
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
    // all audio state
    favouriteController.eventStream.listen((event) {
      if (source != .favouriteState) return;
      if (event is FavouriteControllerAddEvent) {
        _files.insert(0, event.file);
      }
      if (event is FavouriteControllerRemoveEvent) {
        final index = _files.indexWhere((e) => e.id == event.file.id);
        if (index == -1) return;
        _files.removeAt(index);
      }
    });
    allFileStateController.eventStream.listen((event) {
      if (source != .allFileState) return;
      if (event is AllFileAddEvent) {
        _files.insert(0, event.file);
      }
      if (event is AllFileRemoveEvent) {
        final index = _files.indexWhere((e) => e.id == event.file.id);
        if (index == -1) return;
        _files.removeAt(index);
      }
    });
    currentNotifier.addListener(
      () => _currentAudioChangeContrller.add(currentNotifier.value),
    );
  }

  AudioFile? findFile(AudioFile file) {
    final index = files.indexWhere((e) => e.id == file.id);
    if (index == -1) return null;
    return files[index];
  }

  int getCurrentIndex(AudioFile? file) {
    if (file == null) return -1;
    return files.indexWhere((e) => e.id == file.id);
  }

  Future<void> setTracks(
    List<AudioFile> files, {
    int index = 0,
    required AudioFileSourceType source,
  }) async {
    _files = files;
    _source = source;
    currentNotifier.value = files[index];
    if (_player.state.playing || currentNotifier.value != null) return;
    await setAll(files, play: false);
  }

  Future<void> setAll(
    List<AudioFile> files, {
    int index = 0,
    bool play = true,
  }) async {
    _files = files;
    await _player.open(createMedia(currentNotifier.value!), play: play);
    addNotiMediaItem(currentNotifier.value!);
  }

  Future<void> open(AudioFile file) async {
    final index = getCurrentIndex(file);
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
    final index = getCurrentIndex(currentNotifier.value);
    if (index == -1) return;
    final next = index + 1;
    if (next >= files.length) return;
    currentNotifier.value = files[next];
    await open(files[next]);
  }

  @override
  Future<void> skipToPrevious() async {
    final index = getCurrentIndex(currentNotifier.value);
    if (index == -1) return;
    final prev = index - 1;
    if (prev < 0) return;
    currentNotifier.value = files[prev];
    await open(files[prev]);
  }

  // The most common callbacks:
  @override
  Future<void> play() async {
    // _player.state
    if (_player.state.duration.inSeconds == _player.state.position.inSeconds) {
      await _player.seek(Duration.zero);
    }
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
    currentNotifier.value = null;
    playbackState.add(
      playbackState.value.copyWith(playing: false, processingState: .idle),
    );
  }

  @override
  Future<dynamic> customAction(String name, [Map<String, dynamic>? extras]) {
    final current = currentNotifier.value;
    if (name == 'favorite' && current != null) {
      // AudioBookmarkController.instance.remove(current.id);
      favouriteController.remove(current);
    }
    if (name == 'favorite_outline' && current != null) {
      favouriteController.add(current);
      // AudioBookmarkController.instance.add(current.id);
    }

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
      if (currentNotifier.value != null &&
          favouriteController.isExists(currentNotifier.value!))
        MediaControl.custom(
          androidIcon: "drawable/favorite",
          label: 'Favorite',
          name: 'favorite',
        )
      else
        MediaControl.custom(
          androidIcon: "drawable/favorite_outline",
          label: 'UnFavorite',
          name: 'favorite_outline',
        ),
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
