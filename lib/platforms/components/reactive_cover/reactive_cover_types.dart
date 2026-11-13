enum ReactiveCoverType {
  none,
  subtle,
  strong,
  extreme;

  double get scaleFactor => switch (this) {
    none => 0.0,
    subtle => 0.04,
    strong => 0.08,
    extreme => 0.12,
  };

  static ReactiveCoverType fromValue(String val) {
    return values.firstWhere((e) => e.name == val, orElse: () => none);
  }
}
