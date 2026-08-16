import 'dart:async';

class SleepTimer {
  Timer? _timer;
  DateTime? _endTime;

  bool get isActive => _timer?.isActive ?? false;

  Duration? get remaining {
    final end = _endTime;
    if (end == null) return null;

    final value = end.difference(DateTime.now());

    if (value.isNegative) {
      return Duration.zero;
    }

    return value;
  }

  void start(Duration duration, {required void Function() onFinished}) {
    cancel();

    _endTime = DateTime.now().add(duration);

    _timer = Timer(duration, () {
      _timer = null;
      _endTime = null;

      onFinished();
    });
  }

  void cancel() {
    _timer?.cancel();
    _timer = null;
    _endTime = null;
  }

  void dispose() {
    cancel();
  }
}
