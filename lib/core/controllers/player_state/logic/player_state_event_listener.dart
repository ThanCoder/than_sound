part of '../player_state_controller.dart';

class PlayerStateEventListener {
  PlayerStateEventListener({required this._controller});
  final PlayerStateController _controller;

  SleepTimer get sleepTimer => _controller.sleepTimer;
  Player get player => _controller.player;
  PlayerState get state => _controller.state;
  PlayerStream get stream => _controller.stream;
  PlayerActions get actions => _controller.actions;

  bool _init = false;

  Future<void> init() async {
    if (_init) return;
    _init = true;

    player.stream.position.listen((e) {
      state.position = e;
      stream._con.add(PositionChanged(e));
    });
    player.stream.duration.listen((e) {
      state.duration = e;
      stream._con.add(DurationChanged(e));
    });
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
        await player.seek(Duration.zero);
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
          final nextIndex = (index + 1) % state.playOrder.length;
          final file = state.playOrder[nextIndex];
          await actions.open(file);
          return;
        }
      }

      await actions.next();
    });
  }
}
