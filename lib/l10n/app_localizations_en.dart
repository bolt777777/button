// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Bodyguard';

  @override
  String get homeTitle => 'Bodyguard';

  @override
  String get sosActivate => 'Activate alarm';

  @override
  String get sosCancel => 'Cancel';

  @override
  String get sosDoubleTapHint => 'Double-tap the SOS button to cancel';

  @override
  String sosCountdownSemantics(int seconds) {
    return 'Sending in $seconds s — double-tap SOS to cancel';
  }

  @override
  String get sosSent => 'Alarm signal sent';

  @override
  String get sosDemoMode => 'Demo: SOS recorded locally (no server)';

  @override
  String get sosError => 'Failed to send SOS';

  @override
  String get callCsm => 'Call monitoring center';

  @override
  String get chatOperator => 'Chat with operator';

  @override
  String get chatPlaceholder => 'Chat will open here in the full app.';

  @override
  String get chatSubtitle => 'Encrypted session';

  @override
  String get chatMessageHint => 'Message…';

  @override
  String get chatWelcome =>
      'Monitoring center online. Briefly describe what’s happening.';

  @override
  String get chatDemoReply => 'Message received. Stay on the line if you can.';

  @override
  String get statusConnection => 'Connection';

  @override
  String get statusGps => 'GPS';

  @override
  String statusBattery(int percent) {
    return 'Battery: $percent%';
  }

  @override
  String get statusUnknown => '—';
}
