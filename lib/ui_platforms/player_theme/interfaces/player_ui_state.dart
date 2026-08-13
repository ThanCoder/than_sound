import 'package:than_sound/core/models/audio_file.dart';

class PlayerUiState {
  final AudioFile? current;
  final bool playing;
  final Duration position;
  final Duration duration;

  const PlayerUiState({
    required this.current,
    required this.playing,
    required this.position,
    required this.duration,
  });
}