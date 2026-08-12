import 'dart:async';

import 'package:flutter/material.dart';

part 'i_controller_event.dart';
part 'controller_manager.dart';

abstract class IController {
  final _eventController = StreamController<IControllerEvent>.broadcast();

  /// `ControllerAddEvent`,`ControllerRemoveEvent`
  Stream<IControllerEvent> get eventStream => _eventController.stream;
  void init();

  void addEvent(IControllerEvent event) {
    _eventController.add(event);
  }
}
