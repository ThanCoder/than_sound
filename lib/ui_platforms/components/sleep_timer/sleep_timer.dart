import 'dart:async';

enum SleepTimerMode { off, afterDuration, endOfSong }

class SleepTimer {
  Timer? _timer;
  DateTime? _endTime;

  SleepTimerMode _mode = SleepTimerMode.off;

  SleepTimerMode get mode => _mode;

  Duration? get remaining {
    final endTime = _endTime;

    if (endTime == null) {
      return null;
    }

    final value = endTime.difference(DateTime.now());

    return value.isNegative ? Duration.zero : value;
  }

  void start(Duration duration, void Function() onFinished) {
    cancel();

    _mode = SleepTimerMode.afterDuration;
    _endTime = DateTime.now().add(duration);

    _timer = Timer(duration, () {
      _timer = null;
      _endTime = null;
      _mode = SleepTimerMode.off;

      onFinished();
    });
  }

  void endOfSong() {
    cancel();
    _mode = SleepTimerMode.endOfSong;
  }

  bool onSongCompleted() {
    print('onSongCompleted: $_mode');
    if (_mode != SleepTimerMode.endOfSong) {
      return false;
    }

    _mode = SleepTimerMode.off;
    return true;
  }

  void cancel() {
    _timer?.cancel();
    _timer = null;
    _endTime = null;
    _mode = SleepTimerMode.off;
  }

  void dispose() {
    cancel();
  }
}
