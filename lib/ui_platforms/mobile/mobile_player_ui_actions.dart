import 'package:flutter/material.dart';
import 'package:than_sound/ui/player_theme/interfaces/player_ui_actions.dart';

class MobilePlayerUiActions extends PlayerUiActions {
  final VoidCallback playlist;
  final VoidCallback sleepTimer;
  final VoidCallback more;

  MobilePlayerUiActions({
    required super.playPause,
    required super.next,
    required super.previous,
    required super.seek,
    required this.playlist,
    required this.sleepTimer,
    required this.more,
  });
}
