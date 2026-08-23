import 'dart:async';

import 'package:cfb_store/cfb_store.dart';
import 'package:than_sound/core/controllers/all_audio/all_file_event.dart';
import 'package:than_sound/core/controllers/all_audio/all_file_state_controller.dart';
import 'package:than_sound/core/controllers/interfaces/i_controller.dart';
import 'package:than_sound/core/controllers/player/player_state_controller.dart';
import 'package:than_sound/core/models/audio_file.dart';
import 'package:than_sound/core/utils/p_utils.dart';
import 'package:than_sound/ui_platforms/pages/music_tracker/song_stats.dart';

class MusicTrackerControllerValueChanged extends IControllerEvent {}

class MusicTrackerController extends IController {
  final _cf = CFBStore();

  final _allC = ControllerManager.read<AllFileStateController>();
  final _playerCon = ControllerManager.read<PlayerStateController>();

  final filesMap = <String, AudioFile>{};
  final statusMap = <String, SongStats>{};
  bool _init = false;

  @override
  Future<void> init() async {
    if (_init) return;
    await _cf.open(
      PUtils.instance.getExternalConfigPath('music.tracker.config.cfb'),
    );
    _allC.event.whereType<AllFileResetEvent>().listen((_) => load());

    final stopW = Stopwatch();

    _playerCon.event.listen((event) {
      if (event is PlayerStateControllerSongStart) {
        stopW
          ..reset()
          ..start();

        onSongStart(event.file.id);
      }

      if (event is PlayerStateControllerSongEnd) {
        stopW.stop();

        onSongEnd(event.file.id, stopW.elapsed);
      }

      if (event is PlayerStateControllerSongStop) {
        stopW.stop();

        onSongStop(event.file.id, stopW.elapsed);
      }
    });

    _init = true;
  }

  Future<void> load() async {
    await _cf.reload();
    filesMap.clear();
    statusMap.clear();

    for (var f in _allC.files) {
      filesMap[f.id] = f;
    }
    final trackList = _cf
        .getMapList('list')
        .map((e) => SongStats.fromMap(e))
        .toList();
    for (var track in trackList) {
      final au = filesMap[track.trackId];
      if (au == null) continue;
      statusMap[track.trackId] = track;
    }

    addEvent(MusicTrackerControllerValueChanged());
  }

  void onSongStart(String trackId) {
    final now = DateTime.now();
    final stats = getById(trackId);

    update(
      stats.copyWith(
        playCount: stats.playCount + 1,
        firstPlayedAt: stats.firstPlayedAt ?? now,
        lastPlayedAt: now,
      ),
    );
  }

  void onSongEnd(String trackId, Duration listened) {
    final stats = getById(trackId);

    update(
      stats.copyWith(
        listened: stats.listened + listened,
        completionCount: stats.completionCount + 1,
      ),
    );
  }

  void onSongStop(String trackId, Duration listened) {
    final stats = getById(trackId);

    update(stats.copyWith(listened: stats.listened + listened));
  }

  SongStats getById(String trackId) {
    return statusMap[trackId] ?? SongStats(trackId: trackId);
  }

  void update(SongStats stats) {
    statusMap[stats.trackId] = stats;
    save();
  }

  Timer? _saveTimer;
  void save() {
    _saveTimer?.cancel();

    _saveTimer = Timer(Duration(seconds: 5), () {
      final mapList = statusMap.values.map((e) => e.toMap()).toList();
      _saveTimer?.cancel();
      _saveTimer = null;
      _cf.put('list', mapList);
      _cf.writeAll();
    });
    addEvent(MusicTrackerControllerValueChanged());
  }
}
