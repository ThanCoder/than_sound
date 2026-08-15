import 'dart:async';

import 'package:cfb_store/cfb_store.dart';
import 'package:flutter/material.dart';
import 'package:than_sound/const_keys.dart';
import 'package:than_sound/core/controllers/interfaces/i_controller.dart';
import 'package:than_sound/core/controllers/player/player_state_controller.dart';
import 'package:than_sound/ui_platforms/components/current_music_visualizer_widget.dart';
import 'package:than_sound/ui_platforms/desktop/components/desktop_list_page.dart';
import 'package:than_sound/ui_platforms/player_theme/interfaces/player_ui_context.dart';
import 'package:than_sound/ui_platforms/player_theme/ui_context_creator.dart';
import 'package:than_sound/ui_platforms/desktop/components/desktop_music_bar.dart';
import 'package:than_sound/ui_platforms/desktop/desktop_player_ui_actions.dart';
import 'package:than_sound/ui_platforms/mobile/lib_page.dart';
import 'package:than_sound/ui_platforms/mobile/home/more_page.dart';

class DesktopHomeScreen extends StatefulWidget {
  const DesktopHomeScreen({super.key});

  @override
  State<DesktopHomeScreen> createState() => _DesktopHomeScreenState();
}

class _DesktopHomeScreenState extends State<DesktopHomeScreen> {
  @override
  void dispose() {
    _saveTimer?.cancel();
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
  }

  void saveTimer() {
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

  PlayerStateController get playerController =>
      ControllerManager.read<PlayerStateController>();
  late PlayerUiContext ctx;
  void init() {
    final pc = playerController;

    ctx = UiContextCreator.create(
      actions: DesktopPlayerUiActions(
        playPause: pc.toggle,
        next: pc.next,
        previous: pc.prev,
        seek: pc.seek,
      ),
    );

    //   playlist: showPlayList,
    //   sleepTimer: () {},
    //   more: (){},
  }

  int index = 0;

  final pc = ControllerManager.read<PlayerStateController>();

  final pages = const [
    // AudioListPage(listGpsButtonBottomPos: 10),
    LibPage(),
    MorePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        this.constraints = constraints;

        // print(constraints);
        return Scaffold(
          body: Column(
            children: [
              _body(),

              //music bar
              _musicBar(),
            ],
          ),
        );
      },
    );
  }

  Expanded _body() {
    return Expanded(
      child: Row(
        children: [
          _buildNavigation(),

          const VerticalDivider(width: 1),

          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 1000),
                child: IndexedStack(
                  index: index,
                  children: [DesktopListPage(), ...pages],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigation() {
    return NavigationRail(
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
          icon: Icon(Icons.grid_view_outlined),
          selectedIcon: Icon(Icons.grid_view_rounded),
          label: Text('More'),
        ),
      ],
    );
  }

  Widget _musicBar() {
    return StreamBuilder(
      stream: ctx.streams.playlist,
      builder: (context, asyncSnapshot) {
        // return SizedBox.shrink();
        if (ctx.state().current == null) {
          return SizedBox.shrink();
        }
        return ValueListenableBuilder(
          valueListenable: pc.showFloatWidget,
          builder: (context, value, child) {
            if (!pc.showFloatWidget.value) {
              return Row(
                mainAxisAlignment: .end,
                children: [
                  GestureDetector(
                    onTap: () {
                      pc.showFloatWidget.value = true;
                    },
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: Container(
                        padding: .all(5),
                        decoration: BoxDecoration(borderRadius: .circular(15)),
                        child: CurrentMusicVisualizerWidget(),
                      ),
                    ),
                  ),
                ],
              );
            }
            return DesktopMusicBar(
              uiContext: ctx,
              closeBar: () {
                pc.showFloatWidget.value = false;
              },
            );
          },
        );
      },
    );
  }
}
