class UiContentBlurConfig {
  final bool enable;
  final double sigmaY;
  final double sigmaX;
  const UiContentBlurConfig({
    this.enable = false,
    this.sigmaY = 10,
    this.sigmaX = 10,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'enable': enable,
      'sigmaY': sigmaY,
      'sigmaX': sigmaX,
    };
  }

  factory UiContentBlurConfig.fromMap(Map<String, dynamic> map) {
    return UiContentBlurConfig(
      enable: map['enable'] ?? false,
      sigmaY: map['sigmaY'] ?? 15,
      sigmaX: map['sigmaX'] ?? 15,
    );
  }

  UiContentBlurConfig copyWith({bool? enable, double? sigmaY, double? sigmaX}) {
    return UiContentBlurConfig(
      enable: enable ?? this.enable,
      sigmaY: sigmaY ?? this.sigmaY,
      sigmaX: sigmaX ?? this.sigmaX,
    );
  }
}
