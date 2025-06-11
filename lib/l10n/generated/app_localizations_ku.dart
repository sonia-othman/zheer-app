// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Kurdish (`ku`).
class AppLocalizationsKu extends AppLocalizations {
  AppLocalizationsKu([String locale = 'ku']) : super(locale);

  @override
  String get appTitle => 'داشبۆردی سێنسەری زیرەک';

  @override
  String get home => 'سەرەکی';

  @override
  String get notifications => 'ئاگادارکردنەوەکان';

  @override
  String get deviceDashboard => 'داشبۆردی ئامێر';

  @override
  String get settings => 'ڕێکخستنەکان';

  @override
  String get deviceId => 'ناسنامەی ئامێر';

  @override
  String get status => 'دۆخ';

  @override
  String get temperature => 'پلەی گەرمی';

  @override
  String get battery => 'پاتری';

  @override
  String get count => 'ژمارە';

  @override
  String get noNotifications => 'هیچ ئاگادارکردنەوەیەک بەردەست نییە';

  @override
  String get opened => 'کراوەتەوە';

  @override
  String get closed => 'داخراوە';

  @override
  String get noData => 'هیچ داتایەک بەردەست نییە';

  @override
  String get daily => 'ڕۆژانە';

  @override
  String get weekly => 'هەفتانە';

  @override
  String get monthly => 'مانگانە';

  @override
  String get tempAndBattery => 'پلەی گەرمی و پاتری';

  @override
  String get door_opened => 'دەرگاکە کرایەوە 🚪';

  @override
  String get door_closed => 'دەرگاکە داخرا ✅';

  @override
  String temp_too_high(Object temperature) {
    return 'بەرزترین پلەی گەرمی $temperature°C 🔥';
  }

  @override
  String temp_too_low(Object temperature) {
    return 'نزمترین پلەی گەرمی $temperature°C ❄️';
  }

  @override
  String get connection_lost => 'پەیوەندیو بە سێنسەرەکەوە نەما ❌';

  @override
  String battery_critical(Object battery) {
    return 'نزمترین ئاستی پاتری: ${battery}V 🔋';
  }

  @override
  String battery_low(Object battery) {
    return 'ئاستی پاتریەکە نزمە: ${battery}V ⚠️';
  }

  @override
  String door_open_too_long(Object minutes) {
    return 'دەرگا بۆ ماوەی زیاتر لە $minutes خولەکە کراوەیە  ⚠️';
  }

  @override
  String get errorLoadingData => 'هەڵە لە بارکردنی داتا';

  @override
  String get tryAgain => 'دووبارە هەوڵ بدەوە';

  @override
  String get refresh => 'نوێکردنەوە';

  @override
  String get loadMore => 'زیاتر  ببینە';

  @override
  String get firstDevice => 'ئامێری یەکەم';

  @override
  String get secondDevice => 'ئامێری دووەم';

  @override
  String get thirdDevice => 'ئامێری سێیەم';

  @override
  String get labDoor => 'دەرگای تاقیگەی IoT';

  @override
  String get labWindow => 'پەنجەرەی تاقیگەی IoT';

  @override
  String get department => 'دۆڵابی بەش';

  @override
  String get retry => 'دووبارە هەوڵ بدەوە';

  @override
  String get deviceStats => 'ئاماری ئامێر';

  @override
  String get sensorNotRegistered => 'هەستەوەر تۆمار نەکراوە';

  @override
  String get notAvailable => 'بەردەست نییە';

  @override
  String get temperatureShort => 'پلە';

  @override
  String get apiError => 'هەڵەی API';

  @override
  String get retryApiCall => 'دووبارە API بانگ بکە';

  @override
  String get noDataAvailable => 'هیچ داتایەک بەردەست نییە بۆ ئەو کاتەی دیاریکراوە';

  @override
  String get noNotificationsAvailable => 'هیچ ئاگادارکردنەوەیەک بەردەست نییە';

  @override
  String get noMoreNotifications => 'هیچ ئاگادارکردنەوەی تری نییە';

  @override
  String get eventCount => 'ژمارەی ڕووداو';

  @override
  String get temperatureBatteryLevels => 'ئاستی پلەی گەرمی و پاتری';

  @override
  String get temperatureC => 'پلەی گەرمی (°س)';

  @override
  String get batteryPercent => 'پاتری (%)';

  @override
  String get allTypes => 'هەموو جۆرەکان';

  @override
  String get success => 'سەرکەوتوو';

  @override
  String get info => 'زانیاری';

  @override
  String get danger => 'مەترسی';

  @override
  String get warning => 'ئاگاداری';

  @override
  String get justNow => 'ئێستا';

  @override
  String minutesAgo(int minutes) {
    return '$minutes خولەک پێش ئێستا';
  }

  @override
  String hoursAgo(int hours) {
    return '$hours کاتژمێر پێش ئێستا';
  }

  @override
  String get unknownDate => 'بەرواری نەزانراو';

  @override
  String get invalidDate => 'بەرواری هەڵە';

  @override
  String get device => 'ئامێر';

  @override
  String get unregistered => 'تۆمار نەکراوە';
}
