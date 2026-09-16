import 'package:flutter/material.dart';
import 'package:than_sound/ui_platforms/desktop/home/desktop_home_screen.dart';
import 'package:than_sound/ui_platforms/mobile/home/mobile_home_screen.dart';

class PlatformMainScreen extends StatelessWidget {
  const PlatformMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 500;
        if (isMobile) {
          return MobileHomeScreen();
        }
        return DesktopHomeScreen();
      },
    );
  }
}
