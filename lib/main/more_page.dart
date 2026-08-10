import 'package:flutter/material.dart';
import 'package:t_widgets/t_widgets.dart' hide MaterialThemeProviderChooser;
import 'package:than_sound/core/utils/p_utils.dart';
import 'package:than_sound/partials/cache_manager.dart';
import 'package:than_sound/partials/material_theme_provider.dart';
import 'package:than_sound/partials/version_manager.dart';

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
        ],
      ),
    );
  }
}
