enum PlayerLoop {
  /// No looping: `loop-file=no` and `loop-playlist=no`. Playback stops
  /// after the last track of the playlist.
  off,

  /// Loop the currently playing file: `loop-file=inf`,
  /// `loop-playlist=no`.
  file,

  /// Loop the entire playlist: `loop-file=no`, `loop-playlist=inf`.
  playlist;

  static PlayerLoop fromValue(String val) {
    return values.firstWhere((e) => e.name == val, orElse: () => playlist);
  }
}
