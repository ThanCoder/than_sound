part of '../player_state_controller.dart';

class PlayerStateEventListener {
  PlayerStateEventListener({required this._controller});

  final PlayerStateController _controller;

  SleepTimer get sleepTimer => _controller.sleepTimer;
  Player get player => _controller.player;
  PlayerState get state => _controller.state;
  PlayerStream get stream => _controller.stream;
  PlayerActions get actions => _controller.actions;

  bool _init = false;

  Timer? _endTimer;

  // Prevent SongEnd from being handled more than once
  // while the previous end operation is still running.
  bool _handlingEnd = false;

  // Prevent duplicate completed events for the same playback.
  bool _completionPending = false;

  Future<void> init() async {
    if (_init) {
      return;
    }

    _init = true;

    // -------------------------------------------------------------------------
    // Position
    // -------------------------------------------------------------------------

    player.stream.position.listen((position) {
      state.position = position;

      stream._con.add(PositionChanged(position));
    });

    // -------------------------------------------------------------------------
    // Duration
    // -------------------------------------------------------------------------

    player.stream.duration.listen((duration) {
      state.duration = duration;

      stream._con.add(DurationChanged(duration));
    });

    // -------------------------------------------------------------------------
    // Playing
    // -------------------------------------------------------------------------

    player.stream.playing.listen((playing) {
      state.playing = playing;

      stream._con.add(PlayingChanged());
    });

    // -------------------------------------------------------------------------
    // Playback state
    // -------------------------------------------------------------------------

    player.stream.playbackState.listen(_onPlaybackState);

    // -------------------------------------------------------------------------
    // Song end
    // -------------------------------------------------------------------------

    stream.end.listen((_) {
      _handleSongEnd();
    });
  }

  // ===========================================================================
  // Playback state
  // ===========================================================================

  void _onPlaybackState(MpvPlaybackState event) {
    if (event == .completed) {
      _scheduleSongEnd();
    }

    if (event == .paused) {
      stream._con.add(SongPause());
    }

    // stream._con.add(PlayerbackState(event));
  }

  // ===========================================================================
  // Completed debounce
  // ===========================================================================

  void _scheduleSongEnd() {
    // Already waiting for the completion debounce.
    if (_completionPending) {
      return;
    }

    // Already processing the previous song.
    if (_handlingEnd) {
      return;
    }

    _completionPending = true;

    _endTimer?.cancel();

    _endTimer = Timer(const Duration(milliseconds: 800), () {
      _completionPending = false;

      final current = state.current;

      if (current == null) {
        return;
      }

      stream._con.add(SongEnd(current));
    });
  }

  // ===========================================================================
  // Song end handler
  // ===========================================================================

  Future<void> _handleSongEnd() async {
    // Don't allow multiple SongEnd handlers to control mpv simultaneously.
    if (_handlingEnd) {
      return;
    }

    _handlingEnd = true;

    try {
      // -----------------------------------------------------------------------
      // Sleep timer
      // -----------------------------------------------------------------------

      if (sleepTimer.onSongCompleted()) {
        await player.pause();
        await player.seek(Duration.zero);

        return;
      }

      // -----------------------------------------------------------------------
      // Loop
      // -----------------------------------------------------------------------

      final loop = state.loop;

      if (loop != .off) {
        // ---------------------------------------------------------------------
        // Repeat current file
        // ---------------------------------------------------------------------

        if (loop == .file) {
          await player.seek(Duration.zero);
          await player.play();

          return;
        }

        // ---------------------------------------------------------------------
        // Repeat playlist
        // ---------------------------------------------------------------------

        if (loop == .playlist) {
          final index = state.currentIndex;

          if (index == -1) {
            return;
          }

          if (state.playOrder.isEmpty) {
            return;
          }

          final nextIndex = (index + 1) % state.playOrder.length;

          final file = state.playOrder[nextIndex];

          await actions.open(file);

          return;
        }
      }

      // -----------------------------------------------------------------------
      // Normal next
      // -----------------------------------------------------------------------

      await actions.next();
    } finally {
      _handlingEnd = false;
    }
  }

  // ===========================================================================
  // Cleanup
  // ===========================================================================

  void dispose() {
    _endTimer?.cancel();
    _endTimer = null;
  }
}
