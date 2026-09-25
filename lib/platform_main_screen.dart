import 'dart:async';

import 'package:cfb_store/cfb_store.dart';
import 'package:dart_core_extensions/dart_core_extensions.dart';
import 'package:flutter/material.dart';
import 'package:than_sound/const_keys.dart';
import 'package:than_sound/core/utils/platform_util.dart';
import 'package:than_sound/ui_platforms/desktop/home/desktop_home_screen.dart';
import 'package:than_sound/ui_platforms/mobile/home/mobile_home_screen.dart';

class PlatformMainScreen extends StatefulWidget {
  const PlatformMainScreen({super.key});

  @override
  State<PlatformMainScreen> createState() => _PlatformMainScreenState();
}

class _PlatformMainScreenState extends State<PlatformMainScreen> {
  BoxConstraints? constraints;
  Timer? _saveTimer;

  void saveWindowSizeTimer() {
    if (constraints == null) return;
    _saveTimer?.cancel();
    _saveTimer = Timer(Duration(seconds: 3), () {
      CFBStore.getInstance
          .put(linuxWindowWidthKey, constraints!.maxWidth)
          .put(linuxWindowHeightKey, constraints!.maxHeight)
          .writeAll();
      debugPrint(
        '[_DesktopHomeScreenState:saveSizeConfig]: Save window size config width:${constraints!.maxWidth}',
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (TPlatform.isMobile) {
      PlatformUtil.isDesktopNotifier.value = false;
      return MobileHomeScreen();
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        this.constraints = constraints;
        saveWindowSizeTimer();

        final isMobile = constraints.maxWidth <= 500;
        PlatformUtil.isDesktopNotifier.value = !isMobile;
        if (isMobile) {
          return MobileHomeScreen();
        }
        return DesktopHomeScreen();
      },
    );
  }
}
