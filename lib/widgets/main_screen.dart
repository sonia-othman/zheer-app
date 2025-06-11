import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zheer/screens/home_screen.dart';
import 'package:zheer/screens/notifications_screen.dart';
import 'package:zheer/providers/notification_provider.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [const HomeScreen(), const NotificationScreen()];

  @override
  void initState() {
    super.initState();

    // Initialize real-time notifications when the main screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notificationProvider = Provider.of<NotificationProvider>(
        context,
        listen: false,
      );
      notificationProvider.initializeRealtimeNotifications();
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Mark notifications as read when notification tab is tapped
    if (index == 1) {
      final notificationProvider = Provider.of<NotificationProvider>(
        context,
        listen: false,
      );
      notificationProvider.markAllAsRead();
    }
  }

  Widget _buildNotificationIcon(BuildContext context) {
    return Consumer<NotificationProvider>(
      builder: (context, provider, child) {
        final unreadCount = provider.unreadCount;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            const Icon(Icons.notifications),
            if (unreadCount > 0)
              Positioned(
                right: -6,
                top: -6,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 18,
                    minHeight: 18,
                  ),
                  child: Text(
                    unreadCount > 99 ? '99+' : unreadCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  // Alternative: Simple red dot indicator (if you prefer just a dot instead of count)
  Widget _buildNotificationIconWithDot(BuildContext context) {
    return Consumer<NotificationProvider>(
      builder: (context, provider, child) {
        final hasUnread = provider.hasUnreadNotifications;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            const Icon(Icons.notifications),
            if (hasUnread)
              Positioned(
                right: -2,
                top: -2,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: _buildNotificationIcon(
              context,
            ), // Use _buildNotificationIconWithDot for simple dot
            label: 'Notifications',
          ),
        ],
      ),
    );
  }
}
