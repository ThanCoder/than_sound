part of '../my_audio_handler.dart';

mixin EqualizerLogic {
  MyAudioHandler get audioHandler;

  void setEquq() {
    audioHandler.player.updateAudioEffects(
      (eff) => eff.copyWith(bass: BassSettings(enabled: true, g: 6, f: 100)),
    );
  }
}
