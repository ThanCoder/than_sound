// ignore_for_file: implementation_imports

import 'dart:io';
import 'dart:isolate';

import 'package:dart_core_extensions/dart_core_extensions.dart';
import 'package:flutter/foundation.dart';
import 'package:than_pkg_android/than_pkg_android.dart';
import 'package:than_pkg_linux/than_pkg_linux.dart';
import 'package:than_sound/const_keys.dart';
import 'package:than_sound/core/models/audio_file.dart';
import 'package:than_sound/core/models/audio_meta.dart';
import 'package:than_sound/core/utils/file_utils.dart';
import 'package:than_sound/core/utils/p_utils.dart';

class AudioScanner {
  static Future<List<String>> getScanRootPath() async {
    final scanFolders = <String>[];
    if (Platform.isLinux) {
      scanFolders.add(
        (await ThanPkgLinux.getInstance.pathHandler
            .getApplicationDocumentsDirectory())!,
      );
      scanFolders.add(
        (await ThanPkgLinux.getInstance.pathHandler.getDownloadsDirectory())!,
      );
      scanFolders.add(
        (await ThanPkgLinux.getInstance.pathHandler.getDesktopDirectory())!,
      );
      scanFolders.add(
        (await ThanPkgLinux.getInstance.pathHandler.getPicturesDirectory())!,
      );
      final home = Platform.environment['HOME'];
      if (home != null) {
        scanFolders.add(home.join('Music'));
        scanFolders.add(home.join('Videos'));
      }
    }
    if (Platform.isAndroid) {
      scanFolders.add(
        ThanPkgAndroid.getInstance.pathHandler.getDeviceStoragePath(),
      );
    }
    return scanFolders;
  }

  static Future<List<AudioFile>> scan() async {
    final roots = await getScanRootPath();
    final cachePath = PUtils.instance.getCachePath();
    final minAudioFileSize = 1024 * 20;
    return await Isolate.run(() async {
      List<AudioFile> list = [];

      AudioFile? processEntry(FileSystemEntity entry, String name) {
        try {
          // 500 KB အောက် မထည့်ဘူး (1024 * 500)
          // if (entry.size < (1024 * 500)) return null;
          if (entry.statSync().size < minAudioFileSize) return null;

          final lower = name.toLowerCase();

          if (!audioSupportedExtensions.any(lower.endsWith)) {
            return null;
          }
          final id = FileUtils.getFileIdSync(entry.path);

          final meta = AudioMeta(entry.path);
          final cacheCoverPath = cachePath.join('$id.png');
          meta.openMeta(cacheCoverPath);

          return AudioFile(
            id: id,
            name: name,
            path: entry.path,
            dirname: entry.parent.name,
            date: entry.modifiedDate,
            meta: meta,
            size: entry.size,
            cacheCoverPath: cacheCoverPath,
          );
        } catch (e) {
          debugPrint('[AudioScanner:processEntry]: $e');
          return null;
        }
      }

      for (var path in roots) {
        final dirs = <Directory>[Directory(path)];

        while (dirs.isNotEmpty) {
          final currentDir = dirs.removeLast();

          try {
            if (!currentDir.existsSync()) continue;

            // listSync မှာ error တက်နိုင်တာမို့ try-catch ထဲထည့်ပါမည်
            final entries = currentDir.listSync(followLinks: false);

            for (var entry in entries) {
              final name = entry.getName();

              // Hidden files သို့မဟုတ် Android System folder များကို ကျော်မည်
              if (name.startsWith('.') || name.startsWith('Android')) continue;

              if (entry is File) {
                final audio = processEntry(entry, name);

                if (audio != null) {
                  list.add(audio);
                }
              } else if (entry is Directory) {
                // Directory ဖြစ်မှသာ Sub-directory စာရင်းထဲပေါင်းမည်
                dirs.add(entry);
              }
            }
          } catch (e) {
            // Android storage permission ကြောင့် ဖတ်မရတဲ့ folder များကို skip လုပ်မည်
            debugPrint('[AudioScanner:listSync Exception]: $e');
          }
        }
      }

      return list;
    });
  }
}
