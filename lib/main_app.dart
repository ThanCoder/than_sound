import 'package:cfb_store/cfb_store.dart';
import 'package:flutter/material.dart';
import 'package:than_sound/const_keys.dart';
import 'package:than_sound/ui_platforms/ui/partials/material_theme_provider.dart';
import 'package:than_sound/ui_platforms/platform_main_screen.dart';

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final cf = CFBStore.instance;
    return StreamBuilder(
      stream: cf.stream.put.where(
        (e) => e.key == appEnableColorSeedKey || e.key == appColorSeedKey,
      ),
      builder: (context, asyncSnapshot) {
        final appUseColorSeed = cf.getBool(appEnableColorSeedKey);
        final colorSeedInt = cf.getInt(appColorSeedKey);
        // print('appUseColorSeed: $appUseColorSeed');
        // print('colorSeedInt: $colorSeedInt');
        // print('dbFile: ${cf.dbFile}');

        final enable = appUseColorSeed && colorSeedInt != 0;
        final seedColor = Color(colorSeedInt);

        // print('enable: $enable');
        return MaterialThemeProvider(
          theme: !enable
              ? null
              : .light(useMaterial3: true).copyWith(
                  colorScheme: .fromSeed(
                    seedColor: seedColor,
                    brightness: .light,
                  ),
                ),
          darkTheme: !enable
              ? null
              : .dark(useMaterial3: true).copyWith(
                  colorScheme: .fromSeed(
                    brightness: .dark,
                    seedColor: seedColor,
                  ),
                ),
          child: PlatformMainScreen(),
        );
      },
    );
  }
}
