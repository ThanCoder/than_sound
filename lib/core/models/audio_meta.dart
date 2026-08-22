import 'package:dart_core_extensions/dart_core_extensions.dart';
import 'package:flutter/cupertino.dart';
import 'package:than_audiotag/than_audiotag.dart';

class AudioMeta {
  static List<String> tags = ['artist', 'album', 'genre', 'year', 'format'];
  final String path;
  AudioMeta(
    this.path, {
    this.album = '',
    this.artist = '',
    this.bitrate = 0,
    this.bitrateMode = '',
    this.comment = '',
    this.coverMimeType = '',
    this.duration = .zero,
    this.format = '',
    this.genre = '',
    this.hasCover = false,
    this.sampleRate = 0,
    this.title = '',
    this.track = 0,
    this.year = 0,
    this.channels = 0,
    this.description = '',
    this.pictureType = '',
  });

  String album;
  String title;
  String artist;
  String comment;
  String coverMimeType;
  String bitrateMode;
  String genre;
  bool hasCover;
  Duration duration;
  String format;
  int bitrate;
  int sampleRate;

  int track;
  int year;
  int channels;
  String description;
  String pictureType;

  void openMeta(String cachePath) {
    try {
      final file = TTag();

      final fRes = file.openFile(path);
      if (fRes.isErr) {
        return;
      }
      final tagRes = file.tag;
      if (tagRes.isErr) {
        return;
      }
      final tag = tagRes.unwrap();

      title = tag.title;
      album = tag.album;
      artist = tag.artist;
      comment = tag.comment;
      genre = tag.genre;
      track = tag.track;
      year = tag.year;
      // prpos
      final pRes = file.readProperties;
      if (pRes.isErr) {
        file.close();
        return;
      }
      final props = pRes.unwrap();
      duration = Duration(seconds: props.duration);
      bitrate = props.bitrate;
      channels = props.channels;
      sampleRate = props.samplerate;
      file.close();
    } catch (e) {
      debugPrint('[Dev: AudioMeta:openMeta]: $e');
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'path': path,
      'album': album,
      'title': title,
      'artist': artist,
      'comment': comment,
      'coverMimeType': coverMimeType,
      'genre': genre,
      'bitrateMode': bitrateMode,
      'hasCover': hasCover,
      'duration': duration.inMilliseconds,
      'format': format,
      'bitrate': bitrate,
      'sampleRate': sampleRate,
      'track': track,
      'year': year,
      'channels': channels,
      'description': description,
      'pictureType': pictureType,
    };
  }

  factory AudioMeta.fromMap(Map<String, dynamic> map) {
    return AudioMeta(
      map['path'],
      album: map['album'],
      title: map['title'],
      artist: map['artist'],
      comment: map['comment'],
      coverMimeType: map['coverMimeType'],
      bitrateMode: map['bitrateMode'],
      genre: map['genre'],
      hasCover: map['hasCover'],
      duration: Duration(milliseconds: map['duration'] ?? 0),
      format: map['format'],
      bitrate: map['bitrate'],
      sampleRate: map['sampleRate'],
      track: map['track'] ?? 0,
      year: map['year'] ?? 0,
      channels: map['channels'] ?? 0,
      description: map['description'] ?? '',
      pictureType: map['pictureType'] ?? '',
    );
  }

  String get formatDuration {
    final mins = duration.inMinutes;
    final secs = duration.inSeconds % 60;

    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  String get formatLabel {
    return PathBuf(path).extension.toUpperCase();
  }

  String get bitrateLabel {
    return '$bitrate kb/s';
  }

  String get sampleRateLabel {
    return '${sampleRate / 1000} kHz';
  }

  @override
  String toString() => 'AudioMeta(path: $path)';
}
