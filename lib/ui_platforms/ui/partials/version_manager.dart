import 'package:flutter/material.dart';
import 'package:than_pkg_linux/than_pkg_linux.dart';
import 'package:than_sound/core/utils/p_utils.dart';

class VersionManager extends StatelessWidget {
  final String githubUrl;

  const VersionManager({super.key, required this.githubUrl});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      leading: Icon(Icons.info_outline_rounded, color: colorScheme.primary),
      title: const Text('Version'),
      subtitle: Text(
        PUtils.instance.version,
        style: TextStyle(color: colorScheme.onSurfaceVariant),
      ),
      trailing: const Icon(Icons.open_in_new_rounded, size: 20),
      onTap: () {
        ThanPkgLinux.getInstance.launcher.launchUrl('$githubUrl/releases');
      },
    );
  }
}
