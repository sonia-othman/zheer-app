import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:zheer/config/app_config.dart';
import 'package:zheer/services/api_service.dart';
import 'package:zheer/services/pusher_service.dart';
import 'package:zheer/providers/sensor_provider.dart';
import 'package:zheer/providers/notification_provider.dart';
import 'package:zheer/providers/language_provider.dart';
import 'package:zheer/providers/home_sensor_provider.dart';
import 'package:zheer/l10n/generated/app_localizations.dart';
import 'package:zheer/widgets/main_screen.dart';
import 'package:zheer/l10n/material_localizations_ku.dart';

import 'dart:io';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  HttpOverrides.global = MyHttpOverrides();

  final appConfig = AppConfig(
    apiBaseUrl: 'http://159.89.22.229',
    pusherKey: '10f9622a83d72895fe18',
    pusherCluster: 'eu',
  );

  final apiService = ApiService(appConfig);
  final pusherService = PusherService(appConfig);

  runApp(
    MultiProvider(
      providers: [
        Provider<PusherService>.value(value: pusherService),
        ChangeNotifierProvider(create: (_) => LanguageProvider(apiService)),
        ChangeNotifierProvider(
          create:
              (_) =>
                  NotificationProvider(apiService, pusherService)
                    ..initializeRealtimeNotifications(),
        ),
        ChangeNotifierProvider(
          create: (context) => HomeSensorProvider(apiService, pusherService),
        ),
        ChangeNotifierProvider(
          create:
              (_) =>
                  SensorProvider(apiService, pusherService)
                    ..initializeRealtimeUpdates(),
        ),
      ],
      child: MyApp(appConfig: appConfig),
    ),
  );
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

class MyApp extends StatelessWidget {
  final AppConfig appConfig;

  const MyApp({Key? key, required this.appConfig}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Smart Sensor Dashboard',
          locale: languageProvider.currentLocale,
          supportedLocales: const [
            Locale('en', ''),
            Locale('ar', ''),
            Locale('ku', ''),
          ],
          localizationsDelegates: const [
            AppLocalizations.delegate,
            KurdishMaterialLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          localeResolutionCallback: (locale, supportedLocales) {
            if (locale != null) {
              for (final supportedLocale in supportedLocales) {
                if (supportedLocale.languageCode == locale.languageCode) {
                  return supportedLocale;
                }
              }
            }
            return supportedLocales.first;
          },

          builder: (context, child) {
            final locale = Localizations.localeOf(context);
            final isRTL =
                locale.languageCode == 'ar' || locale.languageCode == 'ku';

            return Directionality(
              textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
              child: child!,
            );
          },

          theme: ThemeData(
            primarySwatch: Colors.blue,
            fontFamily: 'NotoSansArabic',
          ),
          home: const MainScreen(),
        );
      },
    );
  }
}
