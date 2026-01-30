import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../constants/api_constants.dart';
import '../storage/storage.dart';

/// Callback type for WebSocket message handlers.
typedef WebSocketMessageHandler = void Function(WebSocketMessage message);

/// Represents a message received from the WebSocket.
class WebSocketMessage {
  final String type;
  final String conversationId;
  final Map<String, dynamic> data;
  final String? timestamp;

  const WebSocketMessage({
    required this.type,
    required this.conversationId,
    required this.data,
    this.timestamp,
  });

  factory WebSocketMessage.fromJson(Map<String, dynamic> json) {
    return WebSocketMessage(
      type: json['type'] as String? ?? '',
      conversationId: json['conversation_id'] as String? ?? '',
      data: json['data'] as Map<String, dynamic>? ?? {},
      timestamp: json['timestamp'] as String?,
    );
  }

  /// Check if this is a new message event.
  bool get isNewMessage => type == 'new_message';

  /// Check if this is a typing indicator.
  bool get isTyping => type == 'typing';

  /// Check if this is a connection event.
  bool get isConnected => type == 'connected';

  /// Check if this is an error event.
  bool get isError => type == 'error';
}

/// Message types for WebSocket communication.
class WebSocketMessageTypes {
  static const String newMessage = 'new_message';
  static const String messageUpdated = 'message_updated';
  static const String typing = 'typing';
  static const String connected = 'connected';
  static const String error = 'error';
  static const String ping = 'ping';
  static const String pong = 'pong';
}

/// Connection state for WebSocket.
enum WebSocketState {
  disconnected,
  connecting,
  connected,
  reconnecting,
}

/// Service for managing WebSocket connections for real-time chat.
///
/// Features:
/// - Automatic reconnection with exponential backoff
/// - Per-conversation connection management
/// - Message broadcasting to listeners
class WebSocketService {
  // Singleton pattern
  WebSocketService._internal();
  static final WebSocketService _instance = WebSocketService._internal();
  factory WebSocketService() => _instance;

  // Active WebSocket channel per conversation
  final Map<String, WebSocketChannel> _channels = {};

  // Message listeners per conversation
  final Map<String, Set<WebSocketMessageHandler>> _listeners = {};

  // Connection state per conversation
  final Map<String, WebSocketState> _states = {};

  // Stream subscriptions for cleanup
  final Map<String, StreamSubscription> _subscriptions = {};

  // Reconnection attempts tracking
  final Map<String, int> _reconnectAttempts = {};
  static const int _maxReconnectAttempts = 5;
  static const Duration _baseReconnectDelay = Duration(seconds: 2);

  // Ping timer for keeping connection alive
  final Map<String, Timer?> _pingTimers = {};
  static const Duration _pingInterval = Duration(seconds: 30);

  /// Get the current connection state for a conversation.
  WebSocketState getState(String conversationId) {
    return _states[conversationId] ?? WebSocketState.disconnected;
  }

  /// Connect to a conversation's WebSocket.
  ///
  /// Establishes a WebSocket connection for real-time updates.
  /// Automatically handles authentication and reconnection.
  Future<bool> connect(String conversationId) async {
    // Already connected or connecting
    final currentState = _states[conversationId];
    if (currentState == WebSocketState.connected ||
        currentState == WebSocketState.connecting) {
      debugPrint('WebSocket: Already connected/connecting to $conversationId');
      return currentState == WebSocketState.connected;
    }

    _states[conversationId] = WebSocketState.connecting;

    try {
      // Get auth token
      final token = await SecureStorage().getAccessToken();
      if (token == null) {
        debugPrint('WebSocket: No auth token available');
        _states[conversationId] = WebSocketState.disconnected;
        return false;
      }

      // Build WebSocket URL with token
      final wsUrl = '${ApiConstants.conversationWs(conversationId)}?token=$token';
      debugPrint('WebSocket: Connecting to $wsUrl');

      // Create WebSocket channel
      final channel = WebSocketChannel.connect(Uri.parse(wsUrl));

      // Wait for connection to be established
      await channel.ready;

      _channels[conversationId] = channel;
      _states[conversationId] = WebSocketState.connected;
      _reconnectAttempts[conversationId] = 0;

      // Listen for messages
      _subscriptions[conversationId] = channel.stream.listen(
        (data) => _handleMessage(conversationId, data),
        onError: (error) => _handleError(conversationId, error),
        onDone: () => _handleDisconnect(conversationId),
      );

      // Start ping timer to keep connection alive
      _startPingTimer(conversationId);

      debugPrint('WebSocket: Connected to $conversationId');
      return true;
    } catch (e) {
      debugPrint('WebSocket: Connection error - $e');
      _states[conversationId] = WebSocketState.disconnected;
      _scheduleReconnect(conversationId);
      return false;
    }
  }

  /// Disconnect from a conversation's WebSocket.
  void disconnect(String conversationId) {
    debugPrint('WebSocket: Disconnecting from $conversationId');

    // Cancel ping timer
    _pingTimers[conversationId]?.cancel();
    _pingTimers.remove(conversationId);

    // Cancel stream subscription
    _subscriptions[conversationId]?.cancel();
    _subscriptions.remove(conversationId);

    // Close channel
    _channels[conversationId]?.sink.close();
    _channels.remove(conversationId);

    // Update state
    _states[conversationId] = WebSocketState.disconnected;

    // Reset reconnect attempts
    _reconnectAttempts.remove(conversationId);
  }

  /// Disconnect from all conversations.
  void disconnectAll() {
    final conversationIds = List<String>.from(_channels.keys);
    for (final id in conversationIds) {
      disconnect(id);
    }
    _listeners.clear();
  }

  /// Add a message listener for a conversation.
  ///
  /// The handler will be called for every message received on this conversation.
  void addListener(String conversationId, WebSocketMessageHandler handler) {
    _listeners[conversationId] ??= {};
    _listeners[conversationId]!.add(handler);
    debugPrint('WebSocket: Added listener for $conversationId');
  }

  /// Remove a message listener.
  void removeListener(String conversationId, WebSocketMessageHandler handler) {
    _listeners[conversationId]?.remove(handler);
    debugPrint('WebSocket: Removed listener for $conversationId');
  }

  /// Remove all listeners for a conversation.
  void removeAllListeners(String conversationId) {
    _listeners.remove(conversationId);
  }

  /// Send a message through the WebSocket.
  void send(String conversationId, Map<String, dynamic> message) {
    final channel = _channels[conversationId];
    if (channel == null) {
      debugPrint('WebSocket: Cannot send - not connected to $conversationId');
      return;
    }

    try {
      channel.sink.add(jsonEncode(message));
    } catch (e) {
      debugPrint('WebSocket: Send error - $e');
    }
  }

  /// Send a typing indicator.
  void sendTyping(String conversationId) {
    send(conversationId, {'type': WebSocketMessageTypes.typing});
  }

  // ============================================================
  // Private Methods
  // ============================================================

  void _handleMessage(String conversationId, dynamic data) {
    try {
      final jsonData = data is String ? jsonDecode(data) : data;

      if (jsonData is! Map<String, dynamic>) {
        debugPrint('WebSocket: Invalid message format');
        return;
      }

      // Handle pong response
      if (jsonData['type'] == WebSocketMessageTypes.pong) {
        debugPrint('WebSocket: Received pong from $conversationId');
        return;
      }

      final message = WebSocketMessage.fromJson(jsonData);
      debugPrint('WebSocket: Received ${message.type} for $conversationId');

      // Notify listeners
      final listeners = _listeners[conversationId];
      if (listeners != null) {
        for (final handler in listeners) {
          try {
            handler(message);
          } catch (e) {
            debugPrint('WebSocket: Listener error - $e');
          }
        }
      }
    } catch (e) {
      debugPrint('WebSocket: Message parse error - $e');
    }
  }

  void _handleError(String conversationId, dynamic error) {
    debugPrint('WebSocket: Error on $conversationId - $error');
    _handleDisconnect(conversationId);
  }

  void _handleDisconnect(String conversationId) {
    debugPrint('WebSocket: Disconnected from $conversationId');

    // Cancel ping timer
    _pingTimers[conversationId]?.cancel();

    // Update state
    _states[conversationId] = WebSocketState.disconnected;

    // Clean up channel
    _channels.remove(conversationId);
    _subscriptions.remove(conversationId);

    // Schedule reconnection if there are still listeners
    if (_listeners[conversationId]?.isNotEmpty ?? false) {
      _scheduleReconnect(conversationId);
    }
  }

  void _scheduleReconnect(String conversationId) {
    final attempts = _reconnectAttempts[conversationId] ?? 0;

    if (attempts >= _maxReconnectAttempts) {
      debugPrint('WebSocket: Max reconnect attempts reached for $conversationId');
      // Notify listeners of permanent disconnect
      final listeners = _listeners[conversationId];
      if (listeners != null) {
        final errorMessage = WebSocketMessage(
          type: WebSocketMessageTypes.error,
          conversationId: conversationId,
          data: {'error': 'Connection lost. Please refresh.'},
        );
        for (final handler in listeners) {
          handler(errorMessage);
        }
      }
      return;
    }

    _states[conversationId] = WebSocketState.reconnecting;
    _reconnectAttempts[conversationId] = attempts + 1;

    // Exponential backoff
    final delay = _baseReconnectDelay * (1 << attempts);
    debugPrint(
        'WebSocket: Scheduling reconnect in ${delay.inSeconds}s (attempt ${attempts + 1})');

    Future.delayed(delay, () {
      // Only reconnect if still in reconnecting state and has listeners
      if (_states[conversationId] == WebSocketState.reconnecting &&
          (_listeners[conversationId]?.isNotEmpty ?? false)) {
        connect(conversationId);
      }
    });
  }

  void _startPingTimer(String conversationId) {
    _pingTimers[conversationId]?.cancel();
    _pingTimers[conversationId] = Timer.periodic(_pingInterval, (_) {
      if (_states[conversationId] == WebSocketState.connected) {
        send(conversationId, {'type': WebSocketMessageTypes.ping});
      }
    });
  }
}
