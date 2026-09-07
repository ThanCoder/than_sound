part of 'player_state_controller.dart';

class PlayerState {
  final Player player;
  PlayerState(this.player);

  AudioFile? current;
  List<AudioFile> files = [];
  List<AudioFile> playOrder = [];
  bool playing = false;
  bool pause = false;
  bool stop = false;
  bool end = false;
  bool isShuffle = false;
  bool showFloatWidget = false;
  AudioFileSource source = NoneAudioSource();
  Duration duration = .new(seconds: 0);
  Duration position = .new(seconds: 0);
  PlayerLoop loop = .playlist;
  double audioVolume = 100;
  //fade
  final Duration fadeDuration = Duration(milliseconds: 500);
  final int fadeSteps = 20;

  int get currentIndex {
    if (current == null) return -1;
    return playOrder.indexWhere((e) => e.path == current!.path);
  }

  bool get isNextSong {
    final index = currentIndex;
    if (index == -1) return false;
    return index + 1 < playOrder.length;
  }

  bool get isPrevSong {
    final index = currentIndex;
    if (index == -1) return false;
    return index > 0;
  }
}
