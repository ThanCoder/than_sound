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
    _setToggleShuffle();
    _controller.state.source = source;
    _controller.stream._con.add(SourceChanged());

    if (files.isEmpty) return;
    if (_controller.state.current == null) {
      await open(files.first, play: false);
      setCurrent(files.first);
    }
  }

  void setCurrent(AudioFile? file) {
    _controller.state.current = file;
    _controller.stream._con.add(CurrentChanged(file));
    if (file != null) {
      _controller.stream._con.add(PlayListChanged(file));
    }
  }

  //*****************Player Actions***************************** */
  Future<void> open(AudioFile file, {bool play = true}) async {
    await _controller.player.open(Media(file.path), play: play);
    setCurrent(file);
    if (play) {
      _controller.stream._con.add(SongStart(file));
      if (!_controller.state.showFloatWidget) {
        _controller.state.showFloatWidget = true;
        _controller.stream._con.add(ShowFloatingWidgetChanged());
      }
    }
  }

  Future<void> pause() async {
    await _controller.player.pause();
  }

  Future<void> stop() async {
    await _controller.player.pause();
    await seek(.zero);
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

  Future<void> prev() async {
    final index = _controller.state.currentIndex;
    if (index == -1) return;
    if ((index - 1) > -1) {
      final file = _controller.state.playOrder[index - 1];
      await open(file);
    }
  }

  Future<void> next() async {
    final index = _controller.state.currentIndex;
    if (index == -1) return;
    if ((index + 1) >= _controller.state.playOrder.length) return;
    final file = _controller.state.playOrder[index + 1];
    await open(file);
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

  void toggleLoop() {
    final values = PlayerLoop.values;

    final index = values.indexOf(_controller.state.loop);
    final nextIndex = (index + 1) % values.length;

    _controller.state.loop = values[nextIndex];
    _controller.stream._con.add(LoopChanged());
    _controller.config.putAndWriteAll(
      audioPlayerLoopKey,
      _controller.state.loop.name,
    );
  }

  void _setToggleShuffle() {
    if (_controller.state.isShuffle) {
      _controller.state.playOrder.shuffle();
    } else {
      _controller.state.playOrder = _controller.state.files;
    }
  }

  void toggleShuffle() {
    _controller.state.isShuffle = !_controller.state.isShuffle;
    _setToggleShuffle();
    _controller.stream._con.add(ShuffleChanged());
    _controller.stream._con.add(PlayListChanged(_controller.state.current!));
    _controller.config.putAndWriteAll(
      audioPlayerShuffleKey,
      _controller.state.isShuffle,
    );
  }

  void setShowFloatingWidget(bool enable) {
    _controller.state.showFloatWidget = enable;
    _controller.stream._con.add(ShowFloatingWidgetChanged());
  }
}
