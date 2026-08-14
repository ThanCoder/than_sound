import 'dart:async';
import 'dart:math';

import 'package:cfb_store/cfb_store.dart';
import 'package:mpv_audio_kit/mpv_audio_kit.dart';
import 'package:than_sound/const_keys.dart';
import 'package:than_sound/core/controllers/player/amplitude/amplitude_type.dart';

mixin BassAmplitudeMixin {
  PlayerStream get stream;

  // ===========================================================================
  // BASS RANGE
  // ===========================================================================

  static const double _bassLowHz = 40.0;
  static const double _bassHighHz = 180.0;

  // ===========================================================================
  // SENSITIVITY
  // ===========================================================================

  /// Bass change -> cover movement sensitivity.
  static const double _sensitivity = 8.0;

  /// Ignore very small bass changes.
  static const double _noiseFloor = 0.015;

  /// Minimum bass movement required to trigger the cover.
  static const double _movementThreshold = 0.003;

  // ===========================================================================
  // SMOOTHING
  // ===========================================================================

  /// Smooth raw FFT bass before detecting movement.
  static const double _bassSmoothing = 0.35;

  /// Cover attack.
  ///
  /// Higher = faster response.
  static const double _attack = 0.85;

  /// Cover decay.
  ///
  /// Higher = returns to zero faster.
  static const double _decay = 0.22;

  // ===========================================================================
  // STREAM
  // ===========================================================================

  final _bassAmplitudeController = StreamController<double>.broadcast();

  Stream<double> get bassAmplitude => _bassAmplitudeController.stream;

  // ===========================================================================
  // SUBSCRIPTIONS
  // ===========================================================================

  StreamSubscription<FftFrame>? _fftSub;
  StreamSubscription? _configStoreSub;

  // ===========================================================================
  // UPDATE RATE
  // ===========================================================================

  DateTime _lastUpdate = DateTime.fromMillisecondsSinceEpoch(0);

  Duration _updateInterval = const Duration(milliseconds: 50);

  Duration get amplitudeUpdateInterval => _updateInterval;

  CFBStore get configStore => CFBStore.getInstance;

  // ===========================================================================
  // STATE
  // ===========================================================================

  /// Current cover value.
  double _bassValue = 0.0;

  /// Smoothed bass energy.
  double _smoothBass = 0.0;

  /// Previous smoothed bass energy.
  double _previousBass = 0.0;

  // ===========================================================================
  // INITIALIZATION
  // ===========================================================================

  void onListenBassAmplitude() {
    _configStoreSub?.cancel();

    _configStoreSub = configStore.events.listen((event) {
      if (event is! PutValue) {
        return;
      }

      if (event.key != audioAmplitudeAnimationTypeKey) {
        return;
      }

      _configure();
    });

    _configure();
  }

  // ===========================================================================
  // CONFIGURE
  // ===========================================================================

  void _configure() {
    final type = AmplitudeType.fromValue(
      configStore.getString(
        audioAmplitudeAnimationTypeKey,
        audioAmplitudeAnimationDefaultType.name,
      ),
    );

    // Disabled.
    if (type == .none) {
      _fftSub?.cancel();
      _fftSub = null;

      resetBassAmplitude();
      return;
    }

    _updateInterval = type.toDuration;

    _fftSub ??= stream.fft.listen(_onFft);
  }

  // ===========================================================================
  // FFT
  // ===========================================================================

  void _onFft(FftFrame frame) {
    final now = DateTime.now();

    if (now.difference(_lastUpdate) < _updateInterval) {
      return;
    }

    _lastUpdate = now;

    final rawBass = _calculateBass(frame);

    // -------------------------------------------------------------------------
    // 1. Smooth raw bass
    // -------------------------------------------------------------------------

    _smoothBass += (rawBass - _smoothBass) * _bassSmoothing;

    // -------------------------------------------------------------------------
    // 2. Detect ONLY bass increase
    // -------------------------------------------------------------------------

    final movement = _smoothBass - _previousBass;

    _previousBass = _smoothBass;

    // -------------------------------------------------------------------------
    // 3. No bass / very small movement
    // -------------------------------------------------------------------------

    if (_smoothBass <= _noiseFloor || movement <= _movementThreshold) {
      // Important:
      // Don't immediately set to zero.
      // Let the cover naturally fall back.
      _decayBass();

      return;
    }

    // -------------------------------------------------------------------------
    // 4. Bass hit -> 0..1
    // -------------------------------------------------------------------------

    final target = (movement * _sensitivity).clamp(0.0, 1.0);

    // -------------------------------------------------------------------------
    // 5. Fast attack
    // -------------------------------------------------------------------------

    _bassValue += (target - _bassValue) * _attack;

    _bassValue = _bassValue.clamp(0.0, 1.0);

    _emitBass();
  }

  // ===========================================================================
  // DECAY
  // ===========================================================================

  void _decayBass() {
    _bassValue *= (1.0 - _decay);

    if (_bassValue < 0.01) {
      _bassValue = 0.0;
    }

    _emitBass();
  }

  // ===========================================================================
  // EMIT
  // ===========================================================================

  void _emitBass() {
    _bassAmplitudeController.add(_bassValue.clamp(0.0, 1.0));
  }

  // ===========================================================================
  // BASS ANALYSIS
  // ===========================================================================

  double _calculateBass(FftFrame frame) {
    final bins = frame.bins;

    if (bins.isEmpty) {
      return 0.0;
    }

    final fftSize = bins.length * 2;

    double energy = 0.0;
    int count = 0;

    for (var i = 1; i < bins.length; i++) {
      final frequency = i * frame.sampleRate / fftSize;

      if (frequency < _bassLowHz) {
        continue;
      }

      if (frequency > _bassHighHz) {
        break;
      }

      final value = bins[i];

      energy += value * value;
      count++;
    }

    if (count == 0) {
      return 0.0;
    }

    return sqrt(energy / count);
  }

  // ===========================================================================
  // RESET
  // ===========================================================================

  /// Call when a new song starts.
  void resetBassAmplitude() {
    _bassValue = 0.0;
    _smoothBass = 0.0;
    _previousBass = 0.0;

    _lastUpdate = DateTime.fromMillisecondsSinceEpoch(0);
  }

  // ===========================================================================
  // DISPOSE
  // ===========================================================================

  Future<void> disposeBassAmplitude() async {
    await _configStoreSub?.cancel();
    await _fftSub?.cancel();

    await _bassAmplitudeController.close();
  }
}
