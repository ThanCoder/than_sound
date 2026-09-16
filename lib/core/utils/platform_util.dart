import 'dart:io';

import 'package:dart_core_extensions/dart_core_extensions.dart';
import 'package:than_audiotag/core/my_native/workers/tag_picture_worker.dart';
import 'package:than_pkg_android/than_pkg_android.dart';
import 'package:than_pkg_linux/than_pkg_linux.dart';
import 'package:than_sound/core/models/audio_file.dart';
import 'package:than_sound/core/utils/p_utils.dart';

class PlatformUtil {
  static Future<void> launchUrl(String url) async {
    if (Platform.isLinux) {
      await ThanPkgLinux.getInstance.launcher.launchUrl(url);
      return;
    }
    if (Platform.isAndroid) {
      await ThanPkgAndroid.getInstance.launchHandler.launchUrl(url);
      return;
    }
  }

  static Future<String> getOutPath(String name) async {
    if (Platform.isLinux) {
      final p = await ThanPkgLinux.getInstance.pathHandler
          .getDownloadsDirectory();
      final dir = Directory(p!.join(PUtils.instance.appName));
      if (!dir.existsSync()) {
        await dir.create(recursive: true);
      }
      return dir.join(name);
    }
    if (Platform.isAndroid) {
      final p = ThanPkgAndroid.getInstance.pathHandler.getDownloadPath().join(
        name,
      );
      final dir = Directory(p.join(PUtils.instance.appName));
      if (!dir.existsSync()) {
        await dir.create(recursive: true);
      }
      return dir.join(name);
    }

    throw UnsupportedError('Only Supported -> `android`,`linux`');
  }

  static Future<void> genThumbnail(
    AudioFile file, {
    bool isOverride = false,
  }) async {
    await TagPictureWorker.instance.generate(
      file.path,
      file.cacheCoverPath,
      isOverride: isOverride,
    );
  }
}
