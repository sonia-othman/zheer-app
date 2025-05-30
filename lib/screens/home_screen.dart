import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zheer/screens/device_dashboard.dart';
import 'package:zheer/widgets/custom_app_bar.dart';
import 'package:zheer/widgets/device_card.dart';
import 'package:zheer/providers/home_sensor_provider.dart';
import 'package:zheer/models/sensor_data.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDeviceData();
    });
  }

  Future<void> _loadDeviceData() async {
    final provider = Provider.of<HomeSensorProvider>(context, listen: false);
    await provider.fetchLatestDevices();
  }

  Future<void> _forceRefresh() async {
    final provider = Provider.of<HomeSensorProvider>(context, listen: false);
    await provider.refreshFromAPI();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Home', showBackButton: false),

      body: Consumer<HomeSensorProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [CircularProgressIndicator(), SizedBox(height: 16)],
              ),
            );
          }

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

          return RefreshIndicator(
            onRefresh: _forceRefresh,
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8),
                    // At the bottom of your devices list, add unregistered cards:
                    itemCount: provider.latestDevices.length + 2,
                    itemBuilder: (context, index) {
                      if (index >= provider.latestDevices.length) {
                        final unregisteredIndex =
                            index - provider.latestDevices.length;
                        return DeviceCard(
                          sensorData: SensorData(
                            deviceId: 'Unregistered-${unregisteredIndex + 1}',
                            status: false,
                            temperature: 0,
                            battery: 0,
                            count: 0,
                            createdAt: DateTime.now(),
                            dateLabel: null,
                          ),
                          isUnregistered: true,
                        );
                      }
                      final device = provider.latestDevices[index];
                      return GestureDetector(
                        onTap: () {
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
