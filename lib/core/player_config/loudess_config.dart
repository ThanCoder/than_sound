class LoudessConfig {
  const LoudessConfig({
    this.enabled = false,
    this.targetLufs = -18.0,
    this.minGain = -12.0,
    this.maxGain = 6.0,
  });

  final bool enabled;
  final double targetLufs;
  final double minGain;
  final double maxGain;

  LoudessConfig copyWith({
    bool? enabled,
    double? targetLufs,
    double? minGain,
    double? maxGain,
  }) {
    return LoudessConfig(
      enabled: enabled ?? this.enabled,
      targetLufs: targetLufs ?? this.targetLufs,
      minGain: minGain ?? this.minGain,
      maxGain: maxGain ?? this.maxGain,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'enabled': enabled,
      'targetLufs': targetLufs,
      'minGain': minGain,
      'maxGain': maxGain,
    };
  }

  factory LoudessConfig.fromMap(Map<String, dynamic> map) {
    return LoudessConfig(
      enabled: map['enabled'] ?? false,
      targetLufs: map['targetLufs'] ?? -18.0,
      minGain: map['minGain'] ?? -12.0,
      maxGain: map['maxGain'] ?? 6.0,
    );
  }

  @override
  String toString() {
    return 'LoudessConfig(enabled: $enabled, targetLufs: $targetLufs, minGain: $minGain, maxGain: $maxGain)';
  }
}
