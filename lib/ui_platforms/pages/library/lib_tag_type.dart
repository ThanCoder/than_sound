import 'package:flutter/material.dart';

enum LibTagType {
  artist,
  album,
  genre,
  year;

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

// static List<String> tags = ['artist', 'album', 'genre', 'year', 'format'];
