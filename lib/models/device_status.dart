class DeviceStatus {
  final String deviceId;
  final bool status;
  final double? temperature;
  final double? battery;
  final int? count;
  final DateTime createdAt;

  DeviceStatus({
    required this.deviceId,
    required this.status,
    this.temperature,
    this.battery,
    this.count,
    required this.createdAt,
  });

  factory DeviceStatus.fromJson(Map<String, dynamic> json) {
    return DeviceStatus(
      deviceId: json['device_id'] ?? '',
      status: json['status'] ?? false,
      temperature: json['temperature']?.toDouble(),
      battery: json['battery']?.toDouble(),
      count: json['count']?.toInt(),
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'device_id': deviceId,
      'status': status,
      'temperature': temperature,
      'battery': battery,
      'count': count,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Helper getters
  String get statusText => status ? 'Open' : 'Closed';
  String get temperatureText =>
      temperature != null ? '${temperature!.toStringAsFixed(1)}°C' : 'N/A';
  String get batteryText =>
      battery != null ? '${battery!.toStringAsFixed(2)}V' : 'N/A';

  double get batteryPercentage {
    if (battery == null) return 0.0;
    final percentage = ((battery! - 2.5) / (3.3 - 2.5)) * 100;
    return percentage.clamp(0.0, 100.0);
  }

  String get batteryStatus {
    if (battery == null) return 'Unknown';
    if (battery! < 2.5) return 'Critical';
    if (battery! < 2.9) return 'Low';
    return 'Good';
  }
}
