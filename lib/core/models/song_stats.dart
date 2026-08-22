class SongStats {
  final int trackId;

  /// Total time the user actually listened
  Duration listened;

  /// Number of times playback started
  int playCount;

  /// Number of times playback completed
  int completionCount;

  /// Last time this song was played
  DateTime? lastPlayedAt;

  SongStats({
    required this.trackId,
    this.listened = Duration.zero,
    this.playCount = 0,
    this.completionCount = 0,
    this.lastPlayedAt,
  });
}
