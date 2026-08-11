import 'package:flutter/material.dart';
import 'package:than_pkg_linux/than_pkg_linux.dart';
import 'package:than_sound/core/utils/p_utils.dart';

class VersionManager extends StatelessWidget {
  final String githubUrl;
  const VersionManager({super.key, required this.githubUrl});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text('Version: ${PUtils.instance.version}'),
        onTap: () {
          ThanPkgLinux.getInstance.launcher.launchUrl('$githubUrl/releases');
        },
      ),
    );
  }
}
