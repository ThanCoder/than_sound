import 'package:cfb_store/cfb_store.dart';
import 'package:flutter/widgets.dart';
import 'package:than_sound/const_keys.dart';
import 'package:than_sound/ui_platforms/mobile/components/reactive_cover/audio_reactive_cover.dart';
import 'package:than_sound/ui_platforms/mobile/content/default_content/reactive_cover_types.dart';

class AudioReactiveCoverSwitcher extends StatelessWidget {
  final Widget child;
  final Stream<double> amplitude;
  final Stream<bool> playing;
  final bool playingState;
  const AudioReactiveCoverSwitcher({
    super.key,
    required this.child,
    required this.playing,
    required this.playingState,
    required this.amplitude,
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
          amplitude: amplitude,
          playing: playing,
          playingState: playingState,
          child: child,
        );
      },
    );
  }
}
