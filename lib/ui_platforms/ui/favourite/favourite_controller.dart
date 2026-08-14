import 'package:cfb_store/cfb_store.dart';
import 'package:than_sound/core/controllers/all_audio/all_file_event.dart';
import 'package:than_sound/core/controllers/all_audio/all_file_state_controller.dart';
import 'package:than_sound/core/controllers/interfaces/i_controller.dart';
import 'package:than_sound/core/models/audio_file.dart';

class FavouriteControllerAddEvent extends IControllerEvent {
  final AudioFile file;
  FavouriteControllerAddEvent(this.file);
}

class FavouriteControllerRemoveEvent extends IControllerEvent {
  final AudioFile file;
  FavouriteControllerRemoveEvent(this.file);
}

class FavouriteController extends IController {
  static final store = CFBStore();
  Stream<StoreEvent> get events => store.events;

  AllFileStateController get allFileStateController =>
      ControllerManager.read<AllFileStateController>();

  bool needToRefetch = false;

  @override
  void init() {
    allFileStateController.eventStream.listen((event) {
      if (event is AllFileAddEvent) {
        add(event.file);
      }
      if (event is AllFileRemoveEvent) {
        remove(event.file);
      }
      if (event is AllFileResetEvent) {
        cacheList.clear();
      }
    });
  }

  bool isExists(AudioFile file) {
    final index = files.indexWhere((e) => e.id == file.id);
    return index != -1;
  }

  void toggle(AudioFile file) {
    final list = store.getList('list');
    if (list.contains(file.id)) {
      remove(file);
    } else {
      add(file);
    }
  }

  void add(AudioFile file) {
    final list = store.getList('list');
    list.remove(file.id);
    list.insert(0, file.id);
    store.putAndWriteAll('list', list);
    cacheList.clear();
    addEvent(FavouriteControllerAddEvent(file));
  }

  void remove(AudioFile file) {
    final list = store.getList('list');
    list.remove(file.id);
    store.putAndWriteAll('list', list);
    cacheList.clear();
    addEvent(FavouriteControllerRemoveEvent(file));
  }

  final List<AudioFile> cacheList = [];

  List<AudioFile> get files {
    if (needToRefetch) {
      needToRefetch = false;
      store.openSync(store.dbFile.path);
    }
    if (cacheList.isNotEmpty) return cacheList;

    final favList = store.getStringList('list');
    if (favList.isEmpty) return [];

    final map = <String, AudioFile>{};
    for (var file in allFileStateController.files) {
      map[file.id] = file;
    }

    for (var id in favList) {
      final file = map[id];
      if (file == null) continue;
      cacheList.add(file);
    }
    return cacheList;
  }
}
