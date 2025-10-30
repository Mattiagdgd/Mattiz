import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/chat_controller.dart';
import '../widgets/message_bubble.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key, required this.conversationId});

  static const routeName = 'chat';
  final String conversationId;

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _handleSendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    await ref
        .read(chatControllerProvider.notifier)
        .sendMessage(widget.conversationId, text);
    _messageController.clear();
    await Future<void>.delayed(const Duration(milliseconds: 100));
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(chatControllerProvider);
    final messages = state.messages[widget.conversationId] ?? [];

    return Scaffold(
      appBar: AppBar(title: const Text('Chat privata')),
      body: Column(
        children: [
          Expanded(
            child: ListView.separated(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final message = messages[index];
                return MessageBubble(message: message);
              },
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemCount: messages.length,
            ),
          ),
          _MessageComposer(
            controller: _messageController,
            onSend: _handleSendMessage,
          ),
        ],
      ),
    );
  }
}

class _MessageComposer extends StatelessWidget {
  const _MessageComposer({
    required this.controller,
    required this.onSend,
  });

  final TextEditingController controller;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                minLines: 1,
                maxLines: 5,
                decoration: const InputDecoration(
                  hintText: 'Scrivi un messaggio…',
                ),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: onSend,
              child: const Icon(Icons.send),
            ),
          ],
        ),
      ),
    );
  }
}
