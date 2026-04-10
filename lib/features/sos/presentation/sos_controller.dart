import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:uuid/uuid.dart';

import '../data/sos_dto.dart';
import '../data/sos_repository_provider.dart';

const int _sosCountdownSeconds = 3;

class SosUiState {
  const SosUiState({
    this.countdown,
    this.pendingIncidentId,
    this.userLat,
    this.userLng,
    this.assignedGuardId,
    this.assignedGuardName,
    this.assignedGuardLat,
    this.assignedGuardLng,
    this.lastError,
    this.demoMode = false,
  });

  final int? countdown;
  final String? pendingIncidentId;
  final double? userLat;
  final double? userLng;
  final String? assignedGuardId;
  final String? assignedGuardName;
  final double? assignedGuardLat;
  final double? assignedGuardLng;
  final Object? lastError;
  final bool demoMode;

  bool get isCountingDown => countdown != null;

  SosUiState copyWith({
    int? countdown,
    String? pendingIncidentId,
    double? userLat,
    double? userLng,
    String? assignedGuardId,
    String? assignedGuardName,
    double? assignedGuardLat,
    double? assignedGuardLng,
    Object? lastError,
    bool? demoMode,
    bool clearCountdown = false,
    bool clearError = false,
    bool clearIncident = false,
  }) {
    return SosUiState(
      countdown: clearCountdown ? null : (countdown ?? this.countdown),
      pendingIncidentId:
          clearIncident ? null : (pendingIncidentId ?? this.pendingIncidentId),
      userLat: clearIncident ? null : (userLat ?? this.userLat),
      userLng: clearIncident ? null : (userLng ?? this.userLng),
      assignedGuardId:
          clearIncident ? null : (assignedGuardId ?? this.assignedGuardId),
      assignedGuardName:
          clearIncident ? null : (assignedGuardName ?? this.assignedGuardName),
      assignedGuardLat:
          clearIncident ? null : (assignedGuardLat ?? this.assignedGuardLat),
      assignedGuardLng:
          clearIncident ? null : (assignedGuardLng ?? this.assignedGuardLng),
      lastError: clearError ? null : (lastError ?? this.lastError),
      demoMode: demoMode ?? this.demoMode,
    );
  }
}

final sosControllerProvider =
    StateNotifierProvider<SosController, SosUiState>((ref) {
  return SosController(ref);
});

class SosController extends StateNotifier<SosUiState> {
  SosController(this._ref) : super(const SosUiState());

  final Ref _ref;
  Timer? _timer;
  int _generation = 0;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void startCountdown() {
    if (state.isCountingDown) return;
    _generation++;
    final gen = _generation;
    _timer?.cancel();
    state = state.copyWith(
      clearError: true,
      clearIncident: true,
      countdown: _sosCountdownSeconds,
    );
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (gen != _generation) {
        t.cancel();
        return;
      }
      final left = (state.countdown ?? 1) - 1;
      if (left <= 0) {
        t.cancel();
        state = state.copyWith(clearCountdown: true);
        unawaited(_confirmSos());
      } else {
        state = state.copyWith(countdown: left);
      }
    });
  }

  void cancelCountdown() {
    _generation++;
    _timer?.cancel();
    _timer = null;
    state = state.copyWith(clearCountdown: true);
  }

  void resetSos() {
    state = state.copyWith(clearIncident: true, clearError: true);
  }

  Future<void> _confirmSos() async {
    final repo = _ref.read(sosRepositoryProvider);
    final clientRequestId = const Uuid().v4();
    const mock = bool.fromEnvironment('MOCK_SOS', defaultValue: false);

    try {
      final serviceOn = await Geolocator.isLocationServiceEnabled();
      if (!serviceOn) {
        state = state.copyWith(lastError: 'GPS выключен');
        return;
      }
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        state = state.copyWith(lastError: 'Нет доступа к геолокации');
        return;
      }

      late Position pos;
      try {
        pos = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.medium,
            timeLimit: Duration(seconds: 18),
          ),
        );
      } on TimeoutException {
        state = state.copyWith(
          lastError:
              'Геолокация не ответила вовремя. Проверьте GPS в настройках.',
        );
        return;
      }

      final res = await repo.createSos(
        CreateSosRequest(
          latitude: pos.latitude,
          longitude: pos.longitude,
          accuracyMeters: pos.accuracy,
          capturedAt: DateTime.now().toUtc(),
          clientRequestId: clientRequestId,
        ),
      );

      state = state.copyWith(
        pendingIncidentId: res.incidentId,
        userLat: pos.latitude,
        userLng: pos.longitude,
        assignedGuardId: res.guard?.id,
        assignedGuardName: res.guard?.name,
        assignedGuardLat: res.guard?.lat,
        assignedGuardLng: res.guard?.lng,
        clearError: true,
        demoMode: mock,
      );
    } catch (e) {
      state = state.copyWith(lastError: e);
    }
  }
}
