class BassConfig {
  final double gain;
  final double frequency;
  final bool enable;
  const BassConfig({this.gain = 6, this.frequency = 100, this.enable = false});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'gain': gain,
      'frequency': frequency,
      'enable': enable,
    };
  }

  factory BassConfig.fromMap(Map<String, dynamic> map) {
    return BassConfig(
      gain: map['gain'] ?? 6,
      frequency: map['frequency'] ?? 100,
      enable: map['enable'] ?? false,
    );
  }

  BassConfig copyWith({double? gain, double? frequency, bool? enable}) {
    return BassConfig(
      gain: gain ?? this.gain,
      frequency: frequency ?? this.frequency,
      enable: enable ?? this.enable,
    );
  }
}
