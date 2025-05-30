import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

final sensorHistoryProvider = FutureProvider.autoDispose
    .family<List<dynamic>, String>((ref, deviceId) async {
      final response = await http.get(
        Uri.parse('http://your-api-url/api/sensor-data?device_id=$deviceId'),
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load sensor history');
      }
    });

class SensorDetailScreen extends ConsumerWidget {
  final String deviceId;

  const SensorDetailScreen({super.key, required this.deviceId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sensorHistoryAsync = ref.watch(sensorHistoryProvider(deviceId));

    return Scaffold(
      appBar: AppBar(title: Text('Sensor: $deviceId')),
      body: sensorHistoryAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (error, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: $error'),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed:
                        () => ref.refresh(sensorHistoryProvider(deviceId)),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
        data: (history) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildDetailCard(
                  'Temperature History',
                  Icons.thermostat,
                  Colors.orange,
                  history.map((h) => h['temperature']).toList(),
                ),
                const SizedBox(height: 16),
                _buildDetailCard(
                  'Battery History',
                  Icons.battery_full,
                  Colors.green,
                  history.map((h) => h['battery']).toList(),
                ),
                const SizedBox(height: 16),
                _buildDetailCard(
                  'Count History',
                  Icons.countertops,
                  Colors.blue,
                  history.map((h) => h['count']).toList(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailCard(
    String title,
    IconData icon,
    Color color,
    List<dynamic> data,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 24, color: color),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: data.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          width: 20,
                          height:
                              data[index].toDouble() *
                              2, // Adjust scaling as needed
                          color: color,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          data[index].toString(),
                          style: const TextStyle(fontSize: 10),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
