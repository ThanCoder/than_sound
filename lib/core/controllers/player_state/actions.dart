// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'player_state_controller.dart';

class PlayerActions {
  final PlayerStateController _controller;

  PlayerActions({required this._controller});

  Player get player => _controller.player;
  PlayerState get state => _controller.state;

  late final _fadeController = PlayerFadeController(_controller);

  // ---------------------------------------------------------------------------
  // Track / playlist
  // ---------------------------------------------------------------------------

  Future<void> setTracks(
    List<AudioFile> files, {
    required AudioFileSource source,
  }) async {
    if (_controller.state.source.isSome(source)) {
      return;
    }

    _controller.state.files = files;

    _setToggleShuffle();

    _controller.state.source = source;
    _controller.stream._con.add(SourceChanged());

    if (files.isEmpty) {
      return;
    }

    if (_controller.state.current == null) {
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

  // ---------------------------------------------------------------------------
  // Track opening
  // ---------------------------------------------------------------------------

  Future<void> _openQueue = Future<void>.value();

  Future<void> open(AudioFile file, {bool play = true}) {
    // A track transition should cancel any currently running fade.
    _fadeController.cancel();

    final future = _openQueue.then((_) => _openInternal(file, play: play));

    _openQueue = future.then<void>((_) {}, onError: (_, _) {});

    return future;
  }

  Future<void> _openInternal(AudioFile file, {required bool play}) async {
    await _controller.player.open(Media(file.path), play: play);

    setCurrent(file);

    if (!play) {
      return;
    }

    _controller.stream._con.add(SongStart(file));

    if (!_controller.state.showFloatWidget) {
      _controller.state.showFloatWidget = true;

      _controller.stream._con.add(ShowFloatingWidgetChanged());
    }
  }

  // ---------------------------------------------------------------------------
  // Playback
  // ---------------------------------------------------------------------------

  Future<void> pause() async {
    if (!_controller.state.playing) {
      return;
    }

    // await _fadeController.fadeOut();

    // Fade may have been cancelled while waiting.
    // if (_fadeController.isCancelled) {
    //   return;
    // }

    await _controller.player.pause();
  }

  Future<void> play() async {
    if (_controller.state.playing) {
      return;
    }

    // await _fadeController.fadeIn();
    await _controller.player.play();
  }

  Future<void> stop() async {
    _fadeController.cancel();

    await _controller.player.pause();

    await seek(Duration.zero);

    // Make sure the next play starts with the normal volume.
    await _controller.player.setVolume(_controller.state.audioVolume);
  }

  Future<void> playPause() async {
    if (_controller.state.playing) {
      await pause();
    } else {
      await play();
    }
  }

  // ---------------------------------------------------------------------------
  // Navigation
  // ---------------------------------------------------------------------------

  Future<void> prev() async {
    _fadeController.cancel();

    final index = _controller.state.currentIndex;

    if (index == -1) {
      return;
    }

    final previousIndex = index - 1;

    if (previousIndex < 0) {
      return;
    }

    final file = _controller.state.playOrder[previousIndex];

    await open(file);
  }

  Future<void> next() async {
    _fadeController.cancel();

    final index = _controller.state.currentIndex;

    if (index == -1) {
      return;
    }

    final nextIndex = index + 1;

    if (nextIndex >= _controller.state.playOrder.length) {
      return;
    }

    final file = _controller.state.playOrder[nextIndex];

    await open(file);
  }

  Future<void> seek(Duration position) async {
    await _controller.player.seek(position);
  }

  // ---------------------------------------------------------------------------
  // Favourite
  // ---------------------------------------------------------------------------

  FavouriteController get _favController =>
      ControllerManager.read<FavouriteController>();

  void addFav() {
    final current = _controller.state.current;

    if (current == null) {
      return;
    }

    _favController.add(current);
  }

  void removeFav() {
    final current = _controller.state.current;

    if (current == null) {
      return;
    }

    _favController.remove(current);
  }

  // ---------------------------------------------------------------------------
  // Loop
  // ---------------------------------------------------------------------------

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

  // ---------------------------------------------------------------------------
  // Shuffle
  // ---------------------------------------------------------------------------

  void _setToggleShuffle() {
    if (_controller.state.isShuffle) {
      _controller.state.playOrder = List.of(_controller.state.files)..shuffle();
    } else {
      _controller.state.playOrder = List.of(_controller.state.files);
    }
    _controller.stream._con.add(PlayOrderChanged());
  }

  void toggleShuffle() {
    _controller.state.isShuffle = !_controller.state.isShuffle;

    _setToggleShuffle();

    _controller.stream._con.add(ShuffleChanged());

    final current = _controller.state.current;

    if (current != null) {
      _controller.stream._con.add(PlayListChanged(current));
    }

    _controller.config.putAndWriteAll(
      audioPlayerShuffleKey,
      _controller.state.isShuffle,
    );
  }

  // ---------------------------------------------------------------------------
  // Floating player
  // ---------------------------------------------------------------------------

  void setShowFloatingWidget(bool enable) {
    _controller.state.showFloatWidget = enable;

    _controller.stream._con.add(ShowFloatingWidgetChanged());
  }
}
