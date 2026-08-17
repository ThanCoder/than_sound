import 'package:mpv_audio_kit/mpv_audio_kit.dart';

mixin ConfigMixin {
  Player get player;

  Future<void> initConfig() async {
    await player.setSpectrum(
      const SpectrumSettings(
        fftSize: 2048,
        bandCount: 64,
        bandLowHz: 20,
        bandHighHz: 20000,
        emitInterval: Duration(milliseconds: 33),
        attackSmoothing: 0.7,
        releaseSmoothing: 0.15,
        minDb: -80,
        maxDb: 0,
        overlapFactor: 4,
      ),
    );
  }
}
