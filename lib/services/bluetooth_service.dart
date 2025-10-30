import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/message.dart';

final bluetoothServiceProvider = Provider<BluetoothService>((ref) {
  final service = BluetoothService();
  service.initialize();
  ref.onDispose(service.dispose);
  return service;
});

class BluetoothService {
  BluetoothService();

  static const _serviceUuid = Guid('6e400001-b5a3-f393-e0a9-e50e24dcca9e');
  static const _characteristicUuid = Guid('6e400003-b5a3-f393-e0a9-e50e24dcca9e');

  final FlutterBluePlus _bluetooth = FlutterBluePlus.instance;
  final _incomingMessages = StreamController<ChatMessage>.broadcast();
  final _connectionSubscriptions = <StreamSubscription>[];

  Stream<ChatMessage> get messages => _incomingMessages.stream;

  Future<void> initialize() async {
    await _bluetooth.turnOn();
  }

  Future<void> startAdvertising(String userId) async {
    if (!await _bluetooth.isSupported) {
      throw StateError('Bluetooth non supportato sul dispositivo.');
    }

    await _bluetooth.startAdvertising(
      localName: 'Mattiz-$userId',
      serviceUuids: [_serviceUuid],
      manufacturerData: utf8.encode(userId),
    );
  }

  Future<void> stopAdvertising() async {
    await _bluetooth.stopAdvertising();
  }

  Future<void> startScanning() async {
    if (!await _bluetooth.isSupported) {
      return;
    }

    await _bluetooth.startScan(withServices: [_serviceUuid]);
    final subscription = _bluetooth.scanResults.listen((results) async {
      for (final result in results) {
        final device = result.device;
        if (device.remoteId.str.contains('Mattiz-')) {
          await _connectToDevice(device);
        }
      }
    });
    _connectionSubscriptions.add(subscription);
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    try {
      await device.connect(autoConnect: true);
      final services = await device.discoverServices();
      for (final service in services) {
        if (service.serviceUuid == _serviceUuid) {
          for (final characteristic in service.characteristics) {
            if (characteristic.characteristicUuid == _characteristicUuid) {
              await characteristic.setNotifyValue(true);
              final subscription = characteristic.lastValueStream.listen(
                (value) {
                  final payload = utf8.decode(value);
                  final message = _parseMessage(payload);
                  if (message != null) {
                    _incomingMessages.add(message);
                  }
                },
                onError: (error, stackTrace) {
                  debugPrint('Errore ricezione BLE: $error');
                },
              );
              _connectionSubscriptions.add(subscription);
            }
          }
        }
      }
    } on Exception catch (error) {
      debugPrint('Connessione BLE fallita: $error');
    }
  }

  ChatMessage? _parseMessage(String raw) {
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return ChatMessage(
        id: json['id'] as String,
        conversationId: json['conversationId'] as String,
        senderId: json['senderId'] as String,
        body: json['body'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
        transport: MessageTransport.bluetooth,
        status: MessageStatus.delivered,
        isOwn: false,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> sendMessage(
    BluetoothCharacteristic characteristic,
    ChatMessage message,
  ) async {
    final payload = jsonEncode({
      'id': message.id,
      'conversationId': message.conversationId,
      'senderId': message.senderId,
      'body': message.body,
      'timestamp': message.timestamp.toIso8601String(),
    });

    await characteristic.write(utf8.encode(payload), withoutResponse: true);
  }

  void dispose() {
    for (final sub in _connectionSubscriptions) {
      sub.cancel();
    }
    _incomingMessages.close();
  }
}
