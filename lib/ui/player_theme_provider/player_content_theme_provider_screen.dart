import 'package:dart_core_extensions/dart_core_extensions.dart';
import 'package:flutter/material.dart';
import 'package:than_sound/core/controllers/interfaces/i_controller.dart';
import 'package:than_sound/core/controllers/player/player_state_controller.dart';
import 'package:than_sound/ui/audio/audio_item_menu.dart';
import 'package:than_sound/ui/content/player_playlist.dart';
import 'package:than_sound/ui/player_theme/interfaces/player_ui_context.dart';
import 'package:than_sound/ui_platforms/mobile/content/default_content/default_player_content_theme.dart';
import 'package:than_sound/ui/player_theme/ui_context_creator.dart';
import 'package:than_sound/ui_platforms/mobile/mobile_player_ui_actions.dart';

class PlayerContentThemeProviderScreen extends StatefulWidget {
  const PlayerContentThemeProviderScreen({super.key});

  @override
  State<PlayerContentThemeProviderScreen> createState() =>
      _PlayerContentThemeProviderScreenState();
}

class _PlayerContentThemeProviderScreenState
    extends State<PlayerContentThemeProviderScreen> {
  @override
  void initState() {
    init();
    super.initState();
  }

  PlayerStateController get playerController =>
      ControllerManager.read<PlayerStateController>();
  late PlayerUiContext ctx;
  void init() {
    final pc = playerController;

    ctx = UiContextCreator.create(
      actions: MobilePlayerUiActions(
        playPause: pc.toggle,
        next: pc.next,
        previous: pc.prev,
        seek: pc.seek,
        playlist: showPlayList,
        sleepTimer: () {},
        more: showItemMenu,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: !TPlatform.isDesktop ? null : AppBar(),
      body: SafeArea(
        child: ValueListenableBuilder(
          valueListenable: playerController.current,
          builder: (context, value, child) {
            return DefaultPlayerContentTheme().build(context, ctx);
          },
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Playlist
  // ---------------------------------------------------------------------------

  void showPlayList() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      builder: (context) {
        return FractionallySizedBox(heightFactor: .82, child: PlayerPlaylist());
      },
    );
  }

  void showItemMenu() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      builder: (context) =>
          AudioItemMenu(file: playerController.current.value!),
    );
  }
}
