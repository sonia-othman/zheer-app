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

import 'dart:io';

import 'package:zheer/widgets/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Allow HTTP for development
  HttpOverrides.global = MyHttpOverrides();

  // App config
  final appConfig = AppConfig(
    apiBaseUrl: 'http://159.89.22.229', // ✅ Replace with your server IP/domain
    pusherKey: '10f9622a83d72895fe18',
    pusherCluster: 'eu',
  );

  final apiService = ApiService(appConfig);
  final pusherService = PusherService(appConfig);

  runApp(
    MultiProvider(
      providers: [
        // First provide the PusherService
        Provider<PusherService>.value(value: pusherService),

        // Then provide other services that don't depend on context
        ChangeNotifierProvider(create: (_) => LanguageProvider(apiService)),

        // Updated NotificationProvider with PusherService
        ChangeNotifierProvider(
          create:
              (_) =>
                  NotificationProvider(apiService, pusherService)
                    ..initializeRealtimeNotifications(),
        ),

        // Now provide services that depend on PusherService
        ChangeNotifierProvider(
          create:
              (context) => HomeSensorProvider(
                apiService,
                pusherService, // Use the instance directly instead of from context
              ),
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

// Allows insecure connections for development (DON'T use in production!)
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
    final languageProvider = Provider.of<LanguageProvider>(context);

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
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MainScreen(),
    );
  }
}
