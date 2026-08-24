import 'package:cfb_store/cfb_store.dart';
import 'package:than_sound/core/controllers/all_audio/all_file_event.dart';
import 'package:than_sound/core/controllers/all_audio/all_file_state_controller.dart';
import 'package:than_sound/core/controllers/interfaces/i_controller.dart';
import 'package:than_sound/core/models/audio_file.dart';
import 'package:than_sound/core/utils/p_utils.dart';

class FavouriteControllerValueChanged extends IControllerEvent {}

class FavouriteController extends IController {
  final _cf = CFBStore();

  final _allC = ControllerManager.read<AllFileStateController>();

  final files = <AudioFile>[];
  bool _init = false;

  @override
  Future<void> init() async {
    if (_init) return;
    await _cf.open(
      PUtils.instance.getExternalConfigPath('app.audio.favourite.cfb'),
    );
    _allC.event.whereType<AllFileResetEvent>().listen((event) => load());
    _init = true;
  }

  Future<void> load() async {
    await _cf.reload();
    files.clear();
    final m = <String, AudioFile>{};
    for (var f in _allC.files) {
      m[f.id] = f;
    }
    for (var id in _cf.getList('list')) {
      final f = m[id];
      if (f == null) continue;
      files.add(f);
    }

    addEvent(FavouriteControllerValueChanged());
  }

  bool isExists(AudioFile file) {
    final index = files.indexWhere((e) => e.id == file.id);
    return index != -1;
  }

  void toggle(AudioFile file) {
    if (isExists(file)) {
      remove(file);
    } else {
      add(file);
    }
  }

  void add(AudioFile file) {
    files.insert(0, file);
    final list = _cf.getList('list');
    list.remove(file.id);
    list.insert(0, file.id);
    _cf.put('list', list);
    save();
  }

  void remove(AudioFile file) {
    final inx = files.indexWhere((e) => e.id == file.id);
    if (inx != -1) {
      files.removeAt(inx);
    }
    final list = _cf.getList('list');
    list.remove(file.id);
    _cf.put('list', list);
    save();
  }

  void save() {
    _cf.writeAll();
    addEvent(FavouriteControllerValueChanged());
  }
}
