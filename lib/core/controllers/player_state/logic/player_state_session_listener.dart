// ignore_for_file: experimental_member_use

part of '../player_state_controller.dart';

class PlayerStateSessionListener {
  final PlayerStateController _controller;
  PlayerStateSessionListener({required this._controller});

  Player get player => _controller.player;

  bool _wasPlayingBeforeInterruption = false;

  bool _init = false;
  Future<void> init() async {
    if (_init) return;
    _init = true;

    if (!Platform.isAndroid) return;
    final session = await AudioSession.instance;

    session.becomingNoisyEventStream.listen((_) {
      // The user unplugged the headphones, so we should pause or lower the volume.
      player.pause();
    });

    session.devicesChangedEventStream.listen((event) {
      // print('Devices added:   ${event.devicesAdded}');
      // print('Devices removed: ${event.devicesRemoved}');
      for (var deviceRemoved in event.devicesRemoved) {
        if (deviceRemoved.type == .bluetoothA2dp ||
            deviceRemoved.type == .bluetoothLe ||
            deviceRemoved.type == .bluetoothSco) {
          player.pause();
        }
      }
    });

    session.interruptionEventStream.listen((event) {
      if (event.begin) {
        // Interruption မဖြစ်ခင် player က play နေလား သိမ်းထား
        _wasPlayingBeforeInterruption = player.state.playing;

        switch (event.type) {
          case AudioInterruptionType.duck:
            // Another app started playing audio and we should duck.
            break;
          case AudioInterruptionType.pause:
          case AudioInterruptionType.unknown:
            // Another app started playing audio and we should pause.
            player.pause();
            break;
        }
        return;
      }

      switch (event.type) {
        case AudioInterruptionType.duck:
          // The interruption ended and we should unduck.
          break;
        case AudioInterruptionType.pause:
          // The interruption ended and we should resume.
          if (_wasPlayingBeforeInterruption) {
            player.play();
          }
        case AudioInterruptionType.unknown:
          // The interruption ended but we should not resume.

          break;
      }

      _wasPlayingBeforeInterruption = false;
    });
  }
}
