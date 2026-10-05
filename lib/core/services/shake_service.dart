import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:sensors_plus/sensors_plus.dart';

/// Detecta un "shake" (sacudida fuerte) del dispositivo vía acelerómetro.
class ShakeService {
  ShakeService._();
  static final ShakeService instance = ShakeService._();

  StreamSubscription<AccelerometerEvent>? _sub;
  DateTime _lastShake = DateTime.fromMillisecondsSinceEpoch(0);

  /// [onShake] se dispara como máximo una vez cada 2 s.
  void start(VoidCallback onShake) {
    if (!kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS)) {
      _sub ??= accelerometerEventStream().listen((event) {
        final magnitude = math.sqrt(
          event.x * event.x + event.y * event.y + event.z * event.z,
        );
        if (magnitude > 25.0) {
          final now = DateTime.now();
          if (now.difference(_lastShake).inSeconds >= 2) {
            _lastShake = now;
            onShake();
          }
        }
      });
    }
  }

  void stop() {
    _sub?.cancel();
    _sub = null;
  }
}
