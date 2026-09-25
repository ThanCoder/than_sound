import 'package:flutter/material.dart';
import 'package:than_sound/core/models/audio_file.dart';

enum LibTagType {
  artist,
  album,
  genre,
  year;

  String get label {
    return switch (this) {
      artist => 'Artist',
      album => 'Album',
      genre => 'Genre',
      year => 'Year',
    };
  }

  Icon get icon {
    if (this == artist) {
      return Icon(Icons.person_2_outlined);
    }
    if (this == album) {
      return Icon(Icons.album_outlined);
    }
    if (this == genre) {
      return Icon(Icons.category_outlined);
    }
    if (this == year) {
      return Icon(Icons.date_range_outlined);
    }
    return Icon(Icons.device_unknown);
  }
}

class AudioGroup {
  const AudioGroup({required this.name, required this.files});

  final String name;
  final List<AudioFile> files;

  int get count => files.length;

  AudioFile get cover => files.first;
}
