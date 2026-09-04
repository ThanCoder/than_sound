import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:cfb_store/cfb_store.dart';
import 'package:flutter/material.dart';
import 'package:than_pkg_linux/than_pkg_linux.dart';
import 'package:than_sound/const_keys.dart';
import 'package:than_sound/core/controllers/all_audio/all_file_state_controller.dart';
import 'package:than_sound/core/controllers/interfaces/i_controller.dart';
import 'package:than_sound/core/controllers/player/my_audio_handler.dart';
import 'package:than_sound/core/controllers/player_state/player_state_controller.dart';
import 'package:than_sound/core/utils/p_utils.dart';
import 'package:than_sound/main_app.dart';
import 'package:mpv_audio_kit/mpv_audio_kit.dart';
import 'package:than_sound/ui_platforms/pages/favourite/favourite_controller.dart';
import 'package:than_sound/ui_platforms/pages/music_tracker/music_tracker_controller.dart';
import 'package:waveform_visualizer/waveform_visualizer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // debugRepaintRainbowEnabled = true;

  // SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  MpvAudioKit.ensureInitialized();
  WaveformVisualizer.initialize();

  if (Platform.isAndroid) {
    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration.music());
  }

  await PUtils.instance.init();
  //app config
  await CFBStore.getInstance.open(
    PUtils.instance.getConfigPath('app.config.cbf'),
  );
  await AllFileStateController.cacheStore.open(
    PUtils.instance.getCachePath('app.audio.cache.files.cfb'),
  );

  if (Platform.isLinux) {
    // await ThanPkgLinux.getInstance.window.setMinWindowSize(
    //   width: CFBStore.getInstance.getInt(
    //     linuxWindowWidthKey,
    //     linuxWindowMinWidth.toInt(),
    //   ),
    //   height: CFBStore.getInstance.getInt(j
    //     linuxWindowHeightKey,
    //     linuxWindowMinHeight.toInt(),
    //   ),
    // );
    await ThanPkgLinux.getInstance.window.setWindowSize(
      width: CFBStore.getInstance.getInt(
        linuxWindowWidthKey,
        linuxWindowMinWidth.toInt(),
      ),
      height: CFBStore.getInstance.getInt(
        linuxWindowHeightKey,
        linuxWindowMinHeight.toInt(),
      ),
    );
  }

  final audioHandler = await AudioService.init(
    builder: () => MyAudioHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'than_sound',
      androidNotificationChannelName: 'Than Sound',
      androidNotificationOngoing: true,
      androidNotificationIcon: 'mipmap/launcher_icon',
    ),
  );

  ControllerManager.register(PlayerStateController(audioHandler));
  ControllerManager.register(AllFileStateController());
  ControllerManager.register(FavouriteController());
  ControllerManager.register(MusicTrackerController());
  ControllerManager.initAll();

  runApp(const MainApp());
}

// AllFileStateController(), PlayerStateController()..init()
