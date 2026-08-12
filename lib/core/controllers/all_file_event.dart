import 'package:than_sound/core/controllers/interfaces/i_controller.dart';
import 'package:than_sound/core/models/audio_file.dart';

class AllFileAddEvent extends IControllerEvent {
  final AudioFile file;
  AllFileAddEvent(this.file);
}

class AllFileRemoveEvent extends IControllerEvent {
  final AudioFile file;
  AllFileRemoveEvent(this.file);
}

class AllFileResetEvent extends IControllerEvent {}
