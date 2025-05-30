import 'package:flutter/material.dart';
import 'package:zheer/models/sensor_data.dart';

class DeviceCard extends StatelessWidget {
  final SensorData sensorData;

  const DeviceCard({Key? key, required this.sensorData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text('Device: ${sensorData.deviceId}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Temp: ${sensorData.temperature}°C'),
            Text('Battery: ${sensorData.battery}V'),
            Text('Count: ${sensorData.count}'),
            Text('Status: ${sensorData.status ? "Active" : "Inactive"}'),
            Text('Last Updated: ${sensorData.createdAt}'),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }
}
