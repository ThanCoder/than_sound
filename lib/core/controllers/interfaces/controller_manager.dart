part of 'i_controller.dart';

/// အသုံးပြုပုံက—
/// ```dart
/// runApp(
///   ControllerManager(
///     controllers: [
///       CustController(
///         (ref) => PlayerStateController(audioHandler),
///       ),
///       CustController(
///         (ref) => AllFileStateController(
///           ref.read<PlayerStateController>(),
///         ),
///       ),
///     ],
///     child: const MainApp(),
///   ),
/// );
/// ```
class ControllerManager extends StatefulWidget {
  final Widget child;

  /// use -> CustController
  final List<CustController> controllers;

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
    super.initState();

    final ref = ControllerRef(_controllersMap);

    for (final custCon in widget.controllers) {
      final con = custCon.callback(ref);

      _controllersMap[con.runtimeType] = con;

      con.init();
    }
  }

  @override
  void dispose() {
    for (final con in _controllersMap.values) {
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
