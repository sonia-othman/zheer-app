class SensorNotification {
  final int id;
  final String deviceId;
  final String type;
  final String message;
  final String? translationKey;
  final Map<String, dynamic>? translationParams;
  final DateTime timestamp;
  final DateTime createdAt;

  SensorNotification({
    required this.id,
    required this.deviceId,
    required this.type,
    required this.message,
    this.translationKey,
    this.translationParams,
    required this.timestamp,
    required this.createdAt,
  });

  factory SensorNotification.fromJson(Map<String, dynamic> json) {
    DateTime parseDateTime(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is int) {
        return DateTime.fromMillisecondsSinceEpoch(value * 1000);
      }
      if (value is String) {
        return DateTime.parse(value);
      }
      throw Exception('Invalid date format');
    }

    return SensorNotification(
      id: json['id'] ?? 0,
      deviceId: json['device_id'] ?? '',
      type: json['type'] ?? 'info',
      message: json['message'] ?? '',
      translationKey: json['translation_key'],
      translationParams:
          json['translation_params'] != null
              ? Map<String, dynamic>.from(json['translation_params'])
              : null,
      timestamp: parseDateTime(json['timestamp']),
      createdAt: parseDateTime(json['created_at']),
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
    };
  }

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
