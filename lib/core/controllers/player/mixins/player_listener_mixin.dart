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
    audioHandler.allFileStateController.eventStream
        .whereType<AllFileStateControllerUpdateMeta>()
        .listen((event) {
          final current = audioHandler.currentNotifier.value;
          if (current != null && current.path == event.file.path) {
            audioHandler.currentNotifier.value = event.file;
            audioHandler._currentAudioChangeContrller.add(event.file);
          }

          final indexPl = audioHandler.playlist.indexWhere(
            (e) => e.path == event.file.path,
          );
          if (indexPl != -1) {
            audioHandler.playlist[indexPl] = event.file;
          }
          final indexPr = audioHandler.playOrder.indexWhere(
            (e) => e.path == event.file.path,
          );
          if (indexPr != -1) {
            audioHandler.playOrder[indexPr] = event.file;
          }
        });

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
