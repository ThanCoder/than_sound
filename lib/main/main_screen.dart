import 'dart:io';

import 'package:flutter/material.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_pkg_android/than_pkg_android.dart';
import 'package:than_sound/audio/audio_float_widget.dart';
import 'package:than_sound/core/controllers/i_controller.dart';
import 'package:than_sound/core/controllers/player/player_state_controller.dart';
import 'package:than_sound/main/audio_list_page.dart';
import 'package:than_sound/main/more_page.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
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
      extendBody: true,
      body: ValueListenableBuilder(
        valueListenable: context.read<PlayerStateController>().showFloatWidget,
        builder: (context, value, child) {
          return Stack(
            children: [
              IndexedStack(
                index: index,
                children: [AudioListPage(), MorePage()],
              ),

              // float widget
              if (value)
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
        currentIndex: index,
        onTap: (value) {
          setState(() {
            index = value;
          });
        },
        selectedItemColor: Colors.blue,
        unselectedItemColor: context.isDarkMode ? Colors.white : Colors.black,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view_rounded),
            label: 'More',
          ),
        ],
      ),
    );
  }
}
