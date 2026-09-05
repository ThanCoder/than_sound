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
  AudioFileSourceType source = .none;
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
}
