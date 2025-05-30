import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zheer/widgets/custom_app_bar.dart';
import '../providers/notification_provider.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  late NotificationProvider _provider;
  bool _isLoadingMore = false;
  String _filterType = '';

  @override
  void initState() {
    super.initState();
    _provider = Provider.of<NotificationProvider>(context, listen: false);
    _loadFirstPage();
  }

  Future<void> _loadFirstPage() async {
    _provider.resetPagination();
    await _provider.loadNotifications();
  }

  Future<void> _loadMore() async {
    if (_provider.hasMore && !_isLoadingMore) {
      setState(() => _isLoadingMore = true);
      await _provider.loadNotifications();
      setState(() => _isLoadingMore = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Notifications', showBackButton: false),
      body: Consumer<NotificationProvider>(
        builder: (context, provider, child) {
          final filteredNotifications =
              _filterType.isEmpty
                  ? provider.notifications
                  : provider.notifications
                      .where((n) => n['type']?.toString() == _filterType)
                      .toList();

          if (provider.notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  provider.hasMore
                      ? const CircularProgressIndicator()
                      : Column(
                        children: [
                          Icon(
                            Icons.notifications_off_outlined,
                            size: 64,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No notifications available',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ],
                      ),
                  const SizedBox(height: 20),
                  if (!provider.hasMore)
                    TextButton(
                      onPressed: _loadFirstPage,
                      child: const Text('Refresh'),
                    ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.refreshNotifications(),
            child: Column(
              children: [
                // Filter dropdown - matches Vue design
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: DropdownButton<String>(
                          value: _filterType,
                          underline: const SizedBox(),
                          items: [
                            DropdownMenuItem(
                              value: '',
                              child: Text('All types'),
                            ),
                            DropdownMenuItem(
                              value: 'success',
                              child: Text('Success'),
                            ),
                            DropdownMenuItem(
                              value: 'info',
                              child: Text('Info'),
                            ),
                            DropdownMenuItem(
                              value: 'danger',
                              child: Text('Danger'),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _filterType = value ?? '';
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                // Notification list
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    itemCount: filteredNotifications.length + 1,
                    itemBuilder: (context, index) {
                      if (index == filteredNotifications.length) {
                        // Load more indicator or button
                        if (provider.hasMore) {
                          _loadMore(); // Auto load more when scrolled to bottom
                          return Padding(
                            padding: const EdgeInsets.all(16),
                            child: Center(
                              child:
                                  _isLoadingMore
                                      ? const CircularProgressIndicator()
                                      : ElevatedButton(
                                        onPressed: _loadMore,
                                        child: const Text('Load More'),
                                      ),
                            ),
                          );
                        } else {
                          return const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(
                              child: Text(
                                'No more notifications',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          );
                        }
                      }

                      final notification = filteredNotifications[index];
                      return NotificationCard(
                        notification: notification,
                        isNew: _isRecentNotification(notification),
                        onTap: () {
                          _handleNotificationTap(notification);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  bool _isRecentNotification(Map<String, dynamic> notification) {
    try {
      final createdAt = notification['created_at'];
      if (createdAt == null) return false;

      DateTime notificationTime;
      if (createdAt is String) {
        notificationTime = DateTime.parse(createdAt);
      } else if (createdAt is int) {
        notificationTime = DateTime.fromMillisecondsSinceEpoch(
          createdAt * 1000,
        );
      } else {
        return false;
      }

      final now = DateTime.now();
      final difference = now.difference(notificationTime);
      return difference.inMinutes < 5;
    } catch (e) {
      return false;
    }
  }

  void _handleNotificationTap(Map<String, dynamic> notification) {
    if (notification['device_id'] != null) {
      // Navigator.pushNamed(context, '/device-detail',
      //                    arguments: notification['device_id']);
    }
  }
}

class NotificationCard extends StatelessWidget {
  final Map<String, dynamic> notification;
  final bool isNew;
  final VoidCallback? onTap;

  const NotificationCard({
    Key? key,
    required this.notification,
    this.isNew = false,
    this.onTap,
  }) : super(key: key);

  String _formatDate(dynamic dateValue) {
    try {
      DateTime date;

      if (dateValue == null) {
        return 'Unknown date';
      } else if (dateValue is int) {
        date = DateTime.fromMillisecondsSinceEpoch(dateValue * 1000);
      } else if (dateValue is String) {
        date = DateTime.parse(dateValue);
      } else {
        return 'Invalid date';
      }

      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inMinutes < 1) {
        return 'Just now';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes}m ago';
      } else if (difference.inHours < 24) {
        return '${difference.inHours}h ago';
      } else {
        return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
      }
    } catch (e) {
      return dateValue.toString();
    }
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'info':
        return Colors.blue;
      case 'success':
        return Colors.green;
      case 'warning':
        return Colors.orange;
      case 'danger':
      case 'alert':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    final type = notification['type']?.toString() ?? 'info';
    final color = _getTypeColor(type);

    // Always use 'message' field if available, otherwise fallback to 'body' or empty string
    final message =
        notification['message']?.toString() ??
        notification['body']?.toString() ??
        '';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          decoration: BoxDecoration(
            color: _getCardColor(type),
            borderRadius: BorderRadius.circular(8),
            border: Border(left: BorderSide(color: color, width: 4)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      message, // Always show the message here
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  Text(
                    _formatDate(
                      notification['created_at'] ?? notification['timestamp'],
                    ),
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
              if (notification['device_id'] != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    'Device: ${notification['device_id']}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getCardColor(String type) {
    switch (type.toLowerCase()) {
      case 'info':
        return Colors.blue.shade50;
      case 'success':
        return Colors.green.shade50;
      case 'danger':
      case 'alert':
        return Colors.red.shade50;
      default:
        return Colors.grey.shade50;
    }
  }
}
