import 'package:battery_plus/battery_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

final connectivityStatusProvider = StreamProvider<List<ConnectivityResult>>(
  (ref) async* {
    final c = Connectivity();
    yield await c.checkConnectivity();
    await for (final r in c.onConnectivityChanged) {
      yield r;
    }
  },
);

final batteryLevelProvider = StreamProvider<int>((ref) async* {
  final battery = Battery();
  yield await battery.batteryLevel;
  await for (final _ in Stream.periodic(const Duration(seconds: 20))) {
    yield await battery.batteryLevel;
  }
});

final gpsOkProvider = FutureProvider<bool>((ref) async {
  final enabled = await Geolocator.isLocationServiceEnabled();
  if (!enabled) return false;
  final p = await Geolocator.checkPermission();
  return p == LocationPermission.always || p == LocationPermission.whileInUse;
});
