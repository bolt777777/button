import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:mobile_bodyguard/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../sos/presentation/sos_controller.dart';
import 'device_status_providers.dart';

/// Главный экран: SOS, статусы, звонок в ЦСМ, заглушка чата.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({
    super.key,
    this.csmPhoneE164 = '+78001234567',
  });

  final String csmPhoneE164;

  static bool _hasNetwork(List<ConnectivityResult> r) {
    return r.any(
      (e) =>
          e == ConnectivityResult.wifi ||
          e == ConnectivityResult.mobile ||
          e == ConnectivityResult.ethernet ||
          e == ConnectivityResult.vpn,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final sos = ref.watch(sosControllerProvider);
    final ctrl = ref.read(sosControllerProvider.notifier);

    final conn = ref.watch(connectivityStatusProvider);
    final bat = ref.watch(batteryLevelProvider);
    final gps = ref.watch(gpsOkProvider);

    ref.listen<SosUiState>(sosControllerProvider, (prev, next) {
      if (next.lastError != null && next.lastError != prev?.lastError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${next.lastError}')),
        );
      }
      if (next.pendingIncidentId != null &&
          next.pendingIncidentId != prev?.pendingIncidentId) {
        final msg = next.demoMode ? l10n.sosDemoMode : l10n.sosSent;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg)),
        );
      }
    });

    final online = conn.when(
      data: _hasNetwork,
      loading: () => true,
      error: (error, stackTrace) => false,
    );
    final gpsOk = gps.when(
      data: (v) => v,
      loading: () => true,
      error: (error, stackTrace) => false,
    );
    final batteryPct = bat.when(
      data: (v) => v,
      loading: () => -1,
      error: (error, stackTrace) => -1,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.homeTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline),
            tooltip: l10n.chatOperator,
            onPressed: () {
              showDialog<void>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text(l10n.chatOperator),
                  content: Text(l10n.chatPlaceholder),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            children: [
              _StatusRow(
                l10n: l10n,
                online: online,
                gpsOk: gpsOk,
                batteryPercent: batteryPct,
              ),
              const Spacer(),
              _SosButton(
                countdown: sos.countdown,
                l10n: l10n,
                onSosTap: ctrl.startCountdown,
                onCancel: ctrl.cancelCountdown,
              ),
              const Spacer(),
              FilledButton.tonalIcon(
                onPressed: () async {
                  final uri = Uri.parse('tel:$csmPhoneE164');
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri);
                  }
                },
                icon: const Icon(Icons.phone),
                label: Text(l10n.callCsm),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({
    required this.l10n,
    required this.online,
    required this.gpsOk,
    required this.batteryPercent,
  });

  final AppLocalizations l10n;
  final bool online;
  final bool gpsOk;
  final int batteryPercent;

  @override
  Widget build(BuildContext context) {
    final batLabel = batteryPercent >= 0
        ? l10n.statusBattery(batteryPercent)
        : l10n.statusUnknown;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _StatusChip(
          icon: Icons.wifi,
          label: l10n.statusConnection,
          ok: online,
        ),
        _StatusChip(
          icon: Icons.location_on,
          label: l10n.statusGps,
          ok: gpsOk,
        ),
        _StatusChip(
          icon: Icons.battery_std,
          label: batLabel,
          ok: batteryPercent > 15 || batteryPercent < 0,
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.icon,
    required this.label,
    required this.ok,
  });

  final IconData icon;
  final String label;
  final bool ok;

  @override
  Widget build(BuildContext context) {
    final color = ok ? Colors.green : Colors.orange;
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelSmall,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _SosButton extends StatelessWidget {
  const _SosButton({
    required this.countdown,
    required this.l10n,
    required this.onSosTap,
    required this.onCancel,
  });

  final int? countdown;
  final AppLocalizations l10n;
  final VoidCallback onSosTap;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final inCd = countdown != null;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Semantics(
          button: true,
          label: inCd
              ? l10n.sosCountdownSemantics(countdown!)
              : l10n.sosActivate,
          child: Material(
            color: Colors.red.shade700,
            shape: const CircleBorder(),
            elevation: 6,
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: inCd ? null : onSosTap,
              child: SizedBox(
                width: 200,
                height: 200,
                child: Center(
                  child: Text(
                    inCd ? '$countdown' : 'SOS',
                    style: TextStyle(
                      fontSize: inCd ? 64 : 42,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        if (inCd) ...[
          const SizedBox(height: 16),
          TextButton(
            onPressed: onCancel,
            child: Text(l10n.sosCancel),
          ),
        ],
      ],
    );
  }
}
