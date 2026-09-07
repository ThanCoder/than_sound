part of 'player_state_controller.dart';

class PlayerStream {
  final _con = StreamController<PlayerStateEvent>.broadcast();

  Stream<PlayerStateEvent> get all => _con.stream;
  Stream<CurrentChanged> get current => all.whereType<CurrentChanged>();
  Stream<SourceChanged> get sourceChanged => all.whereType<SourceChanged>();
  Stream<PlayingChanged> get playing => all.whereType<PlayingChanged>();
  Stream<PlaybackState> get playbackState => all.whereType<PlaybackState>();
  Stream<ShuffleChanged> get shuffle => all.whereType<ShuffleChanged>();
  Stream<ShowFloatingWidgetChanged> get showFloatingWidgetChanged =>
      all.whereType<ShowFloatingWidgetChanged>();

  Stream<PositionChanged> get position => all.whereType<PositionChanged>();
  Stream<DurationChanged> get duration => all.whereType<DurationChanged>();
  Stream<PlayListChanged> get playlist => all.whereType<PlayListChanged>();
  Stream<SongPlay> get play => all.whereType<SongPlay>();
  Stream<SongPause> get pause => all.whereType<SongPause>();
  Stream<SongEnd> get end => all.whereType<SongEnd>();
  Stream<SongStart> get start => all.whereType<SongStart>();
  Stream<SongStop> get stop => all.whereType<SongStop>();
  Stream<LoopChanged> get loop => all.whereType<LoopChanged>();
  Stream<PlayOrderChanged> get playOrder => all.whereType<PlayOrderChanged>();
}

extension PlayerStateEventExt on Stream<PlayerStateEvent> {
  Stream<T> whereType<T>() {
    return where((e) => e is T).cast<T>();
  }
}
