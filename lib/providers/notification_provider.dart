import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/pusher_service.dart';

class NotificationProvider with ChangeNotifier {
  final ApiService apiService;
  final PusherService pusherService;
  List<dynamic> _notifications = [];
  bool _hasMore = true;
  int _currentPage = 1;
  bool _isRealtimeInitialized = false;

  NotificationProvider(this.apiService, this.pusherService);

  List<dynamic> get notifications => _notifications;
  bool get hasMore => _hasMore;
  bool get isRealtimeConnected => pusherService.isConnected;

  // Get count of unread notifications
  int get unreadCount => _notifications.where((n) => n['read'] == false).length;

  // Initialize real-time notifications
  Future<void> initializeRealtimeNotifications() async {
    if (_isRealtimeInitialized) return;

    try {
      // Subscribe to the sensor notifications channel
      await pusherService.subscribeToChannel('sensor-notifications');

      // Bind to the SensorAlert event
      pusherService.bindEvent('SensorAlert', _handleNewNotification);

      _isRealtimeInitialized = true;
      print("✅ Real-time notifications initialized");
    } catch (e) {
      print("❌ Failed to initialize real-time notifications: $e");
    }
  }

  // Handle incoming real-time notifications
  void _handleNewNotification(dynamic eventData) {
    try {
      print("📨 New notification received: $eventData");

      // Extract the alert data from the event
      dynamic alertData = eventData;
      if (eventData is Map && eventData.containsKey('alert')) {
        alertData = eventData['alert'];
      }

      // Create a notification object that matches your expected format
      final notification = _formatNotificationFromAlert(alertData);

      // Add to the beginning of the list (most recent first)
      _notifications.insert(0, notification);

      // Limit the list to prevent memory issues (optional)
      if (_notifications.length > 100) {
        _notifications = _notifications.take(100).toList();
      }

      notifyListeners();
      print("✅ Notification added to list");
    } catch (e) {
      print("❌ Error handling new notification: $e");
    }
  }

  // Format alert data to match notification structure
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
        'read': false, // Mark new notifications as unread
        'translation_key': alertData['translation_key'],
        'translation_params': alertData['translation_params'],
        // Add any other fields from your alert data
        ...alertData,
      };
    }

    // Fallback for non-map data
    return {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'message': alertData.toString(),
      'type': 'info',
      'created_at': DateTime.now().toIso8601String(),
      'timestamp': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      'read': false, // Mark new notifications as unread
    };
  }

  // Mark all notifications as read (call this when notification screen is opened)
  void markAllAsRead() {
    for (var notification in _notifications) {
      notification['read'] = true;
    }
    notifyListeners();
  }

  // Reset pagination and clear old notifications
  void resetPagination() {
    _notifications.clear();
    _currentPage = 1;
    _hasMore = true;
    notifyListeners();
  }

  // Replace the loadNotifications method in your NotificationProvider with this:

  Future<void> loadNotifications() async {
    try {
      print('📡 Loading notifications - Page: $_currentPage');

      final response = await apiService.getNotifications(
        page: _currentPage,
        limit: 20,
      );

      final newNotifications = response['notifications'] as List<dynamic>;
      final hasMoreFromApi = response['hasMore'] as bool;

      print('📦 Received ${newNotifications.length} notifications from API');

      // Add read status to existing notifications (they're considered read)
      final processedNotifications =
          newNotifications.map((notification) {
            if (notification is Map<String, dynamic>) {
              notification['read'] = true; // Existing notifications are read
            }
            return notification;
          }).toList();

      _notifications.addAll(processedNotifications);
      _hasMore = hasMoreFromApi;
      _currentPage++;

      notifyListeners();

      print(
        '✅ Total notifications now: ${_notifications.length}, hasMore: $_hasMore',
      );
    } catch (e) {
      print('❌ Error loading notifications: $e');
      rethrow;
    }
  }

  // Clean up when provider is disposed
  @override
  void dispose() {
    if (_isRealtimeInitialized) {
      pusherService.unbindEvent('SensorAlert');
    }
    super.dispose();
  }

  // Force refresh notifications (useful for pull-to-refresh)
  Future<void> refreshNotifications() async {
    resetPagination();
    await loadNotifications();
  }

  // Get notification count (useful for badges)
  int get notificationCount => _notifications.length;

  // Check if there are unread notifications (if you implement read status later)
  bool get hasUnreadNotifications => _notifications.isNotEmpty;
}
