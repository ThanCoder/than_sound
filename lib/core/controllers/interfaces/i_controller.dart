import 'package:flutter/material.dart';

part 'controller_manager.dart';

abstract class IController {
  void init();
  void dispose();
}

typedef ControllerCallback = IController Function(ControllerRef ref);

class CustController {
  final ControllerCallback callback;

  const CustController(this.callback);
}

class ControllerRef {
  final Map<Type, IController> _controllers;

  ControllerRef(this._controllers);

  T read<T extends IController>() {
    final controller = _controllers[T];

    if (controller == null) {
      throw FlutterError(
        '$T ကို ControllerManager ထဲမှာ Register မလုပ်ရသေးပါ။',
      );
    }

    return controller as T;
  }
}

// ext
extension ControllerManagerExt on BuildContext {
  T read<T extends IController>() {
    return ControllerManager.of<T>(this);
  }
}
// ```

// အသုံးပြုပုံက—

// ```dart
// runApp(
//   ControllerManager(
//     controllers: [
//       CustController(
//         (ref) => PlayerStateController(audioHandler),
//       ),
//       CustController(
//         (ref) => AllFileStateController(
//           ref.read<PlayerStateController>(),
//         ),
//       ),
//     ],
//     child: const MainApp(),
//   ),
// );
// ```

// `MainApp` အောက်ကနေတော့ မင်းအရင်လိုပဲ—

// ```dart
// final player = context.read<PlayerStateController>();

// final files = context.read<AllFileStateController>();
// ```

// သုံးလို့ရတယ်။

// အရေးကြီးတာက `PlayerStateController` ကို `ref.read` နဲ့ယူတာက **ControllerManager initialization အတွင်းမှာ** ဖြစ်လို့ `BuildContext` ပြဿနာလည်း မရှိတော့ဘူး။
