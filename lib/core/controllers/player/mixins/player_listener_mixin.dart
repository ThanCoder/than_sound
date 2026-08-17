part of '../my_audio_handler.dart';

mixin PlayerListenerMixin {
  MyAudioHandler get audioHandler;

  // final _con = StreamController.broadcast<>();

  void onPlayerListenerMixin() {
    audioHandler.player.stream.position.listen((pos) {
      audioHandler.playbackState.add(audioHandler.transformEvent);
    });

    audioHandler.player.stream.duration.listen((duration) {
      audioHandler.playbackState.add(audioHandler.transformEvent);
    });

    audioHandler.player.stream.playbackState.listen((event) {
      audioHandler.playbackState.add(audioHandler.transformEvent);
    });

    audioHandler.player.stream.playbackState.listen((event) {
      // print('playbackState: $event');
      if (event == .completed) {
        audioHandler.songEnd();
      }
    });

    audioHandler.currentNotifier.addListener(
      () => audioHandler._currentAudioChangeContrller.add(
        audioHandler.currentNotifier.value,
      ),
    );
  }

  void onPlayerListenerMixinControllerEvents() {
    audioHandler.allFileStateController.eventStream.listen((event) {
      if (audioHandler.source != .allFileState) return;
      if (event is AllFileAddEvent) {
        audioHandler.playlist.insert(0, event.file);
        audioHandler.playOrder = [...audioHandler.playlist];
      }
      if (event is AllFileRemoveEvent) {
        final index = audioHandler.playlist.indexWhere(
          (e) => e.id == event.file.id,
        );
        if (index == -1) return;
        audioHandler.playlist.removeAt(index);
        audioHandler.playOrder = [...audioHandler.playlist];
      }
    });
  }
}
