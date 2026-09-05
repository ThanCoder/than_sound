// ignore_for_file: unused_element

import 'dart:async';
import 'dart:math' as math;

import 'package:mpv_audio_kit/mpv_audio_kit.dart';
import 'package:than_sound/core/controllers/player_state/player_state_controller.dart';

class PlayerFadeController {
  PlayerFadeController(this._controller);

  final PlayerStateController _controller;

  Player get player => _controller.player;

  Duration get duration => _controller.state.fadeDuration;

  int get steps => _controller.state.fadeSteps;

  double get originalVolume => _controller.state.audioVolume;

  int _generation = 0;

  bool _cancelled = false;

  bool get isCancelled => _cancelled;

  void cancel() {
    _generation++;
    _cancelled = true;
  }

  int _nextGeneration() {
    _cancelled = false;
    return ++_generation;
  }

  double _curve(double t) {
    // Smooth audio fade curve.
    //
    // Linear:
    //   0.0 → 0.1 → 0.2 → ...
    //
    // This curve gives a more natural perceived fade.
    return math.pow(t, 2.0).toDouble();
  }

  Future<void> fadeOut() async {
    // final generation = _nextGeneration();

    // final volume = player.state.volume;

    // final stepDuration = duration ~/ steps;

    // for (var i = steps - 1; i >= 0; i--) {
    //   await Future.delayed(stepDuration);

    //   if (generation != _generation) {
    //     return;
    //   }

    //   final t = i / steps;

    //   final value = volume * _curve(t);

    //   await player.setVolume(value);
    // }

    // if (generation != _generation) {
    //   return;
    // }

    // await player.setVolume(0);
  }

  Future<void> fadeIn() async {
    // final generation = _nextGeneration();

    // final volume = originalVolume;

    // await player.setVolume(0);

    // final stepDuration = duration ~/ steps;

    // for (var i = 1; i <= steps; i++) {
    //   await Future.delayed(stepDuration);

    //   if (generation != _generation) {
    //     return;
    //   }

    //   final t = i / steps;

    //   final value = volume * _curve(t);

    //   await player.setVolume(value);
    // }

    // if (generation != _generation) {
    //   return;
    // }

    // await player.setVolume(volume);
  }

  Future<void> dispose() async {
    cancel();
  }
}
