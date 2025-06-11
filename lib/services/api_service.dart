import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:zheer/config/app_config.dart';
import 'package:zheer/models/sensor_data.dart';

class ApiService {
  final AppConfig config;

  ApiService(this.config);

  Future<Map<String, dynamic>> _getJson(String endpoint) async {
    final url = Uri.parse(
      '${config.apiBaseUrl}/$endpoint'.replaceAll(RegExp(r'(?<!:)/+'), '/'),
    );
    print('🌐 Calling API: $url');

    final response = await http.get(url);

    print('🔧 Response status: ${response.statusCode}');
    print('📦 Response body: ${response.body}');

    return _handleResponse(response);
  }

  Future<List<dynamic>> _getList(String endpoint) async {
    final response = await _getJson(endpoint);
    return List<dynamic>.from(response['data'] ?? []);
  }

  // Add this method to ApiService class
  Future<List<Map<String, dynamic>>> getLatestDevices() async {
    final response = await http.get(
      Uri.parse('${config.apiBaseUrl}/api/home/stats'),
    );
    final json = jsonDecode(response.body);
    return List<Map<String, dynamic>>.from(json['devicesData']);
  }

  Future<List<SensorData>> getSensorDataFiltered({
    required String deviceId,
    required String filter,
  }) async {
    final url = Uri.parse(
      '${config.apiBaseUrl}/api/dashboard/sensor?device_id=$deviceId&filter=$filter',
    );
    final response = await http.get(url);
    final data = jsonDecode(response.body);
    return List<Map<String, dynamic>>.from(
      data,
    ).map((e) => SensorData.fromJson(e)).toList();
  }

  Future<Map<String, dynamic>> _post(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final url = Uri.parse(
      '${config.apiBaseUrl}/$endpoint'.replaceAll(RegExp(r'(?<!:)/+'), '/'),
    );
    final response = await http.post(
      url,
      body: json.encode(body),
      headers: {'Content-Type': 'application/json'},
    );
    return _handleResponse(response);
  }

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('API request failed with status ${response.statusCode}');
    }
  }

  // Device methods
  Future<List<String>> getDevices() async {
    try {
      final response = await http.get(
        Uri.parse('${config.apiBaseUrl}/api/devices'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List) {
          return data.cast<String>(); // Explicitly cast to List<String>
        }
        throw Exception('Unexpected response format');
      }
      throw Exception('Failed with status ${response.statusCode}');
    } catch (e) {
      print('Error fetching devices: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getDeviceData(String deviceId) async {
    try {
      final response = await http.get(
        Uri.parse('${config.apiBaseUrl}/api/devices/$deviceId'),
      );
      print("📦 Device Data API Response: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Handle the latest data
        final latestData = data['latest'];
        if (latestData == null) {
          throw Exception('Latest data is null');
        }
        final latest = SensorData.fromJson({
          ...latestData,
          'device_id': deviceId,
        });

        // Handle history data
        final history =
            List<Map<String, dynamic>>.from(
              data['history'] ?? [],
            ).map((item) => SensorData.fromJson(item)).toList();

        return {'latest': latest, 'history': history};
      }
      throw Exception('Failed with status ${response.statusCode}');
    } catch (e) {
      print('Error getting device data: $e');
      rethrow;
    }
  }

  // Add this missing method
  Future<List<SensorData>> getDeviceHistory(String deviceId) async {
    try {
      final url = Uri.parse(
        '${config.apiBaseUrl}/api/devices/$deviceId/history',
      );
      print("🌐 Calling Device History API: $url");

      final response = await http.get(url);
      print("🔧 Device History Response status: ${response.statusCode}");
      print("📦 Device History API Response: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data is List) {
          return data.map((item) => SensorData.fromJson(item)).toList();
        } else if (data is Map && data.containsKey('error')) {
          throw Exception('API Error: ${data['error']}');
        } else {
          throw Exception(
            'Expected list format for history data, got: ${data.runtimeType}',
          );
        }
      } else if (response.statusCode == 404) {
        print("⚠️ Device history not found for device: $deviceId");
        return []; // Return empty list instead of throwing error
      }
      throw Exception(
        'Failed with status ${response.statusCode}: ${response.body}',
      );
    } catch (e) {
      print('Error getting device history: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getDailyTimeData(String deviceId) async {
    try {
      final response = await http.get(
        Uri.parse(
          '${config.apiBaseUrl}/api/daily-time-data?device_id=$deviceId',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data);
      }
      throw Exception('Failed with status ${response.statusCode}');
    } catch (e) {
      print('Error getting daily time data: $e');
      rethrow;
    }
  }

  Future<List<dynamic>> getSensorData({
    String? deviceId,
    String? filter,
  }) async {
    final params = {
      if (deviceId != null) 'device_id': deviceId,
      if (filter != null) 'filter': filter,
    };
    final query = Uri(queryParameters: params).query;
    return await _getList('sensor-data?$query');
  }

  // Statistics method for dashboard overview
  Future<Map<String, dynamic>> getStatistics({String? deviceId}) async {
    final params = {if (deviceId != null) 'device_id': deviceId};
    final query = Uri(queryParameters: params).query;
    return await _getJson('statistics?$query');
  }

  // Notification Methods
  // Replace the getNotifications method in your ApiService with this:

  Future<Map<String, dynamic>> getNotifications({
    int page = 1,
    int limit = 20,
  }) async {
    final url = Uri.parse(
      '${config.apiBaseUrl}/api/notifications/load-more?page=$page&limit=$limit',
    );
    print('🌐 Calling Notifications API: $url');

    final response = await http.get(url);
    print('🔧 Notifications Response status: ${response.statusCode}');
    print('📦 Notifications Response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return {
        'notifications': List<dynamic>.from(data['notifications'] ?? []),
        'hasMore': data['hasMore'] ?? false,
      };
    } else {
      throw Exception(
        'Notifications API failed with status ${response.statusCode}',
      );
    }
  }

  // Language Methods
  Future<List<String>> getAvailableLanguages() async {
    final response = await _getJson('api/languages');
    return List<String>.from(response['available'] ?? []);
  }

  Future<bool> switchLanguage(String lang) async {
    final response = await _post('language/$lang', {});
    return response['success'] ?? false;
  }

  Future<Map<String, dynamic>> getDeviceDashboardData(String deviceId) async {
    final url = Uri.parse('${config.apiBaseUrl}/api/devices/$deviceId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data;
    } else {
      throw Exception('Failed to load dashboard data: ${response.statusCode}');
    }
  }
}
