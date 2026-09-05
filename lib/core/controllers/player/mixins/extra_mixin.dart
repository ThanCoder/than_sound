import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:mpv_audio_kit/mpv_audio_kit.dart' hide MediaAction;
import 'package:than_sound/core/controllers/player/my_audio_handler.dart';
import 'package:than_sound/core/models/audio_file.dart';

mixin ExtraMixin {
  MyAudioHandler get audioHandler;

  void addNotiMediaItem(AudioFile file) {
    audioHandler.mediaItem.add(
      createMediaItem(file, duration: file.meta.duration),
    );
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
      audioHandler.stateController.state.playing ? MediaControl.pause : .play,
      MediaControl.stop,
      MediaControl.skipToNext,
      if (audioHandler.stateController.state.current != null &&
          audioHandler.favController.isExists(
            audioHandler.stateController.state.current!,
          ))
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
    playing: audioHandler.stateController.player.state.playing,
    updatePosition: audioHandler.stateController.player.state.position,
    bufferedPosition: audioHandler.stateController.player.state.buffer,
    speed: 1.0,
    queueIndex: audioHandler.stateController.state.currentIndex,
    // speed: state.cacheSpeed
  );

  AudioProcessingState get processingState {
    final state = audioHandler.stateController.player.state;
    if (state.completed) return .completed;
    if (state.buffering) return .buffering;
    if (state.playWhenReady || state.playing) return .ready;
    if (audioHandler.stateController.state.pause) return .ready;
    return .idle;
  }
}
