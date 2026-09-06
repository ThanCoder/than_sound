import 'package:dart_core_extensions/dart_core_extensions.dart';
import 'package:flutter/material.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_sound/core/controllers/interfaces/i_controller.dart';
import 'package:than_sound/core/controllers/player_state/player_state_controller.dart';
import 'package:than_sound/ui_platforms/components/sleep_timer/sleep_timer_page.dart';
import 'package:than_sound/ui_platforms/components/sound_volume_menu.dart';
import 'package:than_sound/ui_platforms/components/audio_item_menu.dart';
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

  final PlayerStateController pc =
      ControllerManager.read<PlayerStateController>();
  late PlayerUiContext ctx;
  void init() {
    ctx = UiContextCreator.create(
      uiActions: MobilePlayerUiActions(
        playPause: pc.actions.playPause,
        next: pc.actions.next,
        previous: pc.actions.prev,
        seek: pc.actions.seek,
        playlist: showPlayList,
        sleepTimer: goSleepTimerPage,
        more: showItemMenu,
        volume: showVolumeMenu,
      ),
    );
  }

  final currentTheme = MobileDefaultPlayerContentTheme();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: !TPlatform.isDesktop ? null : AppBar(),
      body: StreamBuilder(
        stream: pc.stream.current,
        builder: (context, snapshot) {
          return currentTheme.build(context, ctx);
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
      builder: (context) =>
          AudioItemMenu(file: pc.state.current!, showContentAnimation: true),
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

  void goSleepTimerPage() {
    context.pushMaterialPageRoute(builder: (mainCtx) => SleepTimerPage());
  }
}
