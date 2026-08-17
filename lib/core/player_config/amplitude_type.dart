enum AmplitudeType {
  none,
  fps20,
  fps30,
  fps60;

  static AmplitudeType fromValue(String val) {
    return values.firstWhere((e) => e.name == val, orElse: () => none);
  }

  String get lable {
    if (this == fps20) return '20 FPS';
    if (this == fps30) return '30 FPS';
    if (this == fps60) return '60 FPS';
    return 'None';
  }

  Duration get toDuration {
    if (this == fps20) return Duration(milliseconds: 50);
    if (this == fps30) return const Duration(milliseconds: 33);
    if (this == fps60) return const Duration(milliseconds: 16);
    return .zero;
  }
}
