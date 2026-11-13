import 'package:mpv_audio_kit/mpv_audio_kit.dart';
import 'package:than_sound/core/models/audio_file.dart';

class PlayerUiStreams {
  final Stream<bool> playing;
  final Stream<Duration> position;
  final Stream<Duration> duration;
  final PlayerStream playerStream;
  final Stream<AudioFile?> playlist;

  const PlayerUiStreams({
    required this.playing,
    required this.position,
    required this.duration,
    required this.playlist,
    required this.playerStream,
  });
}
