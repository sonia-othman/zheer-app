import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:zheer/models/sensor_data.dart';
import 'package:zheer/l10n/generated/app_localizations.dart';

class DeviceCard extends StatelessWidget {
  final SensorData sensorData;
  final bool isUnregistered;
  final int? deviceIndex;

  const DeviceCard({
    Key? key,
    required this.sensorData,
    this.isUnregistered = false,
    this.deviceIndex,
  }) : super(key: key);

  IconData _getDeviceIcon() {
    if (isUnregistered) {
      if (deviceIndex == 1) return Icons.window;
      if (deviceIndex == 2) return Icons.lock;
      return Icons.sensors;
    }

    final deviceId = sensorData.deviceId.toLowerCase();
    if (deviceId.contains('door') || deviceId.contains('entry')) {
      return Icons.door_front_door;
    } else if (deviceId.contains('window')) {
      return Icons.window;
    } else if (deviceId.contains('motion')) {
      return Icons.motion_photos_on;
    }

    return Icons.door_front_door;
  }

  String _getDeviceTitle(AppLocalizations l10n) {
    if (isUnregistered) {
      switch (deviceIndex) {
        case 0:
          return '${l10n.secondDevice}: ${l10n.labWindow}';
        case 1:
          return '${l10n.thirdDevice}: ${l10n.department}';
        default:
          return '${l10n.device} ${(deviceIndex ?? 0) + 2}: ${l10n.notAvailable}';
      }
    }

    return '${l10n.firstDevice}: ${l10n.labDoor}';
  }

  String _getDeviceSubtitle(AppLocalizations l10n) {
    if (isUnregistered) {
      return l10n.sensorNotRegistered;
    }

    return sensorData.deviceId;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    final isOnline = isUnregistered ? false : sensorData.status;
    final updatedAt =
        isUnregistered
            ? ''
            : DateFormat('MMM d, HH:mm').format(sensorData.createdAt.toLocal());

    return Container(
      width: double.infinity,
      height: 160,
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: isUnregistered ? Colors.grey.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color:
                  isUnregistered
                      ? Colors.grey.shade300
                      : (isOnline
                          ? Colors.red.shade100
                          : Colors.green.shade100),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getDeviceIcon(),
              size: 28,
              color:
                  isUnregistered
                      ? Colors.grey.shade600
                      : (isOnline
                          ? Colors.red.shade500
                          : Colors.green.shade500),
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getDeviceTitle(l10n),
                      style: theme.textTheme.titleMedium!.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _getDeviceSubtitle(l10n),
                      style: theme.textTheme.bodyMedium!.copyWith(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),

                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 11,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color:
                            isUnregistered
                                ? Colors.red.shade100
                                : (isOnline
                                    ? Colors.red.shade100
                                    : Colors.green.shade100),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        isUnregistered
                            ? l10n.sensorNotRegistered
                            : (isOnline ? l10n.opened : l10n.closed),
                        style: TextStyle(
                          color:
                              isUnregistered
                                  ? Colors.red.shade700
                                  : (isOnline
                                      ? Colors.red.shade700
                                      : Colors.green.shade700),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    if (!isUnregistered)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 11,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${l10n.temperatureShort}: ${sensorData.temperature}°C',
                          style: TextStyle(
                            color: Colors.blue.shade700,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),

                    const SizedBox(width: 8),

                    if (!isUnregistered)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 11,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${l10n.battery}: ${sensorData.battery.toStringAsFixed(1)}V',
                          style: TextStyle(
                            color: Colors.orange.shade700,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),

                if (!isUnregistered && updatedAt.isNotEmpty)
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: Colors.grey.shade500,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${l10n.refresh}: $updatedAt',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
