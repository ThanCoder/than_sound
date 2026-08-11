import 'dart:async';

import 'package:cfb_store/cfb_store.dart';
import 'package:than_sound/core/controllers/all_state.dart';
import 'package:than_sound/core/controllers/interfaces/i_controller.dart';
import 'package:than_sound/core/controllers/player/player_state_controller.dart';
import 'package:than_sound/core/models/audio_file.dart';
import 'package:than_sound/core/scanner/audio_scanner.dart';
import 'package:than_sound/partials/sort_provider.dart';

class AllFileStateController extends IController {
  final PlayerStateController _playerStateController;
  AllFileStateController(this._playerStateController);

  final List<AudioFile> files = [];
  final List<SortItem> sortList = [.nameSortItem, .dateSortItem, .sizeSortItem];

  AllState _state = .empty();
  AllState get state => _state;

  final _con = StreamController<AllState>.broadcast();
  Stream<AllState> get stream => _con.stream;

  static final cacheStore = CFBStore();
  static const String sortKey = 'sort-key';

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
      }

      final list = await AudioScanner.scan();
      if (list.isNotEmpty) {
        files.clear();
        files.addAll(list);
      }

      _state = _state.copyWith(isLoading: false);
      sort(_state.currentSort, files);
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

  SortItem _getSortFromConfig() {
    final id = cacheStore.getInt(sortKey, -1);
    if (id == -1) return .dateSortItem;
    if (id == SortItem.nameSortItem.id) {
      return SortItem.nameSortItem;
    }
    if (id == SortItem.sizeSortItem.id) {
      return SortItem.sizeSortItem;
    }
    return .dateSortItem;
  }

  void _setSortToConfig() {
    cacheStore.putAndWriteAll(sortKey, state.currentSort.id);
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
    _playerStateController.setTracks(files);
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
