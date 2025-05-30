import 'package:flutter/material.dart';
import '../services/api_service.dart';

class NotificationProvider with ChangeNotifier {
  final ApiService apiService;
  List<dynamic> _notifications = [];
  bool _hasMore = true;
  int _currentPage = 1;

  NotificationProvider(this.apiService);

  List<dynamic> get notifications => _notifications;
  bool get hasMore => _hasMore;

  Future<void> loadNotifications() async {
    try {
      final newNotifications = await apiService.getNotifications(
        page: _currentPage,
      );
      _notifications.addAll(newNotifications);
      _hasMore = newNotifications.isNotEmpty;
      _currentPage++;
      notifyListeners();
    } catch (e) {
      print("Error loading notifications: $e");
      rethrow;
    }
  }

  Future<void> markAsRead(List<String> ids) async {
    try {
      await apiService.markNotificationsAsRead(ids);
      for (var id in ids) {
        final index = _notifications.indexWhere((n) => n['id'] == id);
        if (index != -1) {
          _notifications[index]['read'] = true;
        }
      }
      notifyListeners();
    } catch (e) {
      print("Error marking notifications as read: $e");
      rethrow;
    }
  }
}
