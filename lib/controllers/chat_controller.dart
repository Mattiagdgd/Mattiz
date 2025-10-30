import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../models/conversation.dart';
import '../models/message.dart';
import '../services/auth_service.dart';
import '../services/bluetooth_service.dart';
import '../services/network_service.dart';

final chatControllerProvider =
    StateNotifierProvider<ChatController, ChatState>((ref) {
  final auth = ref.watch(authServiceProvider);
  final network = ref.watch(networkServiceProvider);
  final bluetooth = ref.watch(bluetoothServiceProvider);

  final controller = ChatController(
    authService: auth,
    networkService: network,
    bluetoothService: bluetooth,
  );

  controller.initialize();
  ref.onDispose(controller.dispose);

  return controller;
});

class ChatState {
  const ChatState({
    this.conversations = const [],
    this.messages = const {},
    this.isLoading = false,
  });

  final List<ConversationSummary> conversations;
  final Map<String, List<ChatMessage>> messages;
  final bool isLoading;

  ChatState copyWith({
    List<ConversationSummary>? conversations,
    Map<String, List<ChatMessage>>? messages,
    bool? isLoading,
  }) {
    return ChatState(
      conversations: conversations ?? this.conversations,
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class ChatController extends StateNotifier<ChatState> {
  ChatController({
    required this.authService,
    required this.networkService,
    required this.bluetoothService,
  }) : super(const ChatState());

  final AuthService authService;
  final NetworkService networkService;
  final BluetoothService bluetoothService;

  final _uuid = const Uuid();
  final _subscriptions = <StreamSubscription>[];

  Future<void> initialize() async {
    state = state.copyWith(isLoading: true);

    final user = authService.currentUser;
    if (user != null) {
      await networkService.connect(Uri.parse('wss://mattiz.example/ws'), user.id);
      await bluetoothService.startAdvertising(user.id);
      await bluetoothService.startScanning();
    }

    _subscriptions.add(networkService.messages.listen(_handleIncomingMessage));
    _subscriptions.add(bluetoothService.messages.listen(_handleIncomingMessage));

    state = state.copyWith(isLoading: false);
  }

  void _handleIncomingMessage(ChatMessage message) {
    final messages = Map<String, List<ChatMessage>>.from(state.messages);
    final conversationMessages = List<ChatMessage>.from(
      messages[message.conversationId] ?? const <ChatMessage>[],
    )
      ..add(message);
    messages[message.conversationId] = conversationMessages;

    final conversations = [...state.conversations];
    final index =
        conversations.indexWhere((conv) => conv.id == message.conversationId);

    if (index == -1) {
      conversations.add(
        ConversationSummary(
          id: message.conversationId,
          title: 'Conversazione anonima',
          participantIds: [message.senderId],
          lastMessage: message,
          unreadCount: message.isOwn ? 0 : 1,
        ),
      );
    } else {
      final current = conversations[index];
      conversations[index] = current.copyWith(
        lastMessage: message,
        unreadCount: message.isOwn ? current.unreadCount : current.unreadCount + 1,
      );
    }

    state = state.copyWith(messages: messages, conversations: conversations);
  }

  Future<void> sendMessage(String conversationId, String text) async {
    final user = authService.currentUser;
    if (user == null) {
      throw StateError('Nessun utente autenticato.');
    }

    final message = ChatMessage(
      id: _uuid.v4(),
      conversationId: conversationId,
      senderId: user.id,
      body: text,
      timestamp: DateTime.now(),
      transport: MessageTransport.internet,
      status: MessageStatus.sending,
      isOwn: true,
    );

    _addLocalMessage(message);
    await networkService.sendMessage(message);
  }

  void _addLocalMessage(ChatMessage message) {
    final messages = Map<String, List<ChatMessage>>.from(state.messages);
    final conversationMessages = List<ChatMessage>.from(
      messages[message.conversationId] ?? const <ChatMessage>[],
    )
      ..add(message);
    messages[message.conversationId] = conversationMessages;

    final conversations = [...state.conversations];
    final index =
        conversations.indexWhere((conv) => conv.id == message.conversationId);

    if (index == -1) {
      conversations.add(
        ConversationSummary(
          id: message.conversationId,
          title: 'Conversazione anonima',
          participantIds: [message.senderId],
          lastMessage: message,
        ),
      );
    } else {
      conversations[index] = conversations[index].copyWith(
        lastMessage: message,
      );
    }

    state = state.copyWith(messages: messages, conversations: conversations);
  }

  String createConversation({
    required String title,
    required List<String> participantIds,
  }) {
    final conversationId = _uuid.v4();
    final conversation = ConversationSummary(
      id: conversationId,
      title: title,
      participantIds: participantIds,
    );

    state = state.copyWith(
      conversations: [...state.conversations, conversation],
    );

    return conversationId;
  }

  void markConversationAsRead(String conversationId) {
    final conversations = state.conversations.map((conversation) {
      if (conversation.id == conversationId) {
        return conversation.copyWith(unreadCount: 0);
      }
      return conversation;
    }).toList();

    state = state.copyWith(conversations: conversations);
  }

  @override
  void dispose() {
    for (final sub in _subscriptions) {
      sub.cancel();
    }
    super.dispose();
  }
}
