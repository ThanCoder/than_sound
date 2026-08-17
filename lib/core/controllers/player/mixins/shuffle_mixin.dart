part of '../my_audio_handler.dart';

mixin ShuffleMixin {
  MyAudioHandler get audioHandler;

  final _shuffleStreamController = StreamController<bool>.broadcast();
  bool _isShuffle = false;

  void toggleShuffle() {
    if (audioHandler._isShuffle) {
      final current = audioHandler.currentNotifier.value;
      if (current == null) return;
      disableShuffle(current);
    } else {
      enableShuffle();
    }
  }

  void enableShuffle() {
    audioHandler._isShuffle = true;
    _shuffleStreamController.add(_isShuffle);

    audioHandler.playOrder = [...audioHandler.playlist];
    audioHandler.playOrder.shuffle();
  }

  void disableShuffle(AudioFile current) {
    audioHandler._isShuffle = false;
    _shuffleStreamController.add(_isShuffle);

    final index = audioHandler.playlist.indexWhere((e) => e.id == current.id);

    audioHandler.playOrder = [
      ...audioHandler.playlist.skip(index),
      ...audioHandler.playlist.take(index),
    ];
  }
}
