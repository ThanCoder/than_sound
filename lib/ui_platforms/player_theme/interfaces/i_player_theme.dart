import 'package:flutter/material.dart';
import 'package:than_sound/ui_platforms/player_theme/interfaces/player_ui_context.dart';

abstract class IPlayerTheme {
  const IPlayerTheme();

  Widget build(BuildContext context, PlayerUiContext ctx);
}
