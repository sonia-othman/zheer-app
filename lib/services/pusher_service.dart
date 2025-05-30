import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import '../config/app_config.dart';
import 'dart:convert';

class PusherService {
  final AppConfig config;
  late PusherChannelsFlutter pusher;
  final Map<String, Function(dynamic)> _eventCallbacks = {};
  bool _isConnected = false;
  final Set<String> _subscribedChannels = {};

  PusherService(this.config) {
    pusher = PusherChannelsFlutter.getInstance();
    _initPusher();
  }

  Future<void> _initPusher() async {
    try {
      await pusher.init(
        apiKey: config.pusherKey,
        cluster: config.pusherCluster,
        onConnectionStateChange: (String currentState, String previousState) {
          print("🔄 Pusher connection: $previousState -> $currentState");
          _isConnected = currentState == 'CONNECTED';

          // Re-subscribe to channels when reconnected
          if (currentState == 'CONNECTED' && _subscribedChannels.isNotEmpty) {
            _resubscribeChannels();
          }
        },
        onError: (String message, int? code, dynamic e) {
          print("❌ Pusher error: $message (code: $code) - $e");
        },
        onEvent: (event) {
          print(
            "📨 Pusher event received: ${event.eventName} on channel: ${event.channelName}",
          );
          print("📨 Raw event data: ${event.data}");

          final callback = _eventCallbacks[event.eventName];
          if (callback != null) {
            try {
              // Parse the data if it's a string
              dynamic parsedData = event.data;
              if (event.data is String) {
                parsedData = json.decode(event.data);
              }

              print("📨 Parsed event data: $parsedData");

              // Handle Laravel broadcasting format - your event returns {sensorData: {...}}
              if (parsedData is Map && parsedData.containsKey('sensorData')) {
                parsedData = parsedData['sensorData'];
                print("📨 Extracted sensorData: $parsedData");
              }

              callback(parsedData);
            } catch (e) {
              print("❌ Error parsing event data: $e");
              print("❌ Raw data: ${event.data}");
              callback(event.data); // Use raw data as fallback
            }
          } else {
            print("⚠️  No callback registered for event: ${event.eventName}");
          }
        },
      );

      await pusher.connect();
      print("🚀 Pusher initialized and connecting...");
    } catch (e) {
      print("❌ Pusher init error: $e");
    }
  }

  Future<void> subscribeToChannel(String channelName) async {
    try {
      if (_subscribedChannels.contains(channelName)) {
        print("⚠️  Already subscribed to $channelName");
        return;
      }

      await pusher.subscribe(channelName: channelName);
      _subscribedChannels.add(channelName);
      print("✅ Subscribed to channel: $channelName");
    } catch (e) {
      print("❌ Subscribe error for $channelName: $e");
    }
  }

  Future<void> _resubscribeChannels() async {
    print("🔄 Resubscribing to ${_subscribedChannels.length} channels...");
    final channelsToResubscribe = Set<String>.from(_subscribedChannels);
    _subscribedChannels.clear();

    for (String channel in channelsToResubscribe) {
      await subscribeToChannel(channel);
    }
  }

  void bindEvent(String eventName, Function(dynamic) callback) {
    _eventCallbacks[eventName] = callback;
    print("📋 Event bound: $eventName");
  }

  void unbindEvent(String eventName) {
    _eventCallbacks.remove(eventName);
    print("📋 Event unbound: $eventName");
  }

  bool get isConnected => _isConnected;

  Set<String> get subscribedChannels => Set.unmodifiable(_subscribedChannels);

  Future<void> disconnect() async {
    try {
      await pusher.disconnect();
      _eventCallbacks.clear();
      _subscribedChannels.clear();
      _isConnected = false;
      print("🔌 Pusher disconnected");
    } catch (e) {
      print("❌ Disconnect error: $e");
    }
  }

  // Force reconnection
  Future<void> reconnect() async {
    await disconnect();
    await _initPusher();
  }
}
