// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Smart Sensor Dashboard';

  @override
  String get home => 'Home';

  @override
  String get notifications => 'Notifications';

  @override
  String get deviceDashboard => 'Device Dashboard';

  @override
  String get settings => 'Settings';

  @override
  String get deviceId => 'Device ID';

  @override
  String get status => 'Status';

  @override
  String get temperature => 'Temperature';

  @override
  String get battery => 'Battery';

  @override
  String get count => 'Count';

  @override
  String get noNotifications => 'No Notifications';

  @override
  String get opened => 'Opened';

  @override
  String get closed => 'Closed';

  @override
  String get noData => 'No Data';

  @override
  String get daily => 'Daily';

  @override
  String get weekly => 'Weekly';

  @override
  String get monthly => 'Monthly';

  @override
  String get tempAndBattery => 'Temperature & Battery Levels';

  @override
  String get door_opened => 'Door opened 🚪';

  @override
  String get door_closed => 'Door closed ✅';

  @override
  String temp_too_high(Object temperature) {
    return 'Temperature is too high: $temperature°C 🔥';
  }

  @override
  String temp_too_low(Object temperature) {
    return 'Temperature is too low: $temperature°C ❄️';
  }

  @override
  String get connection_lost => 'Lost connection to sensor ❌';

  @override
  String battery_critical(Object battery) {
    return 'Battery level critical: ${battery}V 🔋';
  }

  @override
  String battery_low(Object battery) {
    return 'Battery level low: ${battery}V ⚠️';
  }

  @override
  String door_open_too_long(Object minutes) {
    return 'Door has been open for more than $minutes minute(s) ⚠️';
  }

  @override
  String get errorLoadingData => 'Error Loading Data';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get refresh => 'Refresh';

  @override
  String get loadMore => 'Load More';

  @override
  String get firstDevice => 'First Device';

  @override
  String get secondDevice => 'Second Device';

  @override
  String get thirdDevice => 'Third Device';

  @override
  String get labDoor => 'IoT Lab Door';

  @override
  String get labWindow => 'IoT Lab Window';

  @override
  String get department => 'Department Locker';

  @override
  String get retry => 'Retry';

  @override
  String get deviceStats => 'Device Statistics';

  @override
  String get sensorNotRegistered => 'Sensor Not Registered';

  @override
  String get notAvailable => 'Not Available';

  @override
  String get temperatureShort => 'Temp';

  @override
  String get apiError => 'API Error';

  @override
  String get retryApiCall => 'Retry API Call';

  @override
  String get noDataAvailable => 'No data available for selected time range';

  @override
  String get noNotificationsAvailable => 'No notifications available';

  @override
  String get noMoreNotifications => 'No more notifications';

  @override
  String get eventCount => 'Event Count';

  @override
  String get temperatureBatteryLevels => 'Temperature & Battery Levels';

  @override
  String get temperatureC => 'Temperature (°C)';

  @override
  String get batteryPercent => 'Battery (%)';

  @override
  String get allTypes => 'All types';

  @override
  String get success => 'Success';

  @override
  String get info => 'Info';

  @override
  String get danger => 'Danger';

  @override
  String get warning => 'Warning';

  @override
  String get justNow => 'Just now';

  @override
  String minutesAgo(int minutes) {
    return '${minutes}m ago';
  }

  @override
  String hoursAgo(int hours) {
    return '${hours}h ago';
  }

  @override
  String get unknownDate => 'Unknown date';

  @override
  String get invalidDate => 'Invalid date';

  @override
  String get device => 'Device';

  @override
  String get unregistered => 'Unregistered';
}
