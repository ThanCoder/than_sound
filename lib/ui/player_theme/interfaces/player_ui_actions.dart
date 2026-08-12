import 'package:flutter/material.dart';

class PlayerUiActions {
  final VoidCallback playPause;
  final VoidCallback next;
  final VoidCallback previous;

  final ValueChanged<Duration> seek;

  final VoidCallback playlist;
  final VoidCallback sleepTimer;
  final VoidCallback more;

  const PlayerUiActions({
    required this.playPause,
    required this.next,
    required this.previous,
    required this.seek,
    required this.playlist,
    required this.sleepTimer,
    required this.more,
  });
}
