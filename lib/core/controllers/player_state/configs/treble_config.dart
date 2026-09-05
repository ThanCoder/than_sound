class TrebleConfig {
  final double gain;
  final double frequency;
  final bool enable;
  const TrebleConfig({
    this.gain = 0,
    this.frequency = 3000,
    this.enable = false,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'gain': gain,
      'frequency': frequency,
      'enable': enable,
    };
  }

  factory TrebleConfig.fromMap(Map<String, dynamic> map) {
    return TrebleConfig(
      gain: map['gain'] ?? 0,
      frequency: map['frequency'] ?? 3000,
      enable: map['enable'] ?? false,
    );
  }

  TrebleConfig copyWith({double? gain, double? frequency, bool? enable}) {
    return TrebleConfig(
      gain: gain ?? this.gain,
      frequency: frequency ?? this.frequency,
      enable: enable ?? this.enable,
    );
  }
}
