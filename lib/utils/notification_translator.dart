import 'package:flutter/material.dart';
import 'package:zheer/l10n/generated/app_localizations.dart';

class NotificationTranslator {
  static String translate({
    required BuildContext context,
    required String? key,
    dynamic rawData, // <-- changed from Map<String, dynamic>? to dynamic
  }) {
    final l10n = AppLocalizations.of(context)!;

    if (key == null) return '';

    // Clean key
    String cleanKey =
        key.startsWith('notifications.')
            ? key.substring('notifications.'.length)
            : key;

    // Safely normalize rawData to Map<String, dynamic> if possible
    Map<String, dynamic>? data;
    try {
      if (rawData is Map<String, dynamic>) {
        data = rawData;
      } else if (rawData is List &&
          rawData.isNotEmpty &&
          rawData.first is Map<String, dynamic>) {
        data = rawData.first;
      }
    } catch (e) {
      data = null;
    }

    // Translation logic
    switch (cleanKey) {
      case 'door_opened':
        return l10n.door_opened;
      case 'door_closed':
        return l10n.door_closed;
      case 'temp_too_high':
        return l10n.temp_too_high(data?['temperature'] ?? '--');
      case 'temp_too_low':
        return l10n.temp_too_low(data?['temperature'] ?? '--');
      case 'connection_lost':
        return l10n.connection_lost;
      case 'battery_critical':
        return l10n.battery_critical(data?['battery'] ?? '--');
      case 'battery_low': // Added missing case
        return l10n.battery_low(data?['battery'] ?? '--');
      case 'door_open_too_long': // Added missing case - THIS WAS THE PROBLEM
        final minutes = data?['minutes'];
        final roundedMinutes =
            minutes is num ? minutes.round() : (minutes ?? '--');
        return l10n.door_open_too_long(roundedMinutes);
      default:
        return cleanKey; // fallback to key if unknown
    }
  }
}
