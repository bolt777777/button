import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_bodyguard/l10n/app_localizations.dart';
import 'package:mobile_bodyguard/l10n/resolve_l10n.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../chat/chat_screen.dart';
import '../sos/presentation/sos_controller.dart';
import 'device_status_providers.dart';

/// Главный экран: SOS, статусы, звонок в ЦСМ, чат.
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
    final l10n = resolveAppLocalizations(context);
    final sos = ref.watch(sosControllerProvider);
    final ctrl = ref.read(sosControllerProvider.notifier);
    final scheme = Theme.of(context).colorScheme;

    final conn = ref.watch(connectivityStatusProvider);
    final bat = ref.watch(batteryLevelProvider);
    final gps = ref.watch(gpsOkProvider);

    ref.listen<SosUiState>(sosControllerProvider, (prev, next) {
      if (!context.mounted) return;
      if (next.lastError != null && next.lastError != prev?.lastError) {
        final err = next.lastError;
        final text = err is Exception
            ? err.toString()
            : '$err';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(text)),
        );
      }
      if (next.pendingIncidentId != null &&
          next.pendingIncidentId != prev?.pendingIncidentId) {
        HapticFeedback.heavyImpact();
        final msg = next.demoMode ? l10n.sosDemoMode : l10n.sosSent;
        if (!context.mounted) return;
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
      backgroundColor: scheme.surface,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          l10n.homeTitle,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: -0.4,
              ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: IconButton(
              style: IconButton.styleFrom(
                shape: const CircleBorder(),
                backgroundColor: scheme.secondaryContainer,
                foregroundColor: scheme.onSecondaryContainer,
              ),
              icon: const Icon(Icons.chat_bubble_outline_rounded),
              tooltip: l10n.chatOperator,
              onPressed: () {
                Navigator.of(context).push<void>(
                  MaterialPageRoute<void>(
                    builder: (context) => const ChatScreen(),
                    fullscreenDialog: false,
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              scheme.surfaceContainerLowest,
              scheme.surface,
              const Color(0xFFE8E8ED),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              children: [
                const SizedBox(height: 4),
                _FrostedStrip(
                  child: _StatusStrip(
                    l10n: l10n,
                    scheme: scheme,
                    online: online,
                    gpsOk: gpsOk,
                    batteryPercent: batteryPct,
                  ),
                ),
                const Spacer(flex: 2),
                _SosHero(
                  countdown: sos.countdown,
                  l10n: l10n,
                  onSosTap: ctrl.startCountdown,
                  onCancel: ctrl.cancelCountdown,
                ),
                const Spacer(flex: 2),
                _CallCsmCard(
                  l10n: l10n,
                  scheme: scheme,
                  csmPhoneE164: csmPhoneE164,
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FrostedStrip extends StatelessWidget {
  const _FrostedStrip({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    // Без BackdropFilter: на части реальных iPhone размытие даёт пустой кадр (белый экран).
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          color: Colors.white.withValues(alpha: 0.78),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.9),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: child,
        ),
      ),
    );
  }
}

class _StatusStrip extends StatelessWidget {
  const _StatusStrip({
    required this.l10n,
    required this.scheme,
    required this.online,
    required this.gpsOk,
    required this.batteryPercent,
  });

  final AppLocalizations l10n;
  final ColorScheme scheme;
  final bool online;
  final bool gpsOk;
  final int batteryPercent;

  @override
  Widget build(BuildContext context) {
    final batLabel = batteryPercent >= 0
        ? l10n.statusBattery(batteryPercent)
        : l10n.statusUnknown;
    return Row(
      children: [
        Expanded(
          child: _StatusTile(
            icon: Icons.wifi_rounded,
            label: l10n.statusConnection,
            ok: online,
            scheme: scheme,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatusTile(
            icon: Icons.location_on_rounded,
            label: l10n.statusGps,
            ok: gpsOk,
            scheme: scheme,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatusTile(
            icon: Icons.battery_charging_full_rounded,
            label: batLabel,
            ok: batteryPercent > 15 || batteryPercent < 0,
            scheme: scheme,
          ),
        ),
      ],
    );
  }
}

class _StatusTile extends StatelessWidget {
  const _StatusTile({
    required this.icon,
    required this.label,
    required this.ok,
    required this.scheme,
  });

  final IconData icon;
  final String label;
  final bool ok;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    final iconColor = ok ? const Color(0xFF34C759) : const Color(0xFFFF9500);
    return Column(
      children: [
        Icon(icon, color: iconColor, size: 24),
        const SizedBox(height: 6),
        Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: scheme.onSurface.withValues(alpha: 0.82),
                fontWeight: FontWeight.w500,
                height: 1.15,
              ),
        ),
      ],
    );
  }
}

BoxDecoration _sosCircleDecoration(LinearGradient gradient) {
  return BoxDecoration(
    shape: BoxShape.circle,
    gradient: gradient,
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.14),
        blurRadius: 28,
        offset: const Offset(0, 16),
      ),
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.06),
        blurRadius: 8,
        offset: const Offset(0, 4),
      ),
    ],
  );
}

class _SosCircleLabel extends StatelessWidget {
  const _SosCircleLabel({
    required this.inCd,
    required this.countdown,
  });

  final bool inCd;
  final int? countdown;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        inCd ? '$countdown' : 'SOS',
        style: TextStyle(
          fontSize: inCd ? 64 : 42,
          fontWeight: FontWeight.w800,
          color: Colors.white,
          letterSpacing: inCd ? 0 : 2.5,
          height: 1,
        ),
      ),
    );
  }
}

class _SosHero extends StatelessWidget {
  const _SosHero({
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
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: inCd
          ? const [Color(0xFFFF6B6B), Color(0xFFD32F2F)]
          : const [Color(0xFFFF1744), Color(0xFFB71C1C)],
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Semantics(
          button: true,
          label: inCd
              ? l10n.sosCountdownSemantics(countdown!)
              : l10n.sosActivate,
          child: inCd
              ? GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onDoubleTap: onCancel,
                  child: Container(
                    width: 216,
                    height: 216,
                    decoration: _sosCircleDecoration(gradient),
                    child: _SosCircleLabel(inCd: inCd, countdown: countdown),
                  ),
                )
              : Material(
                  color: Colors.transparent,
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: onSosTap,
                    child: Ink(
                      width: 216,
                      height: 216,
                      decoration: _sosCircleDecoration(gradient),
                      child: _SosCircleLabel(inCd: inCd, countdown: countdown),
                    ),
                  ),
                ),
        ),
        if (inCd) ...[
          const SizedBox(height: 16),
          Text(
            l10n.sosDoubleTapHint,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  height: 1.35,
                ),
          ),
          TextButton(
            onPressed: onCancel,
            child: Text(l10n.sosCancel),
          ),
        ],
      ],
    );
  }
}

class _CallCsmCard extends StatelessWidget {
  const _CallCsmCard({
    required this.l10n,
    required this.scheme,
    required this.csmPhoneE164,
  });

  final AppLocalizations l10n;
  final ColorScheme scheme;
  final String csmPhoneE164;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white.withValues(alpha: 0.72),
          border: Border.all(color: Colors.white.withValues(alpha: 0.85)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: FilledButton.tonalIcon(
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(54),
              backgroundColor: scheme.surfaceContainerHighest,
              foregroundColor: scheme.onSurface,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: () async {
              final uri = Uri.parse('tel:$csmPhoneE164');
              if (await canLaunchUrl(uri)) {
                await launchUrl(
                  uri,
                  mode: LaunchMode.externalApplication,
                );
              }
            },
            icon: Icon(Icons.phone_in_talk_rounded, color: scheme.primary),
            label: Text(
              l10n.callCsm,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }
}
