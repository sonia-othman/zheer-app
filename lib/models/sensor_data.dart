class SensorData {
  final String deviceId;
  final bool status;
  final double temperature;
  final double battery;
  final int count;
  final DateTime createdAt;

  SensorData({
    required this.deviceId,
    required this.status,
    required this.temperature,
    required this.battery,
    required this.count,
    required this.createdAt,
  });
  factory SensorData.fromJson(Map<String, dynamic> json) {
    return SensorData(
      deviceId: json['device_id'],
      status: json['status'] == true, // ← FIXED: force bool
      temperature: (json['temperature'] as num).toDouble(),
      battery: (json['battery'] as num).toDouble(),
      count: json['count'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
