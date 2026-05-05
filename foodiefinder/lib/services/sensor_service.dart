import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:sensors_plus/sensors_plus.dart';

class SensorService {
  static const double _shakeThreshold = 15.0;  // m/s²
  static const int _shakeCooldownMs = 2000;      // minimal 2 detik antar shake

  DateTime? _lastShakeTime;
  StreamSubscription? _accelSub;

  void startShakeDetection(VoidCallback onShake) {
    _accelSub = accelerometerEventStream().listen((event) {
      final magnitude = sqrt(event.x * event.x + event.y * event.y + event.z * event.z);
      // Kurangi gravitasi bumi (~9.8 m/s²)
      final netAccel = (magnitude - 9.8).abs();

      if (netAccel > _shakeThreshold) {
        final now = DateTime.now();
        if (_lastShakeTime == null ||
            now.difference(_lastShakeTime!).inMilliseconds > _shakeCooldownMs) {
          _lastShakeTime = now;
          onShake();
        }
      }
    });
  }

  void dispose() {
    _accelSub?.cancel();
  }
}
