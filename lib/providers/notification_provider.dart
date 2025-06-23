import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/pusher_service.dart';

class NotificationProvider with ChangeNotifier {
  final ApiService apiService;
  final PusherService pusherService;
  List<dynamic> _notifications = [];
  bool _hasMore = true;
  bool _isLoading = false;
  int _currentPage = 1;
  bool _isRealtimeInitialized = false;

  NotificationProvider(this.apiService, this.pusherService);

  List<dynamic> get notifications => _notifications;
  bool get hasMore => _hasMore;
  bool get isLoading => _isLoading;
  bool get isRealtimeConnected => pusherService.isConnected;

  int get unreadCount => _notifications.where((n) => n['read'] == false).length;

  Future<void> initializeRealtimeNotifications() async {
    if (_isRealtimeInitialized) return;

    try {
      await pusherService.subscribeToChannel('sensor-notifications');

      pusherService.bindEvent('SensorAlert', _handleNewNotification);

      _isRealtimeInitialized = true;
      print("✅ Real-time notifications initialized");
    } catch (e) {
      print("❌ Failed to initialize real-time notifications: $e");
    }
  }

  void _handleNewNotification(dynamic eventData) {
    try {
      print("📨 New notification received: $eventData");

      dynamic alertData = eventData;
      if (eventData is Map && eventData.containsKey('alert')) {
        alertData = eventData['alert'];
      }

      final notification = _formatNotificationFromAlert(alertData);

      _notifications.insert(0, notification);

      if (_notifications.length > 100) {
        _notifications = _notifications.take(100).toList();
      }

      notifyListeners();
      print("✅ Notification added to list");
    } catch (e) {
      print("❌ Error handling new notification: $e");
    }
  }

  Map<String, dynamic> _formatNotificationFromAlert(dynamic alertData) {
    if (alertData is Map) {
      return {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'message':
            alertData['message'] ??
            alertData['body'] ??
            'New sensor alert received',
        'type': alertData['type'] ?? 'info',
        'created_at': DateTime.now().toIso8601String(),
        'timestamp': DateTime.now().millisecondsSinceEpoch ~/ 1000,
        'device_id': alertData['device_id'],
        'sensor_value': alertData['sensor_value'],
        'threshold': alertData['threshold'],
        'read': false,
        'translation_key': alertData['translation_key'],
        'translation_params': alertData['translation_params'],
        ...alertData,
      };
    }

    return {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'message': alertData.toString(),
      'type': 'info',
      'created_at': DateTime.now().toIso8601String(),
      'timestamp': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      'read': false,
    };
  }

  void markAllAsRead() {
    for (var notification in _notifications) {
      notification['read'] = true;
    }
    notifyListeners();
  }

  void resetPagination() {
    _notifications.clear();
    _currentPage = 1;
    _hasMore = true;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadNotifications() async {
    if (_isLoading) {
      print('🚫 Already loading notifications, skipping...');
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      print('📡 Loading notifications - Page: $_currentPage');

      final response = await apiService.getNotifications(
        page: _currentPage,
        limit: 20,
      );

      final newNotifications = response['notifications'] as List<dynamic>;
      final hasMoreFromApi = response['hasMore'] as bool;

      print('📦 Received ${newNotifications.length} notifications from API');

      final processedNotifications =
          newNotifications.map((notification) {
            if (notification is Map<String, dynamic>) {
              notification['read'] = true;
            }
            return notification;
          }).toList();

      _notifications.addAll(processedNotifications);
      _hasMore = hasMoreFromApi;
      _currentPage++;

      print(
        '✅ Total notifications now: ${_notifications.length}, hasMore: $_hasMore',
      );
    } catch (e) {
      print('❌ Error loading notifications: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    if (_isRealtimeInitialized) {
      pusherService.unbindEvent('SensorAlert');
    }
    super.dispose();
  }

  Future<void> refreshNotifications() async {
    resetPagination();
    await loadNotifications();
  }

  int get notificationCount => _notifications.length;

  bool get hasUnreadNotifications => unreadCount > 0;
}
