part of '../player_state_controller.dart';

class PlayerStateEventListener {
  final Player player;
  final PlayerState state;
  final PlayerStream stream;
  final PlayerActions actions;
  final MyAudioHandler audioHandler;
  const PlayerStateEventListener({
    required this.player,
    required this.state,
    required this.stream,
    required this.actions,
    required this.audioHandler,
  });

  Future<void> init() async {
    player.stream.playbackState.listen(
      (event) => stream._con.add(PlaybackState(event)),
    );
    player.stream.position.listen((e) => stream._con.add(PositionChanged(e)));
    player.stream.duration.listen((e) => stream._con.add(DurationChanged(e)));
    player.stream.playing.listen((e) {
      state.playing = e;
      stream._con.add(PlayingChanged());
    });
  }
}
