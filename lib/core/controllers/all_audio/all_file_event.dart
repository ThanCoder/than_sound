part of 'all_file_state_controller.dart';


class AllFileLoaded extends IControllerEvent {}

class AllFileAddEvent extends IControllerEvent {
  final AudioFile file;
  AllFileAddEvent(this.file);
}

class AllFileRemoveEvent extends IControllerEvent {
  final AudioFile file;
  AllFileRemoveEvent(this.file);
}

class AllFileResetEvent extends IControllerEvent {}

class AllFileStateControllerUpdateMeta extends IControllerEvent {
  final AudioFile file;
  AllFileStateControllerUpdateMeta(this.file);
}
