import 'package:than_sound/ui_platforms/pages/music_tracker/song_stats.dart';

final fakeSongStats = <SongStats>[
  SongStats(
    trackId: '1',
    listened: const Duration(hours: 12, minutes: 34, seconds: 20),
    playCount: 87,
    completionCount: 62,
    lastPlayedAt: DateTime.now().subtract(const Duration(minutes: 15)),
  ),

  SongStats(
    trackId: '2',
    listened: const Duration(hours: 8, minutes: 42),
    playCount: 54,
    completionCount: 41,
    lastPlayedAt: DateTime.now().subtract(const Duration(hours: 2)),
  ),

  SongStats(
    trackId: '3',
    listened: const Duration(hours: 25, minutes: 18),
    playCount: 143,
    completionCount: 120,
    lastPlayedAt: DateTime.now().subtract(const Duration(days: 1)),
  ),

  SongStats(
    trackId: '4',
    listened: const Duration(hours: 3, minutes: 27),
    playCount: 21,
    completionCount: 15,
    lastPlayedAt: DateTime.now().subtract(const Duration(days: 3)),
  ),

  SongStats(
    trackId: '5',
    listened: const Duration(hours: 18, minutes: 55),
    playCount: 96,
    completionCount: 78,
    lastPlayedAt: DateTime.now().subtract(const Duration(days: 7)),
  ),

  SongStats(
    trackId: '6',
    listened: const Duration(minutes: 45, seconds: 30),
    playCount: 8,
    completionCount: 4,
    lastPlayedAt: DateTime.now().subtract(const Duration(days: 14)),
  ),

  // တစ်ခါမှမနားထောင်ရသေးတဲ့ song
  SongStats(trackId: '7'),
];
