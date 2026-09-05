part of 'player_state_controller.dart';

sealed class PlayerStateEvent {
  const PlayerStateEvent();
}

class SongPlay extends PlayerStateEvent {}

class SongPause extends PlayerStateEvent {}

class SourceChanged extends PlayerStateEvent {}

class CurrentChanged extends PlayerStateEvent {
  final AudioFile? file;
  const CurrentChanged(this.file);
}

class PlayStateChanged extends PlayerStateEvent {}

class ShuffleChanged extends PlayerStateEvent {}

class ShowFloatingWidgetChanged extends PlayerStateEvent {}

class PositionChanged extends PlayerStateEvent {
  final Duration position;
  const PositionChanged(this.position);
}

class DurationChanged extends PlayerStateEvent {
  final Duration duration;
  const DurationChanged(this.duration);
}

class PlaybackState extends PlayerStateEvent {
  final MpvPlaybackState state;
  const PlaybackState(this.state);
}

class PlayingChanged extends PlayerStateEvent {}

class PlayListChanged extends PlayerStateEvent {
  final AudioFile file;
  const PlayListChanged(this.file);
}

class SongEnd extends PlayerStateEvent {
  final AudioFile file;
  const SongEnd(this.file);
}

class SongStart extends PlayerStateEvent {
  final AudioFile file;
  const SongStart(this.file);
}

class SongStop extends PlayerStateEvent {
  final AudioFile file;
  const SongStop(this.file);
}

class LoopChanged extends PlayerStateEvent {
  
}