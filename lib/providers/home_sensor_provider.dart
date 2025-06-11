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
  
  // ✅ Store callback reference for proper cleanup
  late Function(dynamic) _realtimeCallback;

  HomeSensorProvider(this._apiService, this._pusherService) {
    _realtimeCallback = _handleRealtimeUpdate;
    _initPusher();
  }

  // Getters
  List<SensorData> get latestDevices => _latestDevices;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchLatestDevices() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      print('🔄 HomeSensor: Fetching fresh data from API...');

      final data = await _apiService.getLatestDevices();
      _latestDevices = data.map((json) => SensorData.fromJson(json)).toList();

      print('✅ HomeSensor: Loaded ${_latestDevices.length} devices');

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('❌ HomeSensor: API error: $e');
      _errorMessage = e.toString();
      _isLoading = false;
      _latestDevices = [];
      notifyListeners();
    }
  }

  Future<void> refreshFromAPI() async {
    print('🔄 HomeSensor: Force refresh...');
    await fetchLatestDevices();
  }

  void _initPusher() async {
    try {
      print("📡 HomeSensor: Initializing Pusher...");
      
      // ✅ Subscribe to channel
      await _pusherService.subscribeToChannel('sensor-data');

      // ✅ Bind with callback reference
      _pusherService.bindEvent('SensorDataUpdated', _realtimeCallback);

      print("✅ HomeSensor: Pusher ready");
    } catch (e) {
      print("❌ HomeSensor: Pusher init failed: $e");
    }
  }

  void _handleRealtimeUpdate(dynamic data) {
    try {
      print("📨 HomeSensor: Realtime update received");
      print("📨 HomeSensor: Data: $data");

      if (data is! Map<String, dynamic>) {
        print("❌ HomeSensor: Invalid data format");
        return;
      }

      final updated = SensorData.fromJson(data);
      print("✅ HomeSensor: Parsed device: ${updated.deviceId}");

      final index = _latestDevices.indexWhere(
        (d) => d.deviceId == updated.deviceId,
      );
      
      if (index != -1) {
        _latestDevices[index] = updated;
        print("♻️ HomeSensor: Updated existing device: ${updated.deviceId}");
      } else {
        _latestDevices.insert(0, updated);
        print("🆕 HomeSensor: Added new device: ${updated.deviceId}");
      }

      notifyListeners();
    } catch (e) {
      print("❌ HomeSensor: Realtime error: $e");
    }
  }

  void clearData() {
    _latestDevices.clear();
    _errorMessage = null;
    print('🗑️ HomeSensor: Data cleared');
    notifyListeners();
  }

  @override
  void dispose() {
    // ✅ Properly unbind the specific callback
    _pusherService.unbindEvent('SensorDataUpdated', _realtimeCallback);
    print('🔌 HomeSensor: Disposed');
    super.dispose();
  }
}