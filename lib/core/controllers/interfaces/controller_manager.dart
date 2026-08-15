part of 'i_controller.dart';

class ControllerManager {
  static final Map<Type, IController> _controllers = {};

  static void register<T extends IController>(T controller) {
    final type = T;

    if (_controllers.containsKey(type)) {
      throw FlutterError('$T ကို Register လုပ်ပြီးသားဖြစ်ပါတယ်။');
    }

    _controllers[type] = controller;

    controller.init();
  }

  static T read<T extends IController>() {
    final controller = _controllers[T];

    if (controller == null) {
      throw FlutterError('$T ကို Register မလုပ်ရသေးပါ။');
    }

    return controller as T;
  }

  static bool has<T extends IController>() {
    return _controllers.containsKey(T);
  }
}
