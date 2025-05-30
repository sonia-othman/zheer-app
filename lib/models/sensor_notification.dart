class SensorNotification {
  final int id;
  final String deviceId;
  final String type; // info, success, warning, danger
  final String message;
  final String? translationKey;
  final Map<String, dynamic>? translationParams;
  final DateTime timestamp;
  final DateTime createdAt;
  final DateTime? readAt;

  SensorNotification({
    required this.id,
    required this.deviceId,
    required this.type,
    required this.message,
    this.translationKey,
    this.translationParams,
    required this.timestamp,
    required this.createdAt,
    this.readAt,
  });

  factory SensorNotification.fromJson(Map<String, dynamic> json) {
    return SensorNotification(
      id: json['id'] ?? 0,
      deviceId: json['device_id'] ?? '',
      type: json['type'] ?? 'info',
      message: json['message'] ?? '',
      translationKey: json['translation_key'],
      translationParams: json['translation_params'],
      timestamp: DateTime.parse(
        json['timestamp'] ?? DateTime.now().toIso8601String(),
      ),
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      readAt: json['read_at'] != null ? DateTime.parse(json['read_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'device_id': deviceId,
      'type': type,
      'message': message,
      'translation_key': translationKey,
      'translation_params': translationParams,
      'timestamp': timestamp.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'read_at': readAt?.toIso8601String(),
    };
  }

  // Helper getters
  bool get isRead => readAt != null;

  String get typeDisplayName {
    switch (type) {
      case 'info':
        return 'Info';
      case 'success':
        return 'Success';
      case 'warning':
        return 'Warning';
      case 'danger':
        return 'Alert';
      default:
        return 'Notification';
    }
  }

  // Time ago helper
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
