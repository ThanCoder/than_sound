import 'package:flutter/material.dart';
import 'package:than_sound/ui/main/main_screen.dart';
import 'package:than_sound/ui/partials/material_theme_provider.dart';

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialThemeProvider(child: MainScreen());
  }
}
