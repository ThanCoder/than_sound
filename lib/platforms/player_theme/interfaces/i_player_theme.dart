import 'package:material_ui/material_ui.dart';
import 'package:than_sound/platforms/player_theme/interfaces/player_ui_context.dart';

abstract class IPlayerTheme {
  const IPlayerTheme();

  Widget build(BuildContext context, PlayerUiContext ctx);
}
