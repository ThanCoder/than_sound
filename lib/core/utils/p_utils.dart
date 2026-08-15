import 'dart:io';
import 'dart:isolate';

import 'package:dart_core_extensions/dart_core_extensions.dart';
import 'package:flutter/cupertino.dart';
import 'package:than_pkg_android/than_pkg_android.dart';
import 'package:than_pkg_linux/than_pkg_linux.dart';

class PUtils {
  static PUtils instance = PUtils._();
  PUtils._();
  factory PUtils() => instance;

  late Directory cacheDir;
  late Directory configDir;
  late String androidRootDirPath;
  String packageName = 'than_audio';
  String version = '1';

  Future<void> init() async {
    try {
      if (Platform.isLinux) {
        final cfDir = await ThanPkgLinux.getInstance.pathHandler
            .getApplicationConfigDirectory();
        final cDir = await ThanPkgLinux.getInstance.pathHandler
            .getApplicationTemporaryDirectory();
        final info = await ThanPkgLinux.getInstance.info.getAppInfo();
        if (info != null) {
          packageName = info.packageName;
          version = info.version;
        }
        if (cfDir != null) {
          configDir = cfDir;
        }
        if (cDir != null) {
          cacheDir = cDir;
        }
      } else if (Platform.isAndroid) {
        final path = ThanPkgAndroid.getInstance.pathHandler
            .getDeviceStoragePath();
        androidRootDirPath = PathBuf(path).join('.$packageName').path;
        final ch = await ThanPkgAndroid.getInstance.pathHandler.getCachePath();
        if (ch != null) {
          cacheDir = Directory(ch);
          configDir = Directory(cacheDir.join('config'));
        }
        final appInfo = await ThanPkgAndroid.getInstance.infoHandler
            .getAppInfo();
        if (appInfo != null) {
          packageName = appInfo.packageName;
          version = appInfo.versionName.toString();
        }
      }
    } catch (e) {
      debugPrint('[PUtils:init]: $e');
    }
  }

  String getCachePath([String? name]) {
    if (!cacheDir.existsSync()) {
      cacheDir.createSync();
    }
    if (name == null) return cacheDir.path;
    return cacheDir.join(name);
  }

  String getConfigPath([String? name]) {
    if (!configDir.existsSync()) {
      configDir.create(recursive: true);
    }
    if (name == null) return configDir.path;
    return configDir.join(name);
  }

  String getExternalConfigPath([String? name]) {
    var root = configDir;
    try {
      if (Platform.isAndroid) {
        final dir = PathBuf(androidRootDirPath).join('config').directory;
        if (!dir.existsSync()) {
          dir.createSync(recursive: true);
        }
        root = dir;
      }
    } catch (e) {
      debugPrint('[PUtils:getExternalConfigPath]: $e');
    }
    if (name == null) return root.path;

    return root.join(name);
  }

  /// ### Return -> [(count,size)]
  Future<(int, int)?> getFolderInfo(Directory dir) async {
    if (!dir.existsSync()) return null;
    return await Isolate.run<(int, int)?>(() {
      try {
        int size = 0;
        int count = 0;
        for (var entry in dir.listSync(recursive: true)) {
          if (entry.isFile) {
            size += entry.size;
          }
          count++;
        }
        return (count, size);
      } catch (e) {
        debugPrint('[PUtils:deleteDir]: $e');
        return null;
      }
    });
  }

  Future<bool> deleteFolder(Directory dir) async {
    if (!dir.existsSync()) return false;
    return await Isolate.run(() {
      try {
        dir.deleteSync(recursive: true);
        dir.createSync();
        return true;
      } catch (e) {
        debugPrint('[PUtils:deleteDir]: $e');
        return false;
      }
    });
  }
}
