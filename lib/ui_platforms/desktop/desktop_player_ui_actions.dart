import 'dart:ui';

import 'package:than_sound/ui_platforms/player_theme/interfaces/player_ui_actions.dart';

class DesktopPlayerUiActions extends PlayerUiActions {
  final VoidCallback closeBar;
  DesktopPlayerUiActions({
    required super.playPause,
    required super.next,
    required super.previous,
    required super.seek,
    required this.closeBar,
  });
}
