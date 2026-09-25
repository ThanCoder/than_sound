import 'package:flutter/material.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_sound/core/controllers/interfaces/i_controller.dart';
import 'package:than_sound/core/controllers/player_state/player_state_controller.dart';
import 'package:than_sound/ui_platforms/components/sleep_timer/sleep_timer_page.dart';
import 'package:than_sound/ui_platforms/desktop/home/desktop_list_page.dart';
import 'package:than_sound/ui_platforms/pages/music_tracker/music_tracker_page.dart';
import 'package:than_sound/ui_platforms/pages/share_server/server_home_page.dart';
import 'package:than_sound/ui_platforms/pages/library/lib_home_page.dart';
import 'package:than_sound/ui_platforms/pages/more_page.dart';

class DesktopHomeScreen extends StatefulWidget {
  const DesktopHomeScreen({super.key});

  @override
  State<DesktopHomeScreen> createState() => _DesktopHomeScreenState();
}

class _DesktopHomeScreenState extends State<DesktopHomeScreen> {
  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }

  final focusNode = FocusNode();
  late final PlayerStateController playerController =
      ControllerManager.read<PlayerStateController>();

  int index = 0;

  final pc = ControllerManager.read<PlayerStateController>();

  final pages = const [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      body: _body(),
    );
  }

  // KeyboardListener keyboardListener() {
  //   return KeyboardListener(
  //     focusNode: focusNode,
  //     autofocus: true,
  //     onKeyEvent: (value) {
  //       if (value is KeyDownEvent) {
  //         if (value.logicalKey == .keyF) {}
  //         if (value.logicalKey == .space) {
  //           ctx.actions.playPause();
  //         }
  //       }
  //     },
  //     child: _body(),
  //   );
  // }

  Widget _body() {
    return Row(
      children: [
        _buildNavigation(),

        const VerticalDivider(width: 1),

        Expanded(child: _pages()),
      ],
    );
  }

  Widget _pages() {
    return IndexedStack(
      index: index,
      children: [
        DesktopListPage(),
        LibHomePage(),
        MusicTrackerPage(),
        MorePage(),
        SleepTimerPage(),
        ServerHomePage(),
      ],
    );
  }

  Widget _buildNavigation() {
    return NavigationRail(
      labelType: NavigationRailLabelType.all,
      scrollable: true,
      selectedIndex: index,
      onDestinationSelected: (value) {
        setState(() {
          index = value;
        });
      },
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
        .new(icon: Icon(Icons.share), label: Text('Share Server')),
      ],
    );
  }
}
