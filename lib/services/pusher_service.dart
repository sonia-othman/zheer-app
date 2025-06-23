import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import '../config/app_config.dart';
import 'dart:convert';

class PusherService {
  final AppConfig config;
  late PusherChannelsFlutter pusher;

  final Map<String, List<Function(dynamic)>> _eventCallbacks = {};
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

          if (currentState == 'CONNECTED' && _subscribedChannels.isNotEmpty) {
            _resubscribeChannels();
          }
        },
        onError: (String message, int? code, dynamic e) {
          print("❌ Pusher error: $message (code: $code) - $e");
        },
        onEvent: (event) {
          print("📨 Pusher event: ${event.eventName} on ${event.channelName}");
          print("📨 Raw data: ${event.data}");

          final callbacks = _eventCallbacks[event.eventName] ?? [];
          if (callbacks.isNotEmpty) {
            try {
              dynamic parsedData = event.data;
              if (event.data is String) {
                parsedData = json.decode(event.data);
              }

              if (parsedData is Map && parsedData.containsKey('sensorData')) {
                parsedData = parsedData['sensorData'];
              }

              for (var callback in callbacks) {
                try {
                  callback(parsedData);
                } catch (e) {
                  print("❌ Callback error: $e");
                }
              }
            } catch (e) {
              print("❌ Parse error: $e");
              for (var callback in callbacks) {
                try {
                  callback(event.data);
                } catch (e) {
                  print("❌ Callback fallback error: $e");
                }
              }
            }
          } else {
            print("⚠️  No callbacks for event: ${event.eventName}");
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
        print("✅ Already subscribed to $channelName");
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
    if (!_eventCallbacks.containsKey(eventName)) {
      _eventCallbacks[eventName] = [];
    }
    _eventCallbacks[eventName]!.add(callback);
    print(
      "📋 Event bound: $eventName (${_eventCallbacks[eventName]!.length} callbacks)",
    );
  }

  void unbindEvent(String eventName, [Function(dynamic)? callback]) {
    _eventCallbacks.remove(eventName);
    print("📋 Event unbound: $eventName");
  }

  void unbindAllEvent(String eventName) {
    _eventCallbacks.remove(eventName);
    print("📋 All callbacks unbound for: $eventName");
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

  Future<void> reconnect() async {
    await disconnect();
    await _initPusher();
  }
}
