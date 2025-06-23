import 'package:intl/intl.dart';

class SensorData {
  final String deviceId;
  final bool status;
  final double temperature;
  final double battery;
  final int count;
  final DateTime createdAt;
  final String? dateLabel;

  SensorData({
    required this.deviceId,
    required this.status,
    required this.temperature,
    required this.battery,
    required this.count,
    required this.createdAt,
    this.dateLabel,
  });

  factory SensorData.fromJson(Map<String, dynamic> json) {
    return SensorData(
      deviceId: _parseString(json['device_id']),
      status: _parseBool(json['status']),
      temperature: _parseDouble(json['temperature']),
      battery: _parseDouble(json['battery']),
      count: _parseInt(json['count']),
      createdAt: _parseDateTime(json['created_at']),
      dateLabel: _parseStringNullable(json['date_label']),
    );
  }

  static String _parseString(dynamic value) {
    if (value == null) return '';
    return value.toString();
  }

  static String? _parseStringNullable(dynamic value) {
    if (value == null) return null;
    return value.toString();
  }

  static bool _parseBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is String) {
      return value.toLowerCase() == 'true' || value == '1';
    }
    if (value is int) return value != 0;
    return false;
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value.isFinite ? value : 0.0;
    if (value is int) return value.toDouble();
    if (value is String) {
      final parsed = double.tryParse(value);
      return (parsed != null && parsed.isFinite) ? parsed : 0.0;
    }
    return 0.0;
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return 0;
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    if (value is String && value.isNotEmpty) {
      final parsed = DateTime.tryParse(value);
      return parsed ?? DateTime.now();
    }
    return DateTime.now();
  }

  bool isValid() {
    return deviceId.isNotEmpty &&
        temperature.isFinite &&
        battery.isFinite &&
        count >= 0;
  }

  SensorData copyWith({
    String? deviceId,
    bool? status,
    double? temperature,
    double? battery,
    int? count,
    DateTime? createdAt,
    String? dateLabel,
  }) {
    return SensorData(
      deviceId: deviceId ?? this.deviceId,
      status: status ?? this.status,
      temperature: temperature ?? this.temperature,
      battery: battery ?? this.battery,
      count: count ?? this.count,
      createdAt: createdAt ?? this.createdAt,
      dateLabel: dateLabel ?? this.dateLabel,
    );
  }

  factory SensorData.fromGrouped(Map<String, dynamic> json) {
    final createdAt = _parseDateTime(json['created_at']);
    return SensorData(
      deviceId: '',
      status: false,
      temperature: 0,
      battery: 0,
      count: _parseInt(json['count']),
      createdAt: createdAt,
      dateLabel: DateFormat('h:mm a').format(createdAt.toLocal()),
    );
  }

  @override
  String toString() {
    return 'SensorData(deviceId: $deviceId, status: $status, temperature: $temperature, battery: $battery, count: $count, createdAt: $createdAt, dateLabel: $dateLabel)';
  }
}
