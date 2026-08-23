import 'dart:async';

import 'package:flutter/material.dart';

part 'controller_manager.dart';

abstract class IControllerEvent {
  const IControllerEvent();
}

abstract class IController {
  final _eventController = StreamController<IControllerEvent>.broadcast();

  /// `ControllerAddEvent`,`ControllerRemoveEvent`
  Stream<IControllerEvent> get event => _eventController.stream;
  Future<void> init();

  void addEvent(IControllerEvent event) {
    _eventController.add(event);
  }
}

extension IControllerExt on Stream<IControllerEvent> {
  Stream<T> whereType<T extends IControllerEvent>() {
    return where((e) => e is T).cast<T>();
  }
}
