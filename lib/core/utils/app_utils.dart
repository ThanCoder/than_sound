import 'dart:io';

import 'package:flutter/material.dart';
import 'package:than_pkg_android/than_pkg_android.dart';
import 'package:than_pkg_linux/than_pkg_linux.dart';

class AppUtils {
  static void clearImageCache() {
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
  }

  static Future<String?> getPlatformDownloadPath() async {
    if (Platform.isAndroid) {
      return ThanPkgAndroid.getInstance.pathHandler.getDownloadPath();
    } else if (Platform.isLinux) {
      final path = await ThanPkgLinux.getInstance.pathHandler
          .getDownloadsDirectory();
      if (path == null) return null;
      return path;
    }
    return null;
  }
}
