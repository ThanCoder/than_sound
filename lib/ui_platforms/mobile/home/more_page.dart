import 'package:flutter/material.dart';
import 'package:t_widgets/t_widgets.dart' hide MaterialThemeProviderChooser;
import 'package:than_sound/core/utils/p_utils.dart';
import 'package:than_sound/ui_platforms/mobile/setting/audio_setting_page.dart';
import 'package:than_sound/ui_platforms/ui/partials/cache_manager.dart';
import 'package:than_sound/ui_platforms/ui/partials/material_theme_provider.dart';
import 'package:than_sound/ui_platforms/ui/partials/version_manager.dart';

class MorePage extends StatelessWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("More Apps")),
      body: TScrollableColumn(
        children: [
          MaterialThemeProviderChooser(),
          VersionManager(githubUrl: 'https://github.com/ThanCoder/than_sound'),
          CacheManagerListTile(cacheDirPath: PUtils.instance.cacheDir.path),
          GestureDetector(
            onTap: () {
              context.pushMaterialPageRoute(
                builder: (mainCtx) => AudioSettingPage(),
              );
            },
            child: Container(
              padding: .symmetric(vertical: 14, horizontal: 16),
              decoration: BoxDecoration(
                color: context.colorScheme.surfaceContainerHighest.withValues(
                  alpha: .45,
                ),
                borderRadius: .circular(15),
              ),
              child: Row(
                spacing: 8,
                children: [
                  Icon(Icons.settings, color: context.colorScheme.primary),
                  Expanded(child: Text('Audio Settings')),
                  Icon(Icons.arrow_right),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
