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
  String get sosDoubleTapHint => 'Двойное нажатие по SOS — отмена';

  @override
  String sosCountdownSemantics(int seconds) {
    return 'Отправка через $seconds с — двойное нажатие SOS для отмены';
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
  String get chatSubtitle => 'Защищённый канал';

  @override
  String get chatMessageHint => 'Сообщение…';

  @override
  String get chatWelcome => 'Центр на связи. Кратко опишите ситуацию.';

  @override
  String get chatDemoReply => 'Сообщение получено. Оставайтесь на связи.';

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
