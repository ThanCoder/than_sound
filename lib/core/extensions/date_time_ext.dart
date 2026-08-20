extension DateTimeStringExt on String {
  DateTime? parseYyyyMMdd() {
    if (!RegExp(r'^\d{8}$').hasMatch(this)) {
      return null;
    }

    final year = int.parse(substring(0, 4));
    final month = int.parse(substring(4, 6));
    final day = int.parse(substring(6, 8));

    try {
      return DateTime(year, month, day);
    } catch (_) {
      return null;
    }
  }
}

extension DateTimeExt on DateTime {
  String yyyyMMdd({String sprator = ''}) {
    return '$year$sprator'
        '${month.toString().padLeft(2, '0')}$sprator'
        '${day.toString().padLeft(2, '0')}';
  }
}
