import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_ku.dart';

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
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('ku')
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'Smart Sensor Dashboard'**
  String get appTitle;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @deviceDashboard.
  ///
  /// In en, this message translates to:
  /// **'Device Dashboard'**
  String get deviceDashboard;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @deviceId.
  ///
  /// In en, this message translates to:
  /// **'Device ID'**
  String get deviceId;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @temperature.
  ///
  /// In en, this message translates to:
  /// **'Temperature'**
  String get temperature;

  /// No description provided for @battery.
  ///
  /// In en, this message translates to:
  /// **'Battery'**
  String get battery;

  /// No description provided for @count.
  ///
  /// In en, this message translates to:
  /// **'Count'**
  String get count;

  /// No description provided for @noNotifications.
  ///
  /// In en, this message translates to:
  /// **'No Notifications'**
  String get noNotifications;

  /// No description provided for @opened.
  ///
  /// In en, this message translates to:
  /// **'Opened'**
  String get opened;

  /// No description provided for @closed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get closed;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No Data'**
  String get noData;

  /// No description provided for @daily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get daily;

  /// No description provided for @weekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get weekly;

  /// No description provided for @monthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthly;

  /// No description provided for @tempAndBattery.
  ///
  /// In en, this message translates to:
  /// **'Temperature & Battery Levels'**
  String get tempAndBattery;

  /// No description provided for @door_opened.
  ///
  /// In en, this message translates to:
  /// **'Door opened 🚪'**
  String get door_opened;

  /// No description provided for @door_closed.
  ///
  /// In en, this message translates to:
  /// **'Door closed ✅'**
  String get door_closed;

  /// No description provided for @temp_too_high.
  ///
  /// In en, this message translates to:
  /// **'Temperature is too high: {temperature}°C 🔥'**
  String temp_too_high(Object temperature);

  /// No description provided for @temp_too_low.
  ///
  /// In en, this message translates to:
  /// **'Temperature is too low: {temperature}°C ❄️'**
  String temp_too_low(Object temperature);

  /// No description provided for @connection_lost.
  ///
  /// In en, this message translates to:
  /// **'Lost connection to sensor ❌'**
  String get connection_lost;

  /// No description provided for @battery_critical.
  ///
  /// In en, this message translates to:
  /// **'Battery level critical: {battery}V 🔋'**
  String battery_critical(Object battery);

  /// No description provided for @battery_low.
  ///
  /// In en, this message translates to:
  /// **'Battery level low: {battery}V ⚠️'**
  String battery_low(Object battery);

  /// No description provided for @door_open_too_long.
  ///
  /// In en, this message translates to:
  /// **'Door has been open for more than {minutes} minute(s) ⚠️'**
  String door_open_too_long(Object minutes);

  /// No description provided for @errorLoadingData.
  ///
  /// In en, this message translates to:
  /// **'Error Loading Data'**
  String get errorLoadingData;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @loadMore.
  ///
  /// In en, this message translates to:
  /// **'Load More'**
  String get loadMore;

  /// No description provided for @firstDevice.
  ///
  /// In en, this message translates to:
  /// **'First Device'**
  String get firstDevice;

  /// No description provided for @secondDevice.
  ///
  /// In en, this message translates to:
  /// **'Second Device'**
  String get secondDevice;

  /// No description provided for @thirdDevice.
  ///
  /// In en, this message translates to:
  /// **'Third Device'**
  String get thirdDevice;

  /// No description provided for @labDoor.
  ///
  /// In en, this message translates to:
  /// **'IoT Lab Door'**
  String get labDoor;

  /// No description provided for @labWindow.
  ///
  /// In en, this message translates to:
  /// **'IoT Lab Window'**
  String get labWindow;

  /// No description provided for @department.
  ///
  /// In en, this message translates to:
  /// **'Department Locker'**
  String get department;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @deviceStats.
  ///
  /// In en, this message translates to:
  /// **'Device Statistics'**
  String get deviceStats;

  /// No description provided for @sensorNotRegistered.
  ///
  /// In en, this message translates to:
  /// **'Sensor Not Registered'**
  String get sensorNotRegistered;

  /// No description provided for @notAvailable.
  ///
  /// In en, this message translates to:
  /// **'Not Available'**
  String get notAvailable;

  /// No description provided for @temperatureShort.
  ///
  /// In en, this message translates to:
  /// **'Temp'**
  String get temperatureShort;

  /// No description provided for @apiError.
  ///
  /// In en, this message translates to:
  /// **'API Error'**
  String get apiError;

  /// No description provided for @retryApiCall.
  ///
  /// In en, this message translates to:
  /// **'Retry API Call'**
  String get retryApiCall;

  /// No description provided for @noDataAvailable.
  ///
  /// In en, this message translates to:
  /// **'No data available for selected time range'**
  String get noDataAvailable;

  /// No description provided for @noNotificationsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No notifications available'**
  String get noNotificationsAvailable;

  /// No description provided for @noMoreNotifications.
  ///
  /// In en, this message translates to:
  /// **'No more notifications'**
  String get noMoreNotifications;

  /// No description provided for @eventCount.
  ///
  /// In en, this message translates to:
  /// **'Event Count'**
  String get eventCount;

  /// No description provided for @temperatureBatteryLevels.
  ///
  /// In en, this message translates to:
  /// **'Temperature & Battery Levels'**
  String get temperatureBatteryLevels;

  /// No description provided for @temperatureC.
  ///
  /// In en, this message translates to:
  /// **'Temperature (°C)'**
  String get temperatureC;

  /// No description provided for @batteryPercent.
  ///
  /// In en, this message translates to:
  /// **'Battery (%)'**
  String get batteryPercent;

  /// No description provided for @allTypes.
  ///
  /// In en, this message translates to:
  /// **'All types'**
  String get allTypes;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @info.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get info;

  /// No description provided for @danger.
  ///
  /// In en, this message translates to:
  /// **'Danger'**
  String get danger;

  /// No description provided for @warning.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get warning;

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get justNow;

  /// No description provided for @minutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{minutes}m ago'**
  String minutesAgo(int minutes);

  /// No description provided for @hoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{hours}h ago'**
  String hoursAgo(int hours);

  /// No description provided for @unknownDate.
  ///
  /// In en, this message translates to:
  /// **'Unknown date'**
  String get unknownDate;

  /// No description provided for @invalidDate.
  ///
  /// In en, this message translates to:
  /// **'Invalid date'**
  String get invalidDate;

  /// No description provided for @device.
  ///
  /// In en, this message translates to:
  /// **'Device'**
  String get device;

  /// No description provided for @unregistered.
  ///
  /// In en, this message translates to:
  /// **'Unregistered'**
  String get unregistered;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['ar', 'en', 'ku'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar': return AppLocalizationsAr();
    case 'en': return AppLocalizationsEn();
    case 'ku': return AppLocalizationsKu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
