import 'package:flutter/widgets.dart';

import 'app_localizations.dart';

/// Всегда возвращает строки: не зависит от того, успел ли delegate отдать [AppLocalizations.of].
AppLocalizations resolveAppLocalizations(BuildContext context) {
  final direct = AppLocalizations.of(context);
  if (direct != null) return direct;
  try {
    final locale = Localizations.localeOf(context);
    return lookupAppLocalizations(locale);
  } catch (_) {
    return lookupAppLocalizations(const Locale('en'));
  }
}
