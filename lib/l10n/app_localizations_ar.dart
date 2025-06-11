// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'لوحة تحكم المستشعرات الذكية';

  @override
  String get home => 'الرئيسية';

  @override
  String get notifications => 'التنبيهات';

  @override
  String get deviceDashboard => 'لوحة تحكم الجهاز';

  @override
  String get settings => 'الإعدادات';

  @override
  String get deviceId => 'معرف الجهاز';

  @override
  String get status => 'الحالة';

  @override
  String get temperature => 'درجة الحرارة';

  @override
  String get battery => 'البطارية';

  @override
  String get count => 'العدد';

  @override
  String get noNotifications => 'لا توجد تنبيهات';

  @override
  String get opened => 'مفتوح';

  @override
  String get closed => 'مغلق';

  @override
  String get noData => 'لا توجد بيانات';

  @override
  String get daily => 'يومي';

  @override
  String get weekly => 'أسبوعي';

  @override
  String get monthly => 'شهري';

  @override
  String get tempAndBattery => 'مستويات درجة الحرارة والبطارية';

  @override
  String get door_opened => 'فتح الباب 🚪';

  @override
  String get door_closed => 'تم إغلاق الباب ✅';

  @override
  String temp_too_high(Object temperature) {
    return 'درجة الحرارة مرتفعة جدًا: $temperature°C 🔥';
  }

  @override
  String temp_too_low(Object temperature) {
    return 'درجة الحرارة منخفضة جدًا: $temperature°C ❄️';
  }

  @override
  String get connection_lost => 'فقد الاتصال بالمستشعر ❌';

  @override
  String battery_critical(Object battery) {
    return 'مستوى البطارية حرج: ${battery}V 🔋';
  }

  @override
  String battery_low(Object battery) {
    return 'مستوى البطارية منخفض: ${battery}V ⚠️';
  }

  @override
  String door_open_too_long(Object minutes) {
    return 'الباب مفتوح لأكثر من $minutes دقيقة ⚠️';
  }

  @override
  String get errorLoadingData => 'خطأ في تحميل البيانات';

  @override
  String get tryAgain => 'حاول مرة أخرى';

  @override
  String get refresh => 'تحديث';

  @override
  String get loadMore => 'تحميل المزيد';

  @override
  String get firstDevice => 'الجهاز الأول';

  @override
  String get secondDevice => 'الجهاز الثاني';

  @override
  String get thirdDevice => 'الجهاز الثالث';

  @override
  String get labDoor => 'باب مختبر إنترنت الأشياء';

  @override
  String get labWindow => 'نافذة مختبر إنترنت الأشياء';

  @override
  String get department => 'خزانة القسم';

  @override
  String get retry => 'Retry';

  @override
  String get deviceStats => 'Device Statistics';

  @override
  String get sensorNotRegistered => 'المستشعر غير مسجل';

  @override
  String get notAvailable => 'غير متوفر';

  @override
  String get temperatureShort => 'درجة';

  @override
  String get apiError => 'خطأ في واجهة برمجة التطبيقات';

  @override
  String get retryApiCall => 'إعادة محاولة استدعاء واجهة برمجة التطبيقات';

  @override
  String get noDataAvailable => 'لا توجد بيانات متاحة للفترة الزمنية المحددة';

  @override
  String get noNotificationsAvailable => 'لا توجد تنبيهات متاحة';

  @override
  String get noMoreNotifications => 'لا توجد تنبيهات أخرى';

  @override
  String get eventCount => 'عدد الأحداث';

  @override
  String get temperatureBatteryLevels => 'مستويات درجة الحرارة والبطارية';

  @override
  String get temperatureC => 'درجة الحرارة (°س)';

  @override
  String get batteryPercent => 'البطارية (%)';

  @override
  String get allTypes => 'جميع الأنواع';

  @override
  String get success => 'نجح';

  @override
  String get info => 'معلومات';

  @override
  String get danger => 'خطر';

  @override
  String get warning => 'تحذير';

  @override
  String get justNow => 'الآن';

  @override
  String minutesAgo(int minutes) {
    return 'منذ $minutes دقيقة';
  }

  @override
  String hoursAgo(int hours) {
    return 'منذ $hours ساعة';
  }

  @override
  String get unknownDate => 'تاريخ غير معروف';

  @override
  String get invalidDate => 'تاريخ غير صحيح';

  @override
  String get device => 'Device';

  @override
  String get unregistered => 'Unregistered';
}
