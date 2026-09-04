import 'dart:async';

import 'package:cfb_store/cfb_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_sound/const_keys.dart';
import 'package:than_sound/core/controllers/interfaces/i_controller.dart';
import 'package:than_sound/core/controllers/player_state/player_state_controller.dart';
import 'package:than_sound/ui_platforms/desktop/home/desktop_list_page.dart';
import 'package:than_sound/ui_platforms/components/sleep_timer/sleep_timer_page.dart';
import 'package:than_sound/ui_platforms/desktop/desktop_music_content_page.dart';
import 'package:than_sound/ui_platforms/pages/music_tracker/music_tracker_page.dart';
import 'package:than_sound/ui_platforms/player_theme/interfaces/player_ui_context.dart';
import 'package:than_sound/ui_platforms/player_theme/ui_context_creator.dart';
import 'package:than_sound/ui_platforms/desktop/desktop_player_ui_actions.dart';
import 'package:than_sound/ui_platforms/pages/library/lib_page.dart';
import 'package:than_sound/ui_platforms/pages/more_page.dart';

class DesktopHomeScreen extends StatefulWidget {
  const DesktopHomeScreen({super.key});

  @override
  State<DesktopHomeScreen> createState() => _DesktopHomeScreenState();
}

class _DesktopHomeScreenState extends State<DesktopHomeScreen> {
  @override
  void dispose() {
    _saveTimer?.cancel();
    focusNode.dispose();
    super.dispose();
  }

  BoxConstraints? constraints;
  Timer? _saveTimer;

  void saveSizeConfig() {
    if (constraints == null) return;
    CFBStore.getInstance
        .put(linuxWindowWidthKey, constraints!.maxWidth)
        .put(linuxWindowHeightKey, constraints!.maxHeight)
        .writeAll();
    debugPrint(
      '[_DesktopHomeScreenState:saveSizeConfig]: Save window size config',
    );
  }

  void saveWindowSizeTimer() {
    _saveTimer?.cancel();
    _saveTimer = Timer(Duration(seconds: 3), () {
      saveSizeConfig();
    });
  }

  @override
  void initState() {
    init();
    super.initState();
  }

  final focusNode = FocusNode();
  late final PlayerStateController playerController =
      ControllerManager.read<PlayerStateController>();
  late PlayerUiContext ctx;
  void init() {
    final pc = playerController;

    ctx = UiContextCreator.create(
      uiActions: DesktopPlayerUiActions(
        playPause: pc.actions.playPause,
        next: pc.actions.next,
        previous: pc.actions.prev,
        seek: pc.actions.seek,
        closeBar: () {
          pc.actions.setShowFloatingWidget(false);
        },
      ),
    );
  }

  int index = 0;

  final pc = ControllerManager.read<PlayerStateController>();

  final pages = const [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      body: LayoutBuilder(
        builder: (context, constraints) {
          this.constraints = constraints;
          saveWindowSizeTimer();
          // print(constraints);
          return keyboardListener();
        },
      ),
    );
  }

  KeyboardListener keyboardListener() {
    return KeyboardListener(
      focusNode: focusNode,
      autofocus: true,
      onKeyEvent: (value) {
        if (value is KeyDownEvent) {
          if (value.logicalKey == .keyF) {}
          if (value.logicalKey == .space) {
            ctx.actions.playPause();
          }
        }
      },
      child: _body(),
    );
  }

  Widget _body() {
    return Row(
      children: [
        _buildNavigation(),

        const VerticalDivider(width: 1),

        Expanded(child: _pages()),

        StreamBuilder(
          stream: playerController.stream.showFloatingWidgetChanged,
          builder: (context, snapshot) {
            final enable = playerController.state.showFloatWidget;
            if (enable) {
              return DesktopMusicContentPage();
            }
            return SizedBox.shrink();
          },
        ),
      ],
    );
  }

  Widget _pages() {
    return IndexedStack(
      index: index,
      children: [
        DesktopListPage(),
        LibPage(),
        MusicTrackerPage(),
        MorePage(),
        SleepTimerPage(),
      ],
    );
  }

  Widget _buildNavigation() {
    return NavigationRail(
      scrollable: true,
      selectedIndex: index,
      onDestinationSelected: (value) {
        setState(() {
          index = value;
        });
      },
      labelType: NavigationRailLabelType.all,
      destinations: const [
        NavigationRailDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: Text('Home'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.library_music_outlined),
          selectedIcon: Icon(Icons.library_music),
          label: Text('Library'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.track_changes_outlined),
          selectedIcon: Icon(Icons.track_changes_rounded),
          label: Text('Tracker'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.grid_view_outlined),
          selectedIcon: Icon(Icons.grid_view_rounded),
          label: Text('More'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.timer),
          selectedIcon: Icon(Icons.timer_rounded),
          label: Text('Sleep Timer'),
        ),
      ],
    );
  }
}
