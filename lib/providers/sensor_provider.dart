import 'package:flutter/material.dart';
import 'package:zheer/models/sensor_data.dart';
import 'package:zheer/services/api_service.dart';
import 'package:zheer/services/pusher_service.dart';
import 'package:intl/intl.dart';

class SensorProvider with ChangeNotifier {
  final ApiService apiService;
  final PusherService pusherService;

  List<SensorData> _currentDeviceData = [];
  SensorData? _currentDeviceLatest;
  String _selectedDeviceId = '';
  String? _errorMessage;
  bool _isLoading = false;
  String _currentFilter = 'daily'; // ✅ Tracks selected filter
  List<DateTime> _dailyTimeData = [];

  SensorProvider(this.apiService, this.pusherService);

  List<SensorData> get filteredData => _currentDeviceData;
  SensorData? get currentDeviceLatest => _currentDeviceLatest;
  String get selectedDeviceId => _selectedDeviceId;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get currentFilter => _currentFilter;
  List<DateTime> get dailyTimeData => _dailyTimeData;

  Future<void> loadDailyTimeData(String deviceId) async {
    try {
      final data = await apiService.getDailyTimeData(deviceId);
      _dailyTimeData =
          data.map((item) => DateTime.parse(item['created_at'])).toList();
      notifyListeners();
    } catch (e) {
      print('Error loading daily time data: $e');
      _dailyTimeData = [];
      notifyListeners();
    }
  }

  Future<void> loadFilteredSensorData({
    required String deviceId,
    required String filter,
    bool forceRefresh = false,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _selectedDeviceId = deviceId;
    _currentFilter = filter; // ✅ Set active filter
    notifyListeners();

    try {
      final data = await apiService.getSensorDataFiltered(
        deviceId: deviceId,
        filter: filter,
      );
      _currentDeviceData = data;
      await loadCurrentDeviceLatest(deviceId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _currentDeviceData = [];
      _currentDeviceLatest = null;
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadCurrentDeviceLatest(String deviceId) async {
    try {
      final response = await apiService.getDeviceData(deviceId);
      _currentDeviceLatest = response['latest'] as SensorData?;
    } catch (e) {
      _currentDeviceLatest = null;
    }
  }

  Future<void> refreshCurrentDeviceLatest() async {
    if (_selectedDeviceId.isNotEmpty) {
      await loadCurrentDeviceLatest(_selectedDeviceId);
      notifyListeners();
    }
  }

  void updateDeviceDataRealtime(String deviceId, SensorData newData) {
    if (_selectedDeviceId != deviceId) return;

    _currentDeviceLatest = newData;

    bool isSameGroup(SensorData entry) {
      switch (_currentFilter) {
        case 'weekly':
          return entry.createdAt.weekday == newData.createdAt.weekday;
        case 'monthly':
          return entry.createdAt.day == newData.createdAt.day;
        default: // 'daily'
          return entry.createdAt.hour == newData.createdAt.hour;
      }
    }

    final index = _currentDeviceData.indexWhere(isSameGroup);

    if (index != -1) {
      final existing = _currentDeviceData[index];
      _currentDeviceData[index] = SensorData(
        deviceId: existing.deviceId,
        status: newData.status,
        temperature: (existing.temperature + newData.temperature) / 2,
        battery: newData.battery,
        count: existing.count + 1,
        createdAt: existing.createdAt,
        dateLabel: existing.dateLabel,
      );
    } else {
      final label = () {
        switch (_currentFilter) {
          case 'weekly':
            return DateFormat('E').format(newData.createdAt);
          case 'monthly':
            return newData.createdAt.day.toString();
          default:
            return DateFormat('HH:00').format(newData.createdAt);
        }
      }();

      _currentDeviceData.add(
        SensorData(
          deviceId: newData.deviceId,
          status: newData.status,
          temperature: newData.temperature,
          battery: newData.battery,
          count: 1,
          createdAt: newData.createdAt,
          dateLabel: label,
        ),
      );
    }

    notifyListeners();
  }

  void initializeRealtimeUpdates() {
    try {
      pusherService.subscribeToChannel('sensor-data');
      pusherService.bindEvent('SensorDataUpdated', (data) {
        try {
          final sensor = SensorData.fromJson(data);
          updateDeviceDataRealtime(sensor.deviceId, sensor);
        } catch (e) {
          print('Realtime parse error: $e');
        }
      });
    } catch (e) {
      print('Pusher init error: $e');
    }
  }

  void clearCurrentData() {
    _currentDeviceData.clear();
    _currentDeviceLatest = null;
    _selectedDeviceId = '';
    _errorMessage = null;
    _dailyTimeData = [];
  }

  @override
  void dispose() {
    pusherService.unbindEvent('SensorDataUpdated');
    super.dispose();
  }
}
