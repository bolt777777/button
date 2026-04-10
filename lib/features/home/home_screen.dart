import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_theme.dart';
import '../../l10n/resolve_l10n.dart';
import '../auth/auth_provider.dart';
import '../sos/presentation/sos_controller.dart';
import '../sos/presentation/sos_tracking_screen.dart';
import 'device_status_providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key, this.csmPhoneE164 = '+78001234567'});

  final String csmPhoneE164;

  static bool _hasNetwork(List<ConnectivityResult> r) {
    return r.any((e) =>
        e == ConnectivityResult.wifi ||
        e == ConnectivityResult.mobile ||
        e == ConnectivityResult.ethernet ||
        e == ConnectivityResult.vpn);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = resolveAppLocalizations(context);
    final sos = ref.watch(sosControllerProvider);
    final ctrl = ref.read(sosControllerProvider.notifier);
    final auth = ref.watch(authProvider);

    final conn = ref.watch(connectivityStatusProvider);
    final bat = ref.watch(batteryLevelProvider);
    final gps = ref.watch(gpsOkProvider);

    ref.listen<SosUiState>(sosControllerProvider, (prev, next) {
      if (!context.mounted) return;

      if (next.lastError != null && next.lastError != prev?.lastError) {
        final err = next.lastError;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$err')),
        );
      }

      if (next.pendingIncidentId != null &&
          next.pendingIncidentId != prev?.pendingIncidentId &&
          next.userLat != null &&
          next.userLng != null) {
        HapticFeedback.heavyImpact();
        Navigator.of(context).push<void>(
          MaterialPageRoute(
            builder: (_) => SosTrackingScreen(
              incidentId: next.pendingIncidentId!,
              userLat: next.userLat!,
              userLng: next.userLng!,
              guardId: next.assignedGuardId,
              guardName: next.assignedGuardName,
              guardLat: next.assignedGuardLat,
              guardLng: next.assignedGuardLng,
            ),
          ),
        );
      }
    });

    final online = conn.when(
      data: _hasNetwork,
      loading: () => true,
      error: (_, __) => false,
    );
    final gpsOk = gps.when(
      data: (v) => v,
      loading: () => true,
      error: (_, __) => false,
    );
    final batteryPct = bat.when(
      data: (v) => v,
      loading: () => -1,
      error: (_, __) => -1,
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 12),
              _TopBar(name: auth.email?.split('@').first ?? 'User', onLogout: () {
                ref.read(authProvider.notifier).logout();
              }),
              const Spacer(flex: 2),
              Text(
                l10n.homeTitle.isNotEmpty ? l10n.homeTitle : 'Are you in an\nemergency?',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: kTextPrimary,
                  height: 1.2,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  l10n.sosActivate.isNotEmpty
                      ? l10n.sosActivate
                      : 'Press the SOS button to request immediate help. We will dispatch the nearest guard to your location.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    color: kTextSecondary,
                    height: 1.5,
                  ),
                ),
              ),
              const Spacer(flex: 2),
              _SosButton(
                countdown: sos.countdown,
                onTap: ctrl.startCountdown,
                onCancel: ctrl.cancelCountdown,
              ),
              if (sos.isCountingDown) ...[
                const SizedBox(height: 16),
                TextButton(
                  onPressed: ctrl.cancelCountdown,
                  child: Text(
                    l10n.sosCancel.isNotEmpty ? l10n.sosCancel : 'Cancel',
                    style: const TextStyle(color: kTextSecondary, fontSize: 15),
                  ),
                ),
              ],
              const Spacer(flex: 3),
              _StatusRow(online: online, gpsOk: gpsOk, batteryPct: batteryPct),
              const SizedBox(height: 16),
              _CallButton(phone: csmPhoneE164, label: l10n.callCsm),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.name, required this.onLogout});
  final String name;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Home', style: TextStyle(fontSize: 13, color: kTextSecondary)),
            Text(
              'Hello, $name',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: kTextPrimary,
              ),
            ),
          ],
        ),
        const Spacer(),
        GestureDetector(
          onTap: onLogout,
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: kCoralBg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.person_outline_rounded, color: kCoral, size: 22),
          ),
        ),
      ],
    );
  }
}

class _SosButton extends StatelessWidget {
  const _SosButton({
    required this.countdown,
    required this.onTap,
    required this.onCancel,
  });

  final int? countdown;
  final VoidCallback onTap;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final inCd = countdown != null;

    return GestureDetector(
      onTap: inCd ? null : onTap,
      onDoubleTap: inCd ? onCancel : null,
      child: Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: inCd
                ? const [Color(0xFFF0877F), Color(0xFFD94D47)]
                : const [Color(0xFFF0877F), Color(0xFFE8615A)],
          ),
          boxShadow: [
            BoxShadow(
              color: kCoral.withValues(alpha: 0.35),
              blurRadius: 40,
              offset: const Offset(0, 16),
            ),
            BoxShadow(
              color: kCoral.withValues(alpha: 0.15),
              blurRadius: 80,
              spreadRadius: 20,
            ),
          ],
        ),
        child: Center(
          child: Text(
            inCd ? '$countdown' : 'SOS',
            style: TextStyle(
              fontSize: inCd ? 60 : 42,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: inCd ? 0 : 3,
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({
    required this.online,
    required this.gpsOk,
    required this.batteryPct,
  });

  final bool online;
  final bool gpsOk;
  final int batteryPct;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatusDot(icon: Icons.wifi_rounded, ok: online, label: 'Network'),
          _StatusDot(icon: Icons.location_on_rounded, ok: gpsOk, label: 'GPS'),
          _StatusDot(
            icon: Icons.battery_charging_full_rounded,
            ok: batteryPct > 15 || batteryPct < 0,
            label: batteryPct >= 0 ? '$batteryPct%' : '—',
          ),
        ],
      ),
    );
  }
}

class _StatusDot extends StatelessWidget {
  const _StatusDot({required this.icon, required this.ok, required this.label});
  final IconData icon;
  final bool ok;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: ok ? kGreen : kOrange),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 13, color: kTextSecondary)),
      ],
    );
  }
}

class _CallButton extends StatelessWidget {
  const _CallButton({required this.phone, required this.label});
  final String phone;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: OutlinedButton.icon(
        onPressed: () async {
          final uri = Uri.parse('tel:$phone');
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          }
        },
        icon: const Icon(Icons.phone_rounded, size: 20),
        label: Text(label.isNotEmpty ? label : 'Call Security Center'),
      ),
    );
  }
}
