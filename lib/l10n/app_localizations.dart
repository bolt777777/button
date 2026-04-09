import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Bodyguard'**
  String get appTitle;

  /// No description provided for @homeTitle.
  ///
  /// In en, this message translates to:
  /// **'Bodyguard'**
  String get homeTitle;

  /// No description provided for @sosActivate.
  ///
  /// In en, this message translates to:
  /// **'Activate alarm'**
  String get sosActivate;

  /// No description provided for @sosCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get sosCancel;

  /// No description provided for @sosDoubleTapHint.
  ///
  /// In en, this message translates to:
  /// **'Double-tap the SOS button to cancel'**
  String get sosDoubleTapHint;

  /// No description provided for @sosCountdownSemantics.
  ///
  /// In en, this message translates to:
  /// **'Sending in {seconds} s — double-tap SOS to cancel'**
  String sosCountdownSemantics(int seconds);

  /// No description provided for @sosSent.
  ///
  /// In en, this message translates to:
  /// **'Alarm signal sent'**
  String get sosSent;

  /// No description provided for @sosDemoMode.
  ///
  /// In en, this message translates to:
  /// **'Demo: SOS recorded locally (no server)'**
  String get sosDemoMode;

  /// No description provided for @sosError.
  ///
  /// In en, this message translates to:
  /// **'Failed to send SOS'**
  String get sosError;

  /// No description provided for @callCsm.
  ///
  /// In en, this message translates to:
  /// **'Call monitoring center'**
  String get callCsm;

  /// No description provided for @chatOperator.
  ///
  /// In en, this message translates to:
  /// **'Chat with operator'**
  String get chatOperator;

  /// No description provided for @chatPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Chat will open here in the full app.'**
  String get chatPlaceholder;

  /// No description provided for @chatSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Encrypted session'**
  String get chatSubtitle;

  /// No description provided for @chatMessageHint.
  ///
  /// In en, this message translates to:
  /// **'Message…'**
  String get chatMessageHint;

  /// No description provided for @chatWelcome.
  ///
  /// In en, this message translates to:
  /// **'Monitoring center online. Briefly describe what’s happening.'**
  String get chatWelcome;

  /// No description provided for @chatDemoReply.
  ///
  /// In en, this message translates to:
  /// **'Message received. Stay on the line if you can.'**
  String get chatDemoReply;

  /// No description provided for @statusConnection.
  ///
  /// In en, this message translates to:
  /// **'Connection'**
  String get statusConnection;

  /// No description provided for @statusGps.
  ///
  /// In en, this message translates to:
  /// **'GPS'**
  String get statusGps;

  /// No description provided for @statusBattery.
  ///
  /// In en, this message translates to:
  /// **'Battery: {percent}%'**
  String statusBattery(int percent);

  /// No description provided for @statusUnknown.
  ///
  /// In en, this message translates to:
  /// **'—'**
  String get statusUnknown;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
