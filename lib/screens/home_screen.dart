import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zheer/screens/device_dashboard.dart';
import 'package:zheer/widgets/device_card.dart';
import 'package:zheer/providers/home_sensor_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Load data immediately when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDeviceData();
    });
  }

  Future<void> _loadDeviceData() async {
    print("🔄 Starting to load device data from API...");
    final provider = Provider.of<HomeSensorProvider>(context, listen: false);
    await provider.fetchLatestDevices();
  }

  Future<void> _forceRefresh() async {
    print("🔄 Force refreshing from API...");
    final provider = Provider.of<HomeSensorProvider>(context, listen: false);
    await provider.refreshFromAPI();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Sensor Home'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _forceRefresh,
            tooltip: 'Refresh from API',
          ),
        ],
      ),
      body: Consumer<HomeSensorProvider>(
        builder: (context, provider, child) {
          // Show loading state
          if (provider.isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading fresh data from API...'),
                ],
              ),
            );
          }

          // Show error state
          if (provider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, color: Colors.red, size: 64),
                  const SizedBox(height: 16),
                  Text(
                    'API Error',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      provider.errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _forceRefresh,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry API Call'),
                  ),
                ],
              ),
            );
          }

          // Show empty state
          if (provider.latestDevices.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.device_unknown,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "No devices found",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "API returned no devices",
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _forceRefresh,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Refresh from API'),
                  ),
                ],
              ),
            );
          }

          // Show devices list
          return RefreshIndicator(
            onRefresh: _forceRefresh,
            child: Column(
              children: [
                // API Status Indicator
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    border: Border(
                      bottom: BorderSide(color: Colors.green.withOpacity(0.3)),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.api, size: 16, color: Colors.green),
                      const SizedBox(width: 8),
                      Text(
                        'API Data: ${provider.latestDevices.length} devices',
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: _forceRefresh,
                        icon: const Icon(Icons.refresh, size: 14),
                        label: const Text('Refresh'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                      ),
                    ],
                  ),
                ),
                // Devices List
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: provider.latestDevices.length,
                    itemBuilder: (context, index) {
                      final device = provider.latestDevices[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          vertical: 4,
                          horizontal: 8,
                        ),
                        child: GestureDetector(
                          onTap: () {
                            print(
                              '🔄 Navigating to dashboard for device: ${device.deviceId}',
                            );
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) => DeviceDashboard(
                                      deviceId: device.deviceId,
                                    ),
                              ),
                            );
                          },
                          child: DeviceCard(sensorData: device),
                        ),
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
}
