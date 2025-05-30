// alerts_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

final alertsProvider = StateNotifierProvider<AlertsNotifier, List<dynamic>>(
  (ref) => AlertsNotifier(),
);

class AlertsNotifier extends StateNotifier<List<dynamic>> {
  AlertsNotifier() : super([]);

  void add(dynamic alert) {
    state = [...state, alert];
  }
}
