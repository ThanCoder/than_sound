import 'dart:io';

import 'package:flutter/material.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_pkg_android/than_pkg_android.dart';
import 'package:than_sound/ui_platforms/mobile/components/audio_float_widget.dart';
import 'package:than_sound/core/controllers/interfaces/i_controller.dart';
import 'package:than_sound/core/controllers/player/player_state_controller.dart';
import 'package:than_sound/ui_platforms/components/favourite/favourite_controller.dart';
import 'package:than_sound/ui_platforms/mobile/home/audio_list_page.dart';
import 'package:than_sound/ui_platforms/mobile/home/library/lib_page.dart';
import 'package:than_sound/ui_platforms/mobile/home/search/mobile_search_page.dart';
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
    init();
  }

  void init() async {
    try {
      if (Platform.isAndroid) {
        final pkg = ThanPkgAndroid.getInstance.storagePermissionHandler;
        if (!await pkg.isStoragePermissionGranted()) {
          ControllerManager.read<FavouriteController>().needToRefetch = true;
          await pkg.requestStoragePermission();

          return;
        }
      }
    } catch (e) {
      if (!mounted) return;
      showTMessageDialogError(context, e.toString());
    }
  }

  int index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      extendBody: true,
      body: ValueListenableBuilder(
        valueListenable:
            ControllerManager.read<PlayerStateController>().showFloatWidget,
        builder: (context, floatWidgetEnable, child) {
          return Stack(
            children: [
              IndexedStack(
                index: index,
                children: [
                  AudioListPage(),
                  MobileSearchPage(),
                  LibPage(),
                  MorePage(),
                ],
              ),

              // float widget
              if (floatWidgetEnable)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: kBottomNavigationBarHeight,
                  child: AudioFloatWidget(),
                ),
            ],
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: context.colorScheme.surfaceContainer,
        selectedItemColor: context.colorScheme.primary,
        unselectedItemColor: context.colorScheme.onSurfaceVariant,
        currentIndex: index,
        onTap: (value) {
          setState(() {
            index = value;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search_outlined),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_music_outlined),
            label: 'Library',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view_outlined),
            label: 'More',
          ),
        ],
      ),
    );
  }
}
