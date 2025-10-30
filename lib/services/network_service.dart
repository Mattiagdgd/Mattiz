import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../models/message.dart';

final networkServiceProvider = Provider<NetworkService>((ref) {
  final service = NetworkService();
  ref.onDispose(service.dispose);
  return service;
});

class NetworkService {
  NetworkService();

  WebSocketChannel? _channel;
  final _incomingMessages = StreamController<ChatMessage>.broadcast();
  StreamSubscription? _subscription;

  Stream<ChatMessage> get messages => _incomingMessages.stream;

  Future<void> connect(Uri endpoint, String authToken) async {
    await disconnect();

    try {
      _channel = WebSocketChannel.connect(endpoint);
      _subscription = _channel!.stream.listen(
        (event) {
          final decoded = jsonDecode(event as String) as Map<String, dynamic>;
          _incomingMessages.add(
            ChatMessage(
              id: decoded['id'] as String,
              conversationId: decoded['conversationId'] as String,
              senderId: decoded['senderId'] as String,
              body: decoded['body'] as String,
              timestamp: DateTime.parse(decoded['timestamp'] as String),
              transport: MessageTransport.internet,
              status: MessageStatus.delivered,
              isOwn: false,
            ),
          );
        },
        onError: (error) {
          debugPrint('Errore WebSocket: $error');
        },
      );

      send({'type': 'authenticate', 'token': authToken});
    } on Exception catch (error) {
      debugPrint('Connessione WebSocket fallita: $error');
    }
  }

  void send(Map<String, dynamic> payload) {
    _channel?.sink.add(jsonEncode(payload));
  }

  Future<void> sendMessage(ChatMessage message) async {
    send({
      'type': 'message',
      'id': message.id,
      'conversationId': message.conversationId,
      'senderId': message.senderId,
      'body': message.body,
      'timestamp': message.timestamp.toIso8601String(),
    });
  }

  Future<void> disconnect() async {
    await _subscription?.cancel();
    await _channel?.sink.close();
    _subscription = null;
    _channel = null;
  }

  void dispose() {
    disconnect();
    _incomingMessages.close();
  }
}
