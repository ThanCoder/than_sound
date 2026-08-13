enum ReactiveCoverType {
  none,
  subtle,
  strong,
  extreme;

  static ReactiveCoverType fromValue(String val) {
    return values.firstWhere((e) => e.name == val, orElse: () => subtle);
  }
}

class AudioReactiveCoverConfig {
  /// Overall effect strength.
  ///
  /// 1.0 = normal
  /// 2.0 = strong
  /// 3.0 = very strong
  final double intensity;

  /// Maximum scale amount.
  ///
  /// 0.05 = maximum 5% larger
  /// 0.10 = maximum 10% larger
  final double maxScale;

  /// PCM sensitivity.
  ///
  /// Higher = reacts more easily to small sounds.
  final double amplitudeMultiplier;

  /// Smoothing factor.
  ///
  /// 0.0 = very responsive
  /// 0.9 = very smooth
  final double smoothing;

  /// Animation duration when scale changes.
  final Duration animationDuration;

  const AudioReactiveCoverConfig({
    this.intensity = 1.4,
    this.maxScale = 0.07,
    this.amplitudeMultiplier = 3.0,
    this.smoothing = 0.65,
    this.animationDuration = const Duration(milliseconds: 80),
  });

  /// Subtle effect.
  const AudioReactiveCoverConfig.subtle({
    this.intensity = 1.0,
    this.maxScale = 0.035,
    this.amplitudeMultiplier = 2.0,
    this.smoothing = 0.75,
    this.animationDuration = const Duration(milliseconds: 100),
  });

  /// Strong effect.
  const AudioReactiveCoverConfig.strong({
    this.intensity = 2.0,
    this.maxScale = 0.10,
    this.amplitudeMultiplier = 3.5,
    this.smoothing = 0.55,
    this.animationDuration = const Duration(milliseconds: 65),
  });

  /// Very strong / visualizer-like effect.
  const AudioReactiveCoverConfig.extreme({
    this.intensity = 2.5,
    this.maxScale = 0.14,
    this.amplitudeMultiplier = 4.0,
    this.smoothing = 0.45,
    this.animationDuration = const Duration(milliseconds: 45),
  });
}
