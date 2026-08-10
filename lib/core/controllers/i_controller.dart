import 'package:flutter/material.dart';

abstract class IController {
  void init();
  void dispose();
}

class _ControllerManagerScope extends InheritedWidget {
  final Map<Type, IController> controllers;
  const _ControllerManagerScope({
    required this.controllers,
    required super.child,
  });

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    return false;
  }
}

class ControllerManager extends StatefulWidget {
  final Widget child;
  final List<IController> controllers;
  const ControllerManager({
    super.key,
    required this.controllers,
    required this.child,
  });

  @override
  State<ControllerManager> createState() => _ControllerManagerState();

  static T of<T extends IController>(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<_ControllerManagerScope>();
    if (scope == null) {
      throw FlutterError('ControllerManager မတွေ့ပါ။ Context ကို စစ်ဆေးပါ။');
    }
    final controller = scope.controllers[T];
    if (controller == null) {
      throw FlutterError(
        '$T ကို ControllerManager ထဲမှာ Register မလုပ်ရသေးပါ။',
      );
    }

    return controller as T;
  }
}

class _ControllerManagerState extends State<ControllerManager> {
  final Map<Type, IController> _controllersMap = {};

  @override
  void initState() {
    for (var con in widget.controllers) {
      _controllersMap[con.runtimeType] = con;
      con.init();
    }
    super.initState();
  }

  @override
  void dispose() {
    for (var con in _controllersMap.values) {
      con.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _ControllerManagerScope(
      controllers: _controllersMap,
      child: widget.child,
    );
  }
}

// ext
extension ControllerManagerExt on BuildContext {
  T read<T extends IController>() {
    return ControllerManager.of<T>(this);
  }
}
