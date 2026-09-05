import 'package:flutter/material.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_sound/ui_platforms/mobile/components/audio_float_widget.dart';
import 'package:than_sound/core/controllers/interfaces/i_controller.dart';
import 'package:than_sound/core/controllers/player_state/player_state_controller.dart';
import 'package:than_sound/ui_platforms/mobile/home/audio_list_page.dart';
import 'package:than_sound/ui_platforms/pages/library/lib_page.dart';
import 'package:than_sound/ui_platforms/pages/music_tracker/music_tracker_page.dart';
import 'package:than_sound/ui_platforms/pages/search/mobile_search_page.dart';
import 'package:than_sound/ui_platforms/pages/more_page.dart';

class MobileHomeScreen extends StatefulWidget {
  const MobileHomeScreen({super.key});

  @override
  State<MobileHomeScreen> createState() => _MobileHomeScreenState();
}

class _MobileHomeScreenState extends State<MobileHomeScreen> {
  @override
  void initState() {
    super.initState();
  }

  int index = 0;
  final con = ControllerManager.read<PlayerStateController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      // extendBody: true,
      body: StreamBuilder(
        stream: con.stream.showFloatingWidgetChanged,
        builder: (context, snapshot) {
          final floatWidgetEnable = con.state.showFloatWidget;
          return Stack(
            children: [
              IndexedStack(
                index: index,
                children: [
                  AudioListPage(),
                  MobileSearchPage(),
                  LibPage(),
                  MusicTrackerPage(),
                  MorePage(),
                ],
              ),

              // float widget
              if (floatWidgetEnable)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0, //kBottomNavigationBarHeight,
                  child: AudioFloatWidget(),
                ),
            ],
          );
        },
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (value) {
          setState(() {
            index = value;
          });
        },
        destinations: [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(
            icon: Icon(Icons.search_outlined),
            label: 'Search',
          ),
          NavigationDestination(
            icon: Icon(Icons.library_music_outlined),
            label: 'Library',
          ),
          NavigationDestination(
            icon: Icon(Icons.track_changes_outlined),
            label: 'Tracker',
          ),
          NavigationDestination(
            icon: Icon(Icons.grid_view_outlined),
            label: 'More',
          ),
        ],
      ),
    );
  }
}
