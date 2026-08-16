enum SleepTimerMode {
  none,
  duration, // 30 minutes
  endOfTrack, // လက်ရှိသီချင်းပြီးရင်
  endOfPlaylist; // playlist ပြီးရင်

  String get lable {
    if (this == duration) return 'Duration';
    if (this == endOfTrack) return 'End Of Track';
    if (this == endOfPlaylist) return 'End Of Playlist';
    return 'None';
  }

  static SleepTimerMode fromValue(String val) {
    return values.firstWhere((e) => e.name == val, orElse: () => none);
  }
}
