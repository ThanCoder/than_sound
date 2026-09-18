import 'package:flutter/material.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_sound/ui_platforms/player_theme_provider/mobile_now_playing_provider_page.dart';

Future<void> goContent(BuildContext context) async {
  context.pushMaterialPageRoute(
    builder: (mainCtx) => MobileNowPlayingProviderPage(),
  );
}
