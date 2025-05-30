import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:zheer/models/sensor_data.dart';

class DeviceCard extends StatelessWidget {
  final SensorData sensorData;
  final bool isUnregistered;

  const DeviceCard({
    Key? key,
    required this.sensorData,
    this.isUnregistered = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final isOnline = isUnregistered ? false : sensorData.status;
    final updatedAt =
        isUnregistered
            ? ''
            : DateFormat('MMM d, HH:mm').format(sensorData.createdAt.toLocal());

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Device ID & Status Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Device: ${sensorData.deviceId}',
                style: theme.textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Chip(
                label: Text(
                  isUnregistered
                      ? 'Unregistered Device'
                      : (isOnline ? 'Open' : 'Closed'),
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
                backgroundColor:
                    isUnregistered
                        ? Colors.redAccent
                        : (isOnline ? Colors.green : const Color(0xFF23538F)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Metrics Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _infoItem(
                Icons.thermostat,
                'Temp',
                isUnregistered ? '--' : '${sensorData.temperature}°C',
              ),
              _infoItem(
                Icons.battery_std,
                'Battery',
                isUnregistered
                    ? '--'
                    : '${sensorData.battery.toStringAsFixed(1)}%',
              ),
              _infoItem(
                Icons.numbers,
                'Count',
                isUnregistered ? '--' : '${sensorData.count}',
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Updated time
          if (!isUnregistered)
            Row(
              children: [
                const Icon(Icons.access_time, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  'Updated: $updatedAt',
                  style: theme.textTheme.bodySmall!.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _infoItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.blueAccent),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ],
        ),
      ],
    );
  }
}
