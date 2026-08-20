import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:cfb_store/cfb_store.dart';
import 'package:flutter/material.dart';
import 'package:mpv_audio_kit/mpv_audio_kit.dart' hide MediaAction;
import 'package:than_sound/const_keys.dart';
import 'package:than_sound/core/controllers/all_audio/all_file_event.dart';
import 'package:than_sound/core/controllers/all_audio/all_file_state_controller.dart';
import 'package:than_sound/core/controllers/interfaces/i_controller.dart';
import 'package:than_sound/core/controllers/player/mixins/config_mixin.dart';
import 'package:than_sound/core/controllers/player/mixins/extra_mixin.dart';
import 'package:than_sound/core/controllers/player/mixins/player_sleep_timer_listener.dart';
import 'package:than_sound/core/controllers/player/player_state_controller.dart';
import 'package:than_sound/core/models/audio_file.dart';
import 'package:than_sound/ui_platforms/components/sleep_timer/sleep_timer_mode.dart';
import 'package:than_sound/ui_platforms/components/favourite/favourite_controller.dart';

part 'mixins/player_listener_mixin.dart';
part 'mixins/shuffle_mixin.dart';
part 'mixins/equalizer_logic.dart';

class MyAudioHandler extends BaseAudioHandler
    with
        QueueHandler,
        SeekHandler,
        ConfigMixin,
        PlayerListenerMixin,
        ShuffleMixin,
        ExtraMixin,
        PlayerSleepTimerListener,
        EqualizerLogic {
  final _player = Player();
  @override
  Player get player => _player;
  @override
  MyAudioHandler get audioHandler => this;

  late final FavouriteController favouriteController =
      ControllerManager.read<FavouriteController>();
  late final AllFileStateController allFileStateController =
      ControllerManager.read<AllFileStateController>();

  @override
  PlayerState get state => _player.state;
  PlayerStream get stream => _player.stream;
  bool audioPaused = false;

  AudioFileSourceType _source = .none;
  AudioFileSourceType get source => _source;

  @override
  List<AudioFile> playlist = [];
  @override
  List<AudioFile> playOrder = [];

  bool get isShuffle => _isShuffle;
  Stream<bool> get shuffleStream => _shuffleStreamController.stream;

  @override
  final currentNotifier = ValueNotifier<AudioFile?>(null);

  final _currentAudioChangeContrller = StreamController<AudioFile?>.broadcast();
  Stream<AudioFile?> get currentAudioChangeStream =>
      _currentAudioChangeContrller.stream;

  final store = CFBStore.getInstance;

  void onListenPlayerEvents() {
    onPlayerListenerMixin();
  }

  void onListenControllerEvent() {
    onPlayerListenerMixinControllerEvents();
    onPlayerSleepTimerListener();
  }

  // songe end event
  void songEnd() async {
    final next = getNextSongIndex;
    if (next == -1) return;
    // timer

    final timerType = SleepTimerMode.fromValue(
      store.getString(playerSleepTimerTypeKey),
    );
    if (timerType != .none) {
      return;
    }

    // update ui
    currentNotifier.value = playOrder[next];

    // play next song
    await open(playOrder[next]);
  }

  Future<void> setTracks(
    List<AudioFile> files, {
    required AudioFileSourceType source,
  }) async {
    playlist = files;
    playOrder = [...playlist];
    _source = source;
    if (_player.state.playing || currentNotifier.value != null) return;
    await setAll(files, play: false);
  }

  Future<void> setAll(
    List<AudioFile> files, {
    int index = 0,
    bool play = true,
  }) async {
    playlist = files;
    playOrder = files;
    if (currentNotifier.value == null) {
      currentNotifier.value = files[index];
    }
    await _player.open(createMedia(currentNotifier.value!), play: play);
    addNotiMediaItem(currentNotifier.value!);
  }

  Future<void> open(AudioFile file) async {
    final index = getCurrentIndex(file);
    if (index == -1) {
      debugPrint('[MyAudioHandler:open]: index:$index');
      return;
    }
    await _player.open(createMedia(file), play: true);
    currentNotifier.value = file;
    addNotiMediaItem(file);
  }

  @override
  Future<void> skipToNext() async {
    final next = getNextSongIndex;
    if (next == -1) return;
    currentNotifier.value = playOrder[next];
    await open(playOrder[next]);
  }

  @override
  Future<void> skipToPrevious() async {
    final index = getCurrentIndex(currentNotifier.value);
    if (index == -1) return;
    final prev = index - 1;
    if (prev < 0) return;
    currentNotifier.value = playOrder[prev];
    await open(playOrder[prev]);
  }

  // The most common callbacks:
  @override
  Future<void> play() async {
    // _player.state
    try {
      final pos = _player.state.position.inSeconds;
      final dur = _player.state.duration.inSeconds;
      if (dur != 0 && pos == dur) {
        await _player.seek(Duration.zero);
      }

      _player.play();
      audioPaused = false;
    } catch (e) {
      debugPrint('[MyAudioHandler:play]: $e');
    }
  }

  @override
  Future<void> pause() async {
    _player.pause();
    audioPaused = true;
  }

  @override
  Future<void> seek(Duration position) => _player.seek(position);
  @override
  Future<void> skipToQueueItem(int index) => _player.seek(Duration.zero);

  Future<void> dispose() async {
    _player.dispose();
  }

  @override
  Future<void> stop() async {
    audioPaused = false;
    await _player.stop();
    currentNotifier.value = null;
    playbackState.add(
      playbackState.value.copyWith(playing: false, processingState: .idle),
    );
  }

  @override
  Future<dynamic> customAction(String name, [Map<String, dynamic>? extras]) {
    final current = currentNotifier.value;
    if (name == 'favorite' && current != null) {
      // AudioBookmarkController.instance.remove(current.id);
      favouriteController.remove(current);
    }
    if (name == 'favorite_outline' && current != null) {
      favouriteController.add(current);
      // AudioBookmarkController.instance.add(current.id);
    }

    return super.customAction(name, extras);
  }

  @override
  Future<void> click([MediaButton button = MediaButton.media]) async {
    final useBluetoothControl = CFBStore.getInstance.getBool(
      audioBluetoothControlKeyName,
      true,
    );
    if (!useBluetoothControl) return;

    return super.click(button);
  }
}
