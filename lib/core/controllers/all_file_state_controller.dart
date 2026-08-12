import 'dart:async';
import 'dart:io';

import 'package:cfb_store/cfb_store.dart';
import 'package:flutter/cupertino.dart';
import 'package:than_sound/core/controllers/all_file_event.dart';
import 'package:than_sound/core/controllers/all_state.dart';
import 'package:than_sound/core/controllers/interfaces/i_controller.dart';
import 'package:than_sound/core/controllers/player/player_state_controller.dart';
import 'package:than_sound/core/models/audio_file.dart';
import 'package:than_sound/core/scanner/audio_scanner.dart';
import 'package:than_sound/ui/partials/sort_provider.dart';

class AllFileStateController extends IController {
  PlayerStateController get _playerStateController =>
      ControllerManager.read<PlayerStateController>();

  final List<AudioFile> files = [];
  final List<SortItem> sortList = [.nameSortItem, .dateSortItem, .sizeSortItem];

  AllState _state = .empty();
  AllState get state => _state;

  final _con = StreamController<AllState>.broadcast();
  Stream<AllState> get stream => _con.stream;

  static final cacheStore = CFBStore();
  static const String sortIdKey = 'sort-id-key';
  static const String sortValueKey = 'sort-value-key';

  Future<void> scanFromStorage({bool usedCache = true}) async {
    try {
      _state = _state.copyWith(
        isLoading: true,
        errorMessage: '',
        currentSort: _getSortFromConfig(),
      );
      _con.add(state);

      // cache ကိုအသုံးပြုမယ်
      if (usedCache && _cacheList.isNotEmpty) {
        files.clear();
        files.addAll(_cacheList);
        _state = _state.copyWith(isLoading: false);
        sort(_state.currentSort, files);
        _con.add(state);
        addEvent(AllFileResetEvent());
      }

      final list = await AudioScanner.scan();
      if (list.isNotEmpty) {
        files.clear();
        files.addAll(list);
      }

      _state = _state.copyWith(isLoading: false);
      sort(_state.currentSort, files);
      _con.add(state);
      addEvent(AllFileResetEvent());
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

  SortItem _getSortFromConfig() {
    final id = cacheStore.getInt(sortIdKey, -1);
    final isTrue = cacheStore.getBool(
      sortValueKey,
      SortItem.dateSortItem.isTrue,
    );
    if (id == -1) return .dateSortItem;
    if (id == SortItem.nameSortItem.id) {
      return SortItem.nameSortItem.copyWith(isTrue: isTrue);
    }
    if (id == SortItem.sizeSortItem.id) {
      return SortItem.sizeSortItem.copyWith(isTrue: isTrue);
    }
    if (id == SortItem.dateSortItem.id) {
      return SortItem.dateSortItem.copyWith(isTrue: isTrue);
    }
    return .dateSortItem;
  }

  void _setSortToConfig() {
    cacheStore.put(sortIdKey, state.currentSort.id);
    cacheStore.put(sortValueKey, state.currentSort.isTrue);
    cacheStore.writeAll();
  }

  void sort(SortItem item, List<AudioFile> files) {
    if (item.id == SortItem.dateSortItem.id) {
      files.sortDate(isNewest: item.isTrue);
    }
    if (item.id == SortItem.nameSortItem.id) {
      files.sortName(isA2Z: item.isTrue);
    }
    if (item.id == SortItem.sizeSortItem.id) {
      files.sortSize(smToBig: item.isTrue);
    }
  }

  void setSort(SortItem item) {
    _state = _state.copyWith(currentSort: item);
    sort(item, files);
    _setSortToConfig();
    _con.add(_state);
    _playerStateController.setTracks(files, source: .allFileState);
  }

  @override
  void init() {
    scanFromStorage();
  }

  Future<void> deleteAudioFile(AudioFile file) async {
    try {
      // check current songe
      final current = _playerStateController.current.value;
      if (current != null && current.path == file.path) {
        await _playerStateController.stop();

        _playerStateController.current.value = null;
      }

      final index = files.indexWhere((e) => e.path == file.path);
      if (index == -1) {
        debugPrint(
          '[AllFileStateController:deleteAudioFile]: Not found index: $index',
        );
        return;
      }
      files.removeAt(index);
      addEvent(AllFileRemoveEvent(file));

      _con.add(_state);

      // delete
      final f = File(file.path);
      if (f.existsSync()) {
        await f.delete();
      }
    } catch (e) {
      debugPrint('[AllFileStateController:deleteAudioFile]: $e');
    }
  }
}
