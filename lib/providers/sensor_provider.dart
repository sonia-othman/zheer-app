import 'package:flutter/material.dart';
import '../models/sensor_data.dart';
import '../services/api_service.dart';
import '../services/pusher_service.dart';

class SensorProvider with ChangeNotifier {
  final ApiService apiService;
  final PusherService pusherService;

  // Current device data - refreshed from API each time
  List<SensorData> _currentDeviceData = [];
  SensorData? _currentDeviceLatest;
  String _selectedDeviceId = '';
  bool _isLoading = false;
  String? _errorMessage;

  SensorProvider(this.apiService, this.pusherService);

  // Getters
  List<SensorData> get filteredData => _currentDeviceData;
  SensorData? get currentDeviceLatest => _currentDeviceLatest;
  String get selectedDeviceId => _selectedDeviceId;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Load fresh data from API only
  Future<void> loadFilteredSensorData({
    required String deviceId,
    required String filter,
    bool forceRefresh = false, // Keep for compatibility but always refresh
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _selectedDeviceId = deviceId;
    notifyListeners();

    try {
      print(
        '🔄 Loading fresh filtered data from API for $deviceId with filter: $filter',
      );

      // Always get fresh data from API
      final data = await apiService.getSensorDataFiltered(
        deviceId: deviceId,
        filter: filter,
      );
      _currentDeviceData = data;

      // Also load the latest device data
      await loadCurrentDeviceLatest(deviceId);

      print('✅ Loaded ${data.length} filtered records from API for $deviceId');
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('❌ loadFilteredSensorData error: $e');
      _errorMessage = e.toString();
      _currentDeviceData = [];
      _currentDeviceLatest = null;
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch latest data for current device from API
  Future<void> loadCurrentDeviceLatest(String deviceId) async {
    try {
      print('🔄 Loading fresh latest data from API for device: $deviceId');
      final deviceData = await apiService.getDeviceData(deviceId);
      _currentDeviceLatest = deviceData['latest'] as SensorData?;
      print(
        '✅ Loaded fresh latest data from API: ${_currentDeviceLatest?.deviceId} at ${_currentDeviceLatest?.createdAt}',
      );
    } catch (e) {
      print('❌ loadCurrentDeviceLatest error: $e');
      _currentDeviceLatest = null;
    }
  }

  // Refresh only the current device's latest data from API
  Future<void> refreshCurrentDeviceLatest() async {
    if (_selectedDeviceId.isNotEmpty) {
      print('🔄 Refreshing latest data from API for: $_selectedDeviceId');
      await loadCurrentDeviceLatest(_selectedDeviceId);
      notifyListeners();
    }
  }

  // Handle real-time updates from Pusher
  void updateDeviceDataRealtime(String deviceId, SensorData newData) {
    print('📨 Received realtime update for device: $deviceId');

    // Update current device's filtered data if it matches
    if (_selectedDeviceId == deviceId && _currentDeviceData.isNotEmpty) {
      _currentDeviceData.insert(0, newData);
      // Keep only recent data to prevent memory issues
      if (_currentDeviceData.length > 100) {
        _currentDeviceData.removeLast();
      }
    }

    // Update latest data if it matches current device
    if (_selectedDeviceId == deviceId) {
      _currentDeviceLatest = newData;
      print('✅ Updated current device latest data via realtime');
    }

    notifyListeners();
  }

  // Initialize real-time updates
  void initializeRealtimeUpdates() {
    try {
      pusherService.subscribeToChannel('sensor-data');
      pusherService.bindEvent('SensorDataUpdated', (data) {
        try {
          print("📨 SensorProvider received realtime update");
          print("📨 Data: $data");

          Map<String, dynamic> sensorJson;
          if (data is Map<String, dynamic>) {
            sensorJson = data;
          } else {
            print(
              "❌ Invalid sensor data format, expected Map but got: ${data.runtimeType}",
            );
            return;
          }

          final sensor = SensorData.fromJson(sensorJson);
          updateDeviceDataRealtime(sensor.deviceId, sensor);
          print("✅ SensorProvider updated device: ${sensor.deviceId}");
        } catch (e) {
          print('❌ Error in SensorProvider realtime data parse: $e');
        }
      });

      print("✅ SensorProvider realtime updates initialized");
    } catch (e) {
      print("❌ Failed to initialize SensorProvider realtime updates: $e");
    }
  }

  // Clear all data (for when switching devices or refreshing)
  void clearCurrentData() {
    _currentDeviceData.clear();
    _currentDeviceLatest = null;
    _selectedDeviceId = '';
    _errorMessage = null;
    print('🗑️ Cleared all current device data');
  }

  @override
  void dispose() {
    pusherService.unbindEvent('SensorDataUpdated');
    super.dispose();
  }
}
