extension MusicDurExt on Duration {
  String formatMusicTimer() {
    int sec = inSeconds % 60;
    int mins = inMinutes % 60;
    if (inHours > 0) {
      return '${inHours.toString().padLeft(2, '0')}:${mins.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
    }

    return '${mins.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }
}
