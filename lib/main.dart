import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:cfb_store/cfb_store.dart';
import 'package:flutter/material.dart';
import 'package:than_pkg_linux/than_pkg_linux.dart';
import 'package:than_sound/core/const_keys.dart';
import 'package:than_sound/core/controllers/all_file_state_controller.dart';
import 'package:than_sound/core/controllers/interfaces/i_controller.dart';
import 'package:than_sound/core/controllers/player/my_audio_handler.dart';
import 'package:than_sound/core/controllers/player/player_state_controller.dart';
import 'package:than_sound/core/utils/p_utils.dart';
import 'package:than_sound/main_app.dart';
import 'package:mpv_audio_kit/mpv_audio_kit.dart';
import 'package:than_sound/ui/favourite/favourite_controller.dart';
import 'package:waveform_visualizer/waveform_visualizer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
  await FavouriteController.store.open(
    PUtils.instance.getExternalConfigPath('app.audio.favourite.cfb'),
  );

  if (Platform.isLinux) {
    final size = CFBStore.getInstance.getDouble(
      linuxWindowWidthKey,
      linuxWindowMinWidth,
    );
    await ThanPkgLinux.getInstance.channel.setWindowSize(
      width: size.clamp(linuxWindowMinWidth, size).toInt(),
      height: CFBStore.getInstance.getInt(linuxWindowHeightKey, 480),
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

  audioHandler.startListen();

  runApp(const MainApp());
}

// AllFileStateController(), PlayerStateController()..init()
