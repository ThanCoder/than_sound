import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:mpv_audio_kit/mpv_audio_kit.dart' hide MediaAction;
import 'package:than_sound/core/controllers/player/my_audio_handler.dart';
import 'package:than_sound/core/models/audio_file.dart';

mixin ExtraMixin {
  MyAudioHandler get audioHandler;
  List<AudioFile> get playOrder => audioHandler.playOrder;
  List<AudioFile> get playlist => audioHandler.playlist;
  ValueNotifier<AudioFile?> get currentNotifier => audioHandler.currentNotifier;
  PlayerState get state => audioHandler.state;

  void addNotiMediaItem(AudioFile file) {
    audioHandler.mediaItem.add(
      createMediaItem(file, duration: file.meta.duration),
    );
  }

  AudioFile? findFile(AudioFile file) {
    final index = playlist.indexWhere((e) => e.id == file.id);
    if (index == -1) return null;
    return playlist[index];
  }

  int get getNextSongIndex {
    final index = getCurrentIndex(currentNotifier.value);
    if (index == -1) return -1;
    final next = index + 1;
    if (next >= playOrder.length) return -1;
    return next;
  }

  bool get isLastTrack {
    final file = currentNotifier.value;
    if (file == null) return false;
    final index = getCurrentIndex(file);
    return index == playOrder.length - 1;
  }

  int getCurrentIndex(AudioFile? file) {
    if (file == null) return -1;
    return playOrder.indexWhere((e) => e.id == file.id);
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

  PlaybackState get transformEvent => .new(
    controls: [
      MediaControl.skipToPrevious,
      state.playing ? MediaControl.pause : .play,
      MediaControl.stop,
      MediaControl.skipToNext,
      if (currentNotifier.value != null &&
          audioHandler.favouriteController.isExists(currentNotifier.value!))
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
    if (audioHandler.audioPaused) return .ready;
    return .idle;
  }
}
