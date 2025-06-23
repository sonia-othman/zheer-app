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
  String _currentFilter = 'daily';
  List<DateTime> _dailyTimeData = [];

  late Function(dynamic) _realtimeCallback;
  bool _isRealtimeInitialized = false;

  SensorProvider(this.apiService, this.pusherService) {
    _realtimeCallback = _handleRealtimeUpdate;
  }

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
          data
              .where((item) => item != null && item['created_at'] != null)
              .map(
                (item) =>
                    DateTime.tryParse(item['created_at'].toString()) ??
                    DateTime.now(),
              )
              .toList();
      notifyListeners();
    } catch (e) {
      print('❌ SensorProvider: Daily time data error: $e');
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
    _currentFilter = filter;
    notifyListeners();

    try {
      print('🔄 SensorProvider: Loading filtered data for $deviceId ($filter)');

      final data = await apiService.getSensorDataFiltered(
        deviceId: deviceId,
        filter: filter,
      );

      _currentDeviceData =
          data
              .where((item) => item != null)
              .where((item) => _isValidSensorData(item))
              .toList();

      await loadCurrentDeviceLatest(deviceId);

      if (!_isRealtimeInitialized) {
        initializeRealtimeUpdates();
      }

      _isLoading = false;
      notifyListeners();

      print(
        '✅ SensorProvider: Loaded ${_currentDeviceData.length} valid records',
      );
    } catch (e) {
      print('❌ SensorProvider: Load error: $e');
      _errorMessage = 'Failed to load data. Please try again.';
      _currentDeviceData = [];
      _currentDeviceLatest = null;
      _isLoading = false;
      notifyListeners();
    }
  }

  bool _isValidSensorData(SensorData data) {
    try {
      return data.deviceId.isNotEmpty &&
          data.temperature.isFinite &&
          data.battery.isFinite &&
          data.count >= 0;
    } catch (e) {
      print('⚠️ Invalid sensor data: $e');
      return false;
    }
  }

  Future<void> loadCurrentDeviceLatest(String deviceId) async {
    try {
      final response = await apiService.getDeviceData(deviceId);
      final latest = response['latest'];
      if (latest != null &&
          latest is SensorData &&
          _isValidSensorData(latest)) {
        _currentDeviceLatest = latest;
      } else {
        _currentDeviceLatest = null;
      }
    } catch (e) {
      print('❌ SensorProvider: Latest data error: $e');
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
    if (_selectedDeviceId != deviceId) {
      print(
        '⚠️ SensorProvider: Update for different device ($deviceId != $_selectedDeviceId)',
      );
      return;
    }

    if (!_isValidSensorData(newData)) {
      print('⚠️ SensorProvider: Invalid realtime data received');
      return;
    }

    print('📨 SensorProvider: Updating realtime data for $deviceId');

    _currentDeviceLatest = newData;

    final formattedData = _createFormattedDataPoint(newData);
    if (formattedData != null) {
      _updateChartData(formattedData);
    }

    notifyListeners();
    print('✅ SensorProvider: Real-time update completed');
  }

  Duration _getOptimalTimeBucket(List<SensorData> existingData) {
    if (existingData.isEmpty) {
      return Duration(minutes: 15);
    }

    if (existingData.length < 2) {
      return Duration(minutes: 15);
    }

    final timeSpan = existingData.last.createdAt.difference(
      existingData.first.createdAt,
    );
    final averageGap = Duration(
      milliseconds: timeSpan.inMilliseconds ~/ (existingData.length - 1),
    );

    if (averageGap.inMinutes <= 5) {
      return Duration(minutes: 5);
    } else if (averageGap.inMinutes <= 15) {
      return Duration(minutes: 15);
    } else if (averageGap.inMinutes <= 30) {
      return Duration(minutes: 30);
    } else {
      return Duration(hours: 1);
    }
  }

  SensorData? _createFormattedDataPoint(SensorData newData) {
    try {
      String dateLabel;
      DateTime aggregateTime = newData.createdAt;

      switch (_currentFilter) {
        case 'weekly':
          dateLabel = DateFormat('EEEE').format(newData.createdAt);
          aggregateTime = DateTime(
            newData.createdAt.year,
            newData.createdAt.month,
            newData.createdAt.day,
          );
          break;
        case 'monthly':
          dateLabel = DateFormat('MMM d').format(newData.createdAt);
          aggregateTime = DateTime(
            newData.createdAt.year,
            newData.createdAt.month,
            newData.createdAt.day,
          );
          break;
        default:
          final bucketSize = _getOptimalTimeBucket(_currentDeviceData);

          if (bucketSize.inMinutes <= 5) {
            final minutes = (newData.createdAt.minute ~/ 5) * 5;
            aggregateTime = DateTime(
              newData.createdAt.year,
              newData.createdAt.month,
              newData.createdAt.day,
              newData.createdAt.hour,
              minutes,
            );
            dateLabel = DateFormat('h:mm a').format(aggregateTime);
          } else if (bucketSize.inMinutes <= 15) {
            final minutes = (newData.createdAt.minute ~/ 15) * 15;
            aggregateTime = DateTime(
              newData.createdAt.year,
              newData.createdAt.month,
              newData.createdAt.day,
              newData.createdAt.hour,
              minutes,
            );
            dateLabel = DateFormat('h:mm a').format(aggregateTime);
          } else if (bucketSize.inMinutes <= 30) {
            final minutes = (newData.createdAt.minute ~/ 30) * 30;
            aggregateTime = DateTime(
              newData.createdAt.year,
              newData.createdAt.month,
              newData.createdAt.day,
              newData.createdAt.hour,
              minutes,
            );
            dateLabel = DateFormat('h:mm a').format(aggregateTime);
          } else {
            aggregateTime = DateTime(
              newData.createdAt.year,
              newData.createdAt.month,
              newData.createdAt.day,
              newData.createdAt.hour,
            );
            dateLabel = DateFormat('h:mm a').format(aggregateTime);
          }
          break;
      }

      return SensorData(
        deviceId: newData.deviceId,
        status: newData.status,
        temperature: newData.temperature,
        battery: newData.battery,
        count: newData.count,
        createdAt: aggregateTime,
        dateLabel: dateLabel,
      );
    } catch (e) {
      print('❌ SensorProvider: Error creating formatted data point: $e');
      return null;
    }
  }

  void _updateChartData(SensorData formattedData) {
    try {
      int existingIndex = -1;

      for (int i = 0; i < _currentDeviceData.length; i++) {
        final existing = _currentDeviceData[i];

        bool isSameTimeBucket = false;
        switch (_currentFilter) {
          case 'weekly':
          case 'monthly':
            isSameTimeBucket =
                existing.createdAt.year == formattedData.createdAt.year &&
                existing.createdAt.month == formattedData.createdAt.month &&
                existing.createdAt.day == formattedData.createdAt.day;
            break;
          default:
            isSameTimeBucket =
                existing.createdAt.millisecondsSinceEpoch ==
                formattedData.createdAt.millisecondsSinceEpoch;
            break;
        }

        if (isSameTimeBucket) {
          existingIndex = i;
          break;
        }
      }

      if (existingIndex != -1) {
        final existing = _currentDeviceData[existingIndex];
        final newCount = existing.count + 1;

        double newTemperature = formattedData.temperature;
        if (existing.count > 0 &&
            existing.temperature.isFinite &&
            formattedData.temperature.isFinite) {
          newTemperature =
              ((existing.temperature * existing.count) +
                  formattedData.temperature) /
              newCount;
        }

        _currentDeviceData[existingIndex] = SensorData(
          deviceId: existing.deviceId,
          status: formattedData.status,
          temperature: newTemperature,
          battery: formattedData.battery,
          count: newCount,
          createdAt: existing.createdAt,
          dateLabel: existing.dateLabel,
        );

        print(
          '♻️ SensorProvider: Updated existing data bucket at index $existingIndex (count: $newCount)',
        );
      } else {
        _currentDeviceData.add(formattedData);
        _currentDeviceData.sort((a, b) => a.createdAt.compareTo(b.createdAt));

        print(
          '➕ SensorProvider: Added new data point for ${formattedData.dateLabel}',
        );

        final maxPoints = _getDynamicMaxDataPoints();
        if (_currentDeviceData.length > maxPoints) {
          _currentDeviceData =
              _currentDeviceData
                  .skip(_currentDeviceData.length - maxPoints)
                  .toList();
          print('🔄 SensorProvider: Trimmed data to $maxPoints points');
        }
      }
    } catch (e) {
      print('❌ SensorProvider: Error updating chart data: $e');
    }
  }

  int _getDynamicMaxDataPoints() {
    switch (_currentFilter) {
      case 'weekly':
        return 7;
      case 'monthly':
        return 31;
      default:
        if (_currentDeviceData.isEmpty) return 50;

        final bucketSize = _getOptimalTimeBucket(_currentDeviceData);
        if (bucketSize.inMinutes <= 5) {
          return 288;
        } else if (bucketSize.inMinutes <= 15) {
          return 96;
        } else if (bucketSize.inMinutes <= 30) {
          return 48;
        } else {
          return 24;
        }
    }
  }

  int _getMaxDataPoints() {
    return _getDynamicMaxDataPoints();
  }

  void initializeRealtimeUpdates() {
    if (_isRealtimeInitialized) {
      print('⚠️ SensorProvider: Realtime already initialized');
      return;
    }

    try {
      print('📡 SensorProvider: Initializing realtime updates...');

      pusherService.subscribeToChannel('sensor-data');
      pusherService.bindEvent('SensorDataUpdated', _realtimeCallback);

      _isRealtimeInitialized = true;
      print('✅ SensorProvider: Realtime initialized');
    } catch (e) {
      print('❌ SensorProvider: Realtime init error: $e');
    }
  }

  void _handleRealtimeUpdate(dynamic data) {
    try {
      print('📨 SensorProvider: Realtime update received: $data');

      if (data == null) {
        print('⚠️ SensorProvider: Received null data');
        return;
      }

      final sensor = SensorData.fromJson(data);
      if (_isValidSensorData(sensor)) {
        updateDeviceDataRealtime(sensor.deviceId, sensor);
      } else {
        print('⚠️ SensorProvider: Received invalid sensor data');
      }
    } catch (e) {
      print('❌ SensorProvider: Realtime parse error: $e');
      print('❌ Raw data: $data');
    }
  }

  void forceChartRefresh() {
    print('🔄 SensorProvider: Forcing chart refresh');
    notifyListeners();
  }

  void clearCurrentData() {
    _currentDeviceData.clear();
    _currentDeviceLatest = null;
    _selectedDeviceId = '';
    _errorMessage = null;
    _dailyTimeData = [];
    print('🗑️ SensorProvider: Data cleared');
    notifyListeners();
  }

  @override
  void dispose() {
    if (_isRealtimeInitialized) {
      pusherService.unbindEvent('SensorDataUpdated', _realtimeCallback);
      print('🔌 SensorProvider: Disposed');
    }
    super.dispose();
  }
}
