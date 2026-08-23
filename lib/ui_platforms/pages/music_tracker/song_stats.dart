class SongStats {
  final String trackId;

  /// Total time the user actually listened.
  Duration listened;

  /// Number of times playback started.
  int playCount;

  /// Number of times playback completed.
  int completionCount;

  /// First time this song was played.
  DateTime? firstPlayedAt;

  /// Last time this song was played.
  DateTime? lastPlayedAt;

  SongStats({
    required this.trackId,
    this.listened = Duration.zero,
    this.playCount = 0,
    this.completionCount = 0,
    this.firstPlayedAt,
    this.lastPlayedAt,
  });

  SongStats copyWith({
    String? trackId,
    Duration? listened,
    int? playCount,
    int? completionCount,
    DateTime? firstPlayedAt,
    DateTime? lastPlayedAt,
  }) {
    return SongStats(
      trackId: trackId ?? this.trackId,
      listened: listened ?? this.listened,
      playCount: playCount ?? this.playCount,
      completionCount: completionCount ?? this.completionCount,
      firstPlayedAt: firstPlayedAt ?? this.firstPlayedAt,
      lastPlayedAt: lastPlayedAt ?? this.lastPlayedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'trackId': trackId,
      'listened': listened.inSeconds,
      'playCount': playCount,
      'completionCount': completionCount,
      'firstPlayedAt': firstPlayedAt?.millisecondsSinceEpoch,
      'lastPlayedAt': lastPlayedAt?.millisecondsSinceEpoch,
    };
  }

  factory SongStats.fromMap(Map<String, dynamic> map) {
    return SongStats(
      trackId: map['trackId'] as String,
      listened: Duration(seconds: map['listened'] ?? 0),
      playCount: map['playCount'] as int,
      completionCount: map['completionCount'] as int,
      firstPlayedAt: map['firstPlayedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['firstPlayedAt'] as int)
          : null,
      lastPlayedAt: map['lastPlayedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['lastPlayedAt'] as int)
          : null,
    );
  }

  @override
  String toString() {
    return 'SongStats(trackId: $trackId, listened: $listened, playCount: $playCount, completionCount: $completionCount, firstPlayedAt: $firstPlayedAt, lastPlayedAt: $lastPlayedAt)';
  }
}
