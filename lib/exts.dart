extension StrExt on String {
  /// empty or def
  String isEmptyOr(String defaultVal) {
    if (isEmpty) return defaultVal;
    return this;
  }
}
