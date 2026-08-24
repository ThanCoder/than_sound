import 'package:than_sound/core/models/audio_file.dart';

extension AudioFilePropsExt on AudioFile {
  String get yearLabel {
    final year = meta.year.toString();

    if (meta.year == 0) return '';
    // date format
    if (year.length == 8) {
      try {
        return '${year.substring(0, 4)}-${year.substring(4, 6)}-${year.substring(6, 8)}';
      } catch (e) {
        // print(e.toString());
      }
    }
    // print('year: ${meta.year}');
    return year;
  }
}

extension AudioFileExt on List<AudioFile> {
  void sortName({bool isA2Z = true}) {
    sort((a, b) {
      if (isA2Z) {
        return a.name.compareTo(b.name);
      } else {
        return b.name.compareTo(a.name);
      }
    });
  }

  void sortSize({bool smToBig = true}) {
    sort((a, b) {
      if (smToBig) {
        return a.size.compareTo(b.size);
      } else {
        return b.size.compareTo(a.size);
      }
    });
  }

  void sortDuration({bool smToBig = true}) {
    sort((a, b) {
      final ad = a.meta.duration;
      final bd = b.meta.duration;
      if (smToBig) {
        return ad.compareTo(bd);
      } else {
        return bd.compareTo(ad);
      }
    });
  }

  void sortDate({bool isNewest = true}) {
    sort((a, b) {
      if (isNewest) {
        return b.date.millisecondsSinceEpoch.compareTo(
          a.date.millisecondsSinceEpoch,
        );
      } else {
        return a.date.millisecondsSinceEpoch.compareTo(
          b.date.millisecondsSinceEpoch,
        );
      }
    });
  }
}
