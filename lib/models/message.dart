enum MessageTransport { internet, bluetooth }

enum MessageStatus { sending, sent, delivered, failed }

class ChatMessage {
  ChatMessage({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.body,
    required this.timestamp,
    required this.transport,
    this.status = MessageStatus.sending,
    this.isOwn = false,
  });

  final String id;
  final String conversationId;
  final String senderId;
  final String body;
  final DateTime timestamp;
  final MessageTransport transport;
  final MessageStatus status;
  final bool isOwn;

  ChatMessage copyWith({
    String? id,
    String? conversationId,
    String? senderId,
    String? body,
    DateTime? timestamp,
    MessageTransport? transport,
    MessageStatus? status,
    bool? isOwn,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      body: body ?? this.body,
      timestamp: timestamp ?? this.timestamp,
      transport: transport ?? this.transport,
      status: status ?? this.status,
      isOwn: isOwn ?? this.isOwn,
    );
  }
}
