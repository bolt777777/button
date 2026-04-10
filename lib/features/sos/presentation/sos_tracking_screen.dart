import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/network/socket_provider.dart';
import '../../../core/theme/app_theme.dart';

class SosTrackingScreen extends ConsumerStatefulWidget {
  const SosTrackingScreen({
    super.key,
    required this.incidentId,
    required this.userLat,
    required this.userLng,
    this.guardId,
    this.guardName,
    this.guardLat,
    this.guardLng,
  });

  final String incidentId;
  final double userLat;
  final double userLng;
  final String? guardId;
  final String? guardName;
  final double? guardLat;
  final double? guardLng;

  @override
  ConsumerState<SosTrackingScreen> createState() => _SosTrackingScreenState();
}

class _SosTrackingScreenState extends ConsumerState<SosTrackingScreen>
    with SingleTickerProviderStateMixin {
  late final MapController _mapController;
  late AnimationController _pulseController;

  String? _guardId;
  String _guardName = '';
  LatLng? _guardPosition;
  String _status = 'searching';
  final List<LatLng> _guardTrail = [];

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _guardId = widget.guardId;
    _guardName = widget.guardName ?? '';
    if (widget.guardLat != null && widget.guardLng != null) {
      _guardPosition = LatLng(widget.guardLat!, widget.guardLng!);
      _status = 'assigned';
    }

    WidgetsBinding.instance.addPostFrameCallback((_) => _connectSocket());
  }

  void _connectSocket() {
    final socket = ref.read(socketProvider);
    if (socket == null) return;

    socket.on('alert-assigned', (data) {
      if (!mounted) return;
      final d = data as Map<String, dynamic>;
      if (d['id'] != widget.incidentId) return;
      final guard = d['guard'] as Map<String, dynamic>?;
      if (guard == null) return;
      setState(() {
        _guardId = guard['id'] as String;
        _guardName = guard['name'] as String? ?? '';
        final lat = (guard['currentLat'] as num?)?.toDouble();
        final lng = (guard['currentLng'] as num?)?.toDouble();
        if (lat != null && lng != null) {
          _guardPosition = LatLng(lat, lng);
        }
        _status = 'assigned';
      });
    });

    socket.on('guard-location', (data) {
      if (!mounted) return;
      final d = data as Map<String, dynamic>;
      if (_guardId == null || d['guardId'] != _guardId) return;
      final lat = (d['lat'] as num).toDouble();
      final lng = (d['lng'] as num).toDouble();
      setState(() {
        _guardPosition = LatLng(lat, lng);
        _guardTrail.add(_guardPosition!);
        if (_guardTrail.length > 100) _guardTrail.removeAt(0);
      });
    });

    socket.on('alert-resolved', (data) {
      if (!mounted) return;
      final d = data as Map<String, dynamic>;
      if (d['id'] != widget.incidentId) return;
      setState(() => _status = 'resolved');
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    final socket = ref.read(socketProvider);
    socket?.off('alert-assigned');
    socket?.off('guard-location');
    socket?.off('alert-resolved');
    super.dispose();
  }

  double _distanceKm() {
    if (_guardPosition == null) return 0;
    const d = Distance();
    return d.as(
          LengthUnit.Meter,
          LatLng(widget.userLat, widget.userLng),
          _guardPosition!,
        ) /
        1000.0;
  }

  int _etaMinutes() {
    final km = _distanceKm();
    return max(1, (km / 0.5).ceil());
  }

  @override
  Widget build(BuildContext context) {
    final userPos = LatLng(widget.userLat, widget.userLng);
    final hasGuard = _guardPosition != null;
    final center = hasGuard
        ? LatLng(
            (userPos.latitude + _guardPosition!.latitude) / 2,
            (userPos.longitude + _guardPosition!.longitude) / 2,
          )
        : userPos;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: center,
              initialZoom: hasGuard ? 14.0 : 15.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.bodyguard.app',
              ),
              if (hasGuard)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: [userPos, _guardPosition!],
                      color: kCoral.withValues(alpha: 0.6),
                      strokeWidth: 3,
                    ),
                  ],
                ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: userPos,
                    width: 48,
                    height: 48,
                    child: const _UserMarker(),
                  ),
                  if (hasGuard)
                    Marker(
                      point: _guardPosition!,
                      width: 52,
                      height: 52,
                      child: const _GuardMarker(),
                    ),
                ],
              ),
            ],
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _TopOverlay(
              status: _status,
              onBack: () => Navigator.of(context).pop(),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _BottomCard(
              status: _status,
              guardName: _guardName,
              distanceKm: _distanceKm(),
              etaMinutes: _etaMinutes(),
              pulseController: _pulseController,
              onCancel: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }
}

class _UserMarker extends StatelessWidget {
  const _UserMarker();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: kCoral,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: kCoral.withValues(alpha: 0.4),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: const Icon(Icons.person, color: Colors.white, size: 24),
    );
  }
}

class _GuardMarker extends StatelessWidget {
  const _GuardMarker();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF2196F3),
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2196F3).withValues(alpha: 0.4),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: const Icon(Icons.shield_rounded, color: Colors.white, size: 24),
    );
  }
}

class _TopOverlay extends StatelessWidget {
  const _TopOverlay({required this.status, required this.onBack});
  final String status;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    String title;
    switch (status) {
      case 'searching':
        title = 'Searching for guard...';
        break;
      case 'assigned':
        title = 'Guard is on the way';
        break;
      case 'resolved':
        title = 'Incident resolved';
        break;
      default:
        title = 'SOS Active';
    }

    return Container(
      padding: EdgeInsets.only(top: topPad + 8, left: 16, right: 16, bottom: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white,
            Colors.white.withValues(alpha: 0.95),
            Colors.white.withValues(alpha: 0),
          ],
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack,
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.arrow_back_rounded, size: 20, color: kTextPrimary),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: kTextPrimary,
              ),
            ),
          ),
          if (status == 'searching')
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(kCoral),
              ),
            ),
        ],
      ),
    );
  }
}

class _BottomCard extends StatelessWidget {
  const _BottomCard({
    required this.status,
    required this.guardName,
    required this.distanceKm,
    required this.etaMinutes,
    required this.pulseController,
    required this.onCancel,
  });

  final String status;
  final String guardName;
  final double distanceKm;
  final int etaMinutes;
  final AnimationController pulseController;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(20, 24, 20, bottomPad + 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: status == 'searching'
          ? _buildSearching()
          : status == 'resolved'
              ? _buildResolved()
              : _buildTracking(context),
    );
  }

  Widget _buildSearching() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: pulseController,
          builder: (_, child) => Transform.scale(
            scale: 0.9 + pulseController.value * 0.1,
            child: child,
          ),
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: kCoralBg,
              border: Border.all(color: kCoral.withValues(alpha: 0.3), width: 2),
            ),
            child: const Icon(Icons.phone_in_talk_rounded, color: kCoral, size: 28),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Looking for the nearest guard',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: kTextPrimary,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Please stay at your current location',
          style: TextStyle(fontSize: 14, color: kTextSecondary),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton(
            onPressed: onCancel,
            child: const Text('Cancel SOS'),
          ),
        ),
      ],
    );
  }

  Widget _buildTracking(BuildContext context) {
    final distLabel = distanceKm < 1
        ? '${(distanceKm * 1000).round()} m'
        : '${distanceKm.toStringAsFixed(1)} km';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.shield_rounded, color: Color(0xFF2196F3), size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    guardName.isNotEmpty ? guardName : 'Guard',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: kTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'En route to your location',
                    style: TextStyle(
                      fontSize: 13,
                      color: kGreen,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$etaMinutes min',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: kTextPrimary,
                  ),
                ),
                Text(
                  distLabel,
                  style: const TextStyle(fontSize: 13, color: kTextSecondary),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 50,
                child: FilledButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.phone_rounded, size: 18),
                  label: const Text('Call'),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 50,
                child: OutlinedButton(
                  onPressed: onCancel,
                  child: const Text('Cancel'),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildResolved() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFFE8F5E9),
          ),
          child: const Icon(Icons.check_rounded, color: kGreen, size: 32),
        ),
        const SizedBox(height: 16),
        const Text(
          'Incident resolved',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: kTextPrimary,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'You are safe. The guard has confirmed the situation.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: kTextSecondary),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: FilledButton(
            onPressed: onCancel,
            child: const Text('Back to Home'),
          ),
        ),
      ],
    );
  }
}
