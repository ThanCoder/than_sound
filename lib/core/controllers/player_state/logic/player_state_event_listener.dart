part of '../player_state_controller.dart';

class PlayerStateEventListener {
  PlayerStateEventListener({
    required this.player,
    required this.state,
    required this.stream,
    required this.actions,
    required this.audioHandler,
    required this.sleepTimer,
  });
  final Player player;
  final PlayerState state;
  final PlayerStream stream;
  final PlayerActions actions;
  final MyAudioHandler audioHandler;
  final SleepTimer sleepTimer;

  bool _init = false;

  Future<void> init() async {
    if (_init) return;
    _init = true;

    player.stream.position.listen((e) => stream._con.add(PositionChanged(e)));
    player.stream.duration.listen((e) => stream._con.add(DurationChanged(e)));
    player.stream.playing.listen((e) {
      state.playing = e;
      stream._con.add(PlayingChanged());
    });

    Timer? endTimer;
    int endCount = 0;
    player.stream.playbackState.listen((event) {
      if (event == .completed) {
        endCount++;
        endTimer?.cancel();
        endTimer = Timer(Duration(milliseconds: 800), () {
          endCount--;
          if (endCount != 0) return;
          stream._con.add(SongEnd(state.current!));
        });
      }
      if (event == .paused) {
        stream._con.add(SongPause());
      }
      stream._con.add(PlaybackState(event));
    });

    stream.end.listen((event) async {
      // timer
      if (sleepTimer.onSongCompleted()) {
        await player.pause();
        return;
      }
      //loop
      if (state.loop != .off) {
        if (state.loop == PlayerLoop.file) {
          await player.seek(Duration.zero);
          await player.play();
          return;
        }
        if (state.loop == .playlist) {
          final index = state.currentIndex;
          if (index == -1) return;
          if (index == state.playOrder.length -1) {
            final file = state.playOrder.first;
            await actions.open(file);
            return;
          }
        }
      }

      await actions.next();
    });
  }
}
