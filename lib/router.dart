import 'package:flutter/material.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_sound/ui_platforms/player_theme_provider/player_content_theme_provider_screen.dart';

Future<void> goContent(BuildContext context) async {
  context.pushMaterialPageRoute(
    builder: (mainCtx) => PlayerContentThemeProviderScreen(),
  );
}
