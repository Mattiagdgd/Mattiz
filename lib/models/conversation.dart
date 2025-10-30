import 'message.dart';

class ConversationSummary {
  ConversationSummary({
    required this.id,
    required this.title,
    required this.participantIds,
    this.lastMessage,
    this.unreadCount = 0,
  });

  final String id;
  final String title;
  final List<String> participantIds;
  final ChatMessage? lastMessage;
  final int unreadCount;

  ConversationSummary copyWith({
    String? id,
    String? title,
    List<String>? participantIds,
    ChatMessage? lastMessage,
    int? unreadCount,
  }) {
    return ConversationSummary(
      id: id ?? this.id,
      title: title ?? this.title,
      participantIds: participantIds ?? this.participantIds,
      lastMessage: lastMessage ?? this.lastMessage,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}
