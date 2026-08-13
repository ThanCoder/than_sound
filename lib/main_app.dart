import 'package:flutter/material.dart';
import 'package:than_sound/ui/partials/material_theme_provider.dart';
import 'package:than_sound/ui_platforms/platform_main_screen.dart';

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialThemeProvider(child: PlatformMainScreen());
  }
}
