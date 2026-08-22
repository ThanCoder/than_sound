class ListeningStats {
  Duration totalListeningTime;
  int totalPlayCount;

  DateTime? firstPlayedAt;
  DateTime? lastPlayedAt;

  ListeningStats({
    this.totalListeningTime = Duration.zero,
    this.totalPlayCount = 0,
    this.firstPlayedAt,
    this.lastPlayedAt,
  });
}
