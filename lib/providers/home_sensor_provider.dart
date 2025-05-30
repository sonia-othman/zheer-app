import 'package:flutter/material.dart';
import 'package:zheer/models/sensor_data.dart';
import 'package:zheer/services/api_service.dart';
import 'package:zheer/services/pusher_service.dart';

class HomeSensorProvider extends ChangeNotifier {
  final ApiService _apiService;
  final PusherService _pusherService;

  List<SensorData> _latestDevices = [];
  bool _isLoading = false;
  String? _errorMessage;

  HomeSensorProvider(this._apiService, this._pusherService) {
    _initPusher();
  }

  // Getters
  List<SensorData> get latestDevices => _latestDevices;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Fetch fresh data from API every time
  Future<void> fetchLatestDevices() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      print('🔄 Fetching fresh latest devices from API...');

      // Always get fresh data from API
      final data = await _apiService.getLatestDevices();
      _latestDevices = data.map((json) => SensorData.fromJson(json)).toList();

      print('✅ Loaded ${_latestDevices.length} devices from API');

      // Debug: Print each device
      for (int i = 0; i < _latestDevices.length; i++) {
        final device = _latestDevices[i];
        print(
          'Device $i: ${device.deviceId}, Status: ${device.status}, Temp: ${device.temperature}',
        );
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('❌ Error fetching latest devices from API: $e');
      _errorMessage = e.toString();
      _isLoading = false;
      _latestDevices = []; // Clear on error
      notifyListeners();
    }
  }

  // Force refresh from API
  Future<void> refreshFromAPI() async {
    print('🔄 Force refreshing from API...');
    await fetchLatestDevices();
  }

  // Initialize Pusher for real-time updates
  void _initPusher() async {
    try {
      await _pusherService.subscribeToChannel('sensor-data');
      _pusherService.bindEvent('SensorDataUpdated', _handleRealtimeUpdate);
      print("✅ Pusher initialized for HomeSensorProvider");
    } catch (e) {
      print("❌ Pusher initialization failed: $e");
    }
  }

  // Handle real-time updates
  void _handleRealtimeUpdate(dynamic data) {
    try {
      print("📨 HomeSensorProvider received realtime update");
      print("📨 Data type: ${data.runtimeType}");
      print("📨 Data content: $data");

      Map<String, dynamic> sensorJson;
      if (data is Map<String, dynamic>) {
        sensorJson = data;
      } else {
        print(
          "❌ Invalid data format, expected Map but got: ${data.runtimeType}",
        );
        return;
      }

      final updated = SensorData.fromJson(sensorJson);
      print(
        "✅ Parsed sensor data: Device ${updated.deviceId}, Temp: ${updated.temperature}",
      );

      // Update the device in the list
      final index = _latestDevices.indexWhere(
        (d) => d.deviceId == updated.deviceId,
      );

      if (index != -1) {
        // Update existing device
        _latestDevices[index] = updated;
        print("✅ Updated existing device: ${updated.deviceId}");
      } else {
        // Add new device to the beginning of the list
        _latestDevices.insert(0, updated);
        print("✅ Added new device: ${updated.deviceId}");
      }

      notifyListeners();
    } catch (e) {
      print("❌ Realtime update failed: $e");
      print("❌ Data that caused error: $data");
    }
  }

  // Clear all data
  void clearData() {
    _latestDevices.clear();
    _errorMessage = null;
    print('🗑️ Cleared all home sensor data');
    notifyListeners();
  }

  @override
  void dispose() {
    _pusherService.unbindEvent('SensorDataUpdated');
    super.dispose();
  }
}
