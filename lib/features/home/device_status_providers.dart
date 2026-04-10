import 'package:battery_plus/battery_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

/// Устойчивый поток: при сбое плагина не роняем весь UI.
final connectivityStatusProvider = StreamProvider<List<ConnectivityResult>>(
  (ref) async* {
    final c = Connectivity();
    try {
      yield await c.checkConnectivity();
    } catch (_) {
      yield [ConnectivityResult.mobile];
    }
    try {
      await for (final r in c.onConnectivityChanged) {
        yield r;
      }
    } catch (_) {
      yield [ConnectivityResult.mobile];
    }
  },
);

final batteryLevelProvider = StreamProvider<int>((ref) async* {
  final battery = Battery();
  try {
    yield await battery.batteryLevel;
  } catch (_) {
    yield -1;
  }
  try {
    await for (final _ in Stream.periodic(const Duration(seconds: 20))) {
      yield await battery.batteryLevel;
    }
  } catch (_) {
    yield -1;
  }
});

final gpsOkProvider = FutureProvider<bool>((ref) async {
  try {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) return false;
    final p = await Geolocator.checkPermission();
    return p == LocationPermission.always || p == LocationPermission.whileInUse;
  } catch (_) {
    return false;
  }
});
