import 'package:flutter/material.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_sound/core/utils/p_utils.dart';
import 'package:than_sound/ui_platforms/mobile/setting/audio_setting_page.dart';
import 'package:than_sound/ui_platforms/mobile/setting/ui_theme_setting_page.dart';
import 'package:than_sound/ui_platforms/pages/app_about_dialog.dart';
import 'package:than_sound/ui_platforms/pages/dev_pages/dev_route_tile.dart';
import 'package:than_sound/ui_platforms/pages/share_server/server_home_page.dart';
import 'package:than_sound/ui_platforms/pages/partials/cache_manager.dart';
import 'package:than_sound/ui_platforms/pages/partials/material_theme_provider.dart';
import 'package:than_sound/ui_platforms/pages/partials/version_manager.dart';

class MorePage extends StatefulWidget {
  const MorePage({super.key});

  @override
  State<MorePage> createState() => _MorePageState();
}

class _MorePageState extends State<MorePage> {
  ColorScheme get col => Theme.of(context).colorScheme;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      appBar: AppBar(
        title: Text("More Apps"),
        backgroundColor: context.colorScheme.surfaceContainer,
      ),
      body: TScrollableColumn(
        children: [
          MaterialThemeProviderChooser(),
          VersionManager(githubUrl: 'https://github.com/ThanCoder/than_sound'),
          CacheManagerListTile(cacheDirPath: PUtils.instance.cacheDir.path),
          // ui setting
          uiColorSetting(),

          audioSetting(),

          ListTile(
            tileColor: col.surfaceContainer,
            shape: RoundedRectangleBorder(borderRadius: .circular(15)),
            leading: Icon(Icons.share_outlined, color: col.primary),
            trailing: Icon(Icons.arrow_forward_ios),
            title: Text('Share Server'),
            onTap: () {
              context.pushMaterialPageRoute(
                builder: (mainCtx) => ServerHomePage(),
              );
            },
          ),
          DevRouteTile(),
          AppAboutDialogListTile(descText: 'Audio Player Application.'),
          SizedBox(height: 50),
        ],
      ),
    );
  }

  Widget uiColorSetting() {
    final col = context.colorScheme;
    return GestureDetector(
      onTap: () {
        context.pushMaterialPageRoute(
          builder: (mainCtx) => UiThemeSettingPage(),
        );
      },
      child: Container(
        padding: .symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: .circular(15),
          color: col.surfaceContainerHighest.withValues(alpha: .45),
        ),
        child: Row(
          children: [
            Icon(Icons.color_lens, color: col.primary),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: .start,
              children: [
                Text(
                  'UI Theme Setting',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: .w600,
                    color: col.onSurface,
                  ),
                ),
                Text(
                  'Custom App Color Schemes',
                  style: TextStyle(
                    color: col.onSurfaceVariant,
                    fontSize: 12,
                    fontWeight: .w400,
                  ),
                ),
              ],
            ),
            Spacer(),
            Icon(Icons.arrow_right),
          ],
        ),
      ),
    );
  }

  GestureDetector audioSetting() {
    return GestureDetector(
      onTap: () {
        context.pushMaterialPageRoute(builder: (mainCtx) => AudioSettingPage());
      },
      child: Container(
        padding: .symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: col.surfaceContainerHighest.withValues(alpha: .45),
          borderRadius: .circular(15),
        ),
        child: Row(
          spacing: 8,
          children: [
            Icon(Icons.settings, color: col.primary),
            Expanded(
              child: Text(
                'Audio Settings',
                style: TextStyle(
                  color: col.onSurface,
                  fontSize: 16,
                  fontWeight: .w600,
                ),
              ),
            ),
            Icon(Icons.arrow_right, color: col.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}
