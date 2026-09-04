// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'player_state_controller.dart';

class PlayerActions {
  final PlayerStateController _controller;

  const PlayerActions({required this._controller});

  Future<void> setTracks(
    List<AudioFile> files, {
    required AudioFileSourceType source,
  }) async {
    _controller.state.files = files;
    _controller.state.playOrder = files;
    _controller.state.source = source;
    _controller.stream._con.add(SourceChanged());
  }

  void setCurrent(AudioFile? file) {
    _controller.state.current = file;
    _controller.stream._con.add(CurrentChanged(file));
  }

  //*****************Player Actions***************************** */
  Future<void> open(AudioFile file, {bool play = true}) async {
    await _controller.player.open(Media(file.path), play: play);
    setCurrent(file);
  }

  void toggleShuffle() {
    _controller.state.isShuffle = !_controller.state.isShuffle;
    if (_controller.state.isShuffle) {
      _controller.state.playOrder.shuffle();
    } else {
      _controller.state.playOrder = _controller.state.files;
    }
    _controller.stream._con.add(ShuffleChanged());
    _controller.stream._con.add(PlayListChanged());
  }

  void setShowFloatingWidget(bool enable) {
    _controller.state.showFloatWidget = enable;
    _controller.stream._con.add(ShowFloatingWidgetChanged());
  }

  Future<void> pause() async {
    await _controller.player.pause();
  }

  Future<void> stop() async {
    await _controller.player.stop();
  }

  Future<void> play() async {
    await _controller.player.play();
  }

  Future<void> playPause() async {
    if (_controller.state.playing) {
      await pause();
    } else {
      await play();
    }
  }

  Future<void> next() async {
    final index = _controller.state.currentIndex;
    if (index == -1) return;
    if ((index + 1) >= _controller.state.playOrder.length) return;
    open(_controller.state.playOrder[index + 1]);
  }

  Future<void> prev() async {
    final index = _controller.state.currentIndex;
    if (index == -1) return;
    if ((index - 1) > -1) {
      open(_controller.state.playOrder[index - 1]);
    }
  }

  Future<void> seek(Duration position) async {
    await _controller.player.seek(position);
  }

  //*****************Fav***************************** */
  FavouriteController get _favController =>
      ControllerManager.read<FavouriteController>();
  void addFav() {
    if (_controller.state.current == null) return;
    _favController.add(_controller.state.current!);
  }

  void removeFav() {
    if (_controller.state.current == null) return;
    _favController.remove(_controller.state.current!);
  }
}
