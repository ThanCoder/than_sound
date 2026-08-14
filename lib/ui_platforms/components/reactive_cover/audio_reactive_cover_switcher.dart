import 'package:cfb_store/cfb_store.dart';
import 'package:flutter/widgets.dart';
import 'package:mpv_audio_kit/mpv_audio_kit.dart';
import 'package:than_sound/const_keys.dart';
import 'package:than_sound/ui_platforms/components/reactive_cover/audio_reactive_cover.dart';
import 'package:than_sound/ui_platforms/components/reactive_cover/reactive_cover_types.dart';

class AudioReactiveCoverSwitcher extends StatelessWidget {
  final Widget child;
  final PlayerStream playerStream;
  final Stream<bool> playing;
  final bool playingState;
  const AudioReactiveCoverSwitcher({
    super.key,
    required this.child,
    required this.playing,
    required this.playingState,
    required this.playerStream,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: CFBStore.getInstance.events.where(
        (e) => e is PutValue && e.key == audioContentUseReactiveCoverTypeKey,
      ),
      builder: (context, asyncSnapshot) {
        final reactiveCoverType = ReactiveCoverType.fromValue(
          CFBStore.getInstance.getString(audioContentUseReactiveCoverTypeKey),
        );
        if (reactiveCoverType == .none) {
          return child;
        }
        return AudioReactiveCover(
          playerStream: playerStream,
          playing: playing,
          playingState: playingState,
          type: reactiveCoverType,
          child: child,
        );
      },
    );
  }
}
