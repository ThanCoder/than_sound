import 'dart:async';

import 'package:cfb_store/cfb_store.dart';
import 'package:than_sound/core/controllers/all_state.dart';
import 'package:than_sound/core/controllers/i_controller.dart';
import 'package:than_sound/core/models/audio_file.dart';
import 'package:than_sound/core/scanner/audio_scanner.dart';

class AllFileStateController extends IController {
  final List<AudioFile> files = [];

  AllState _state = .new();
  AllState get state => _state;

  final _con = StreamController<AllState>.broadcast();
  Stream<AllState> get stream => _con.stream;

  static final cacheStore = CFBStore();

  Future<void> scanFromStorage({bool usedCache = true}) async {
    try {
      _state = _state.copyWith(isLoading: true, errorMessage: '');
      _con.add(state);

      if (usedCache && _cacheList.isNotEmpty) {
        files.clear();
        files.addAll(_cacheList);
        _state = _state.copyWith(isLoading: false);
        _con.add(state);
      }

      final list = await AudioScanner.scan();
      if (list.isNotEmpty) {
        files.addAll(list);
      }

      _state = _state.copyWith(isLoading: false);
      _con.add(state);
      // set cache
      if (files.isNotEmpty) {
        final cList = files.map((e) => e.toMap()).toList();
        cacheStore.put('list', cList);
      }
    } catch (e) {
      _state = _state.copyWith(isLoading: false, errorMessage: e.toString());
      _con.add(state);
    }
  }

  List<AudioFile> get _cacheList {
    final res = cacheStore.getMapList('list');
    if (res.isEmpty) return [];
    return res.map((e) => AudioFile.fromMap(e)).toList();
  }

  @override
  void dispose() {
    _con.close();
  }

  @override
  void init() {
    scanFromStorage();
  }
}
