import 'package:dart_core_extensions/dart_core_extensions.dart';
import 'package:flutter/material.dart';
import 'package:than_sound/core/controllers/interfaces/i_controller.dart';
import 'package:than_sound/core/controllers/player/player_state_controller.dart';
import 'package:than_sound/ui_platforms/mobile/components/sound_volume_menu.dart';
import 'package:than_sound/ui_platforms/mobile/components/audio_item_menu.dart';
import 'package:than_sound/ui_platforms/components/player_playlist.dart';
import 'package:than_sound/ui_platforms/player_theme/interfaces/player_ui_context.dart';
import 'package:than_sound/ui_platforms/mobile/content/default_content/mobile_default_player_content_theme.dart';
import 'package:than_sound/ui_platforms/player_theme/ui_context_creator.dart';
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

  final PlayerStateController playerController =
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
        volume: showVolumeMenu,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: !TPlatform.isDesktop ? null : AppBar(),
      body: ValueListenableBuilder(
        valueListenable: playerController.current,
        builder: (context, value, child) {
          return MobileDefaultPlayerContentTheme().build(context, ctx);
        },
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
        return FractionallySizedBox(heightFactor: .90, child: PlayerPlaylist());
      },
    );
  }

  void showItemMenu() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      builder: (context) => AudioItemMenu(
        file: playerController.current.value!,
        showContentAnimation: true,
      ),
    );
  }

  void showVolumeMenu() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      builder: (context) => SoundVolumeMenu(),
    );
  }
}
