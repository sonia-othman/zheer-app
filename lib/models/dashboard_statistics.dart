import 'package:zheer/models/device_status.dart';

class DashboardStatistics {
  final int devices;
  final int alerts;
  final List<DeviceStatus> devicesData;

  DashboardStatistics({
    required this.devices,
    required this.alerts,
    required this.devicesData,
  });

  factory DashboardStatistics.fromJson(Map<String, dynamic> json) {
    return DashboardStatistics(
      devices: json['devices'] ?? 0,
      alerts: json['alerts'] ?? 0,
      devicesData:
          (json['devicesData'] as List? ?? [])
              .map((item) => DeviceStatus.fromJson(item))
              .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'devices': devices,
      'alerts': alerts,
      'devicesData': devicesData.map((d) => d.toJson()).toList(),
    };
  }
}
