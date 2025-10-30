import 'package:flutter/material.dart';

import '../models/message.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.message,
  });

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final alignment = message.isOwn ? Alignment.centerRight : Alignment.centerLeft;
    final colorScheme = Theme.of(context).colorScheme;
    final color = message.isOwn ? colorScheme.primary : colorScheme.secondaryContainer;
    final textColor = message.isOwn ? Colors.white : Colors.black87;

    return Align(
      alignment: alignment,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: message.isOwn
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                message.body,
                style: TextStyle(color: textColor),
              ),
              const SizedBox(height: 4),
              Text(
                _formatMetadata(message),
                style: TextStyle(
                  color: textColor.withOpacity(0.7),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatMetadata(ChatMessage message) {
    final timestamp = message.timestamp;
    final formattedTime =
        '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    final transportLabel =
        message.transport == MessageTransport.bluetooth ? 'Bluetooth' : 'Internet';
    return '$formattedTime · $transportLabel';
  }
}
