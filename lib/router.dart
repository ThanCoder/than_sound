import 'package:material_ui/material_ui.dart';
import 'package:than_sound/ui/build_context_x.dart';

import 'package:than_sound/platforms/player_theme_provider/mobile_now_playing_provider_page.dart';

Future<void> goContent(BuildContext context) async {
  context.push(builder: (mainCtx) => MobileNowPlayingProviderPage());
}
