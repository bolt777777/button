// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Телохранитель';

  @override
  String get homeTitle => 'Телохранитель';

  @override
  String get sosActivate => 'Активировать тревогу';

  @override
  String get sosCancel => 'Отмена';

  @override
  String sosCountdownSemantics(int seconds) {
    return 'Отмена тревоги, осталось $seconds секунд';
  }

  @override
  String get sosSent => 'Сигнал тревоги передан';

  @override
  String get sosDemoMode => 'Демо: тревога сохранена локально (без сервера)';

  @override
  String get sosError => 'Не удалось отправить SOS';

  @override
  String get callCsm => 'Позвонить в ЦСМ';

  @override
  String get chatOperator => 'Чат с оператором';

  @override
  String get chatPlaceholder => 'Здесь будет чат в полной версии приложения.';

  @override
  String get statusConnection => 'Связь';

  @override
  String get statusGps => 'GPS';

  @override
  String statusBattery(int percent) {
    return 'Аккумулятор: $percent%';
  }

  @override
  String get statusUnknown => '—';
}
