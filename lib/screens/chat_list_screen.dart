import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../controllers/chat_controller.dart';
import '../services/auth_service.dart';

class ChatListScreen extends ConsumerWidget {
  const ChatListScreen({super.key});

  static const routeName = 'chatList';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatState = ref.watch(chatControllerProvider);
    final auth = ref.watch(authServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Conversazioni'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authServiceProvider).logout();
              if (context.mounted) {
                GoRouter.of(context).go('/login');
              }
            },
          ),
        ],
      ),
      body: chatState.conversations.isEmpty
          ? const _EmptyChatState()
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final conversation = chatState.conversations[index];
                return ListTile(
                  onTap: () {
                    ref
                        .read(chatControllerProvider.notifier)
                        .markConversationAsRead(conversation.id);
                    GoRouter.of(context).go('/chats/${conversation.id}');
                  },
                  title: Text(conversation.title),
                  subtitle: conversation.lastMessage == null
                      ? const Text('Nessun messaggio ancora')
                      : Text(
                          conversation.lastMessage!.body,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                  trailing: conversation.unreadCount > 0
                      ? CircleAvatar(
                          backgroundColor:
                              Theme.of(context).colorScheme.secondary,
                          foregroundColor: Colors.white,
                          child: Text('${conversation.unreadCount}'),
                        )
                      : null,
                );
              },
              separatorBuilder: (context, index) => const Divider(),
              itemCount: chatState.conversations.length,
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateConversationDialog(context, ref, auth),
        child: const Icon(Icons.add_comment),
      ),
    );
  }

  Future<void> _showCreateConversationDialog(
    BuildContext context,
    WidgetRef ref,
    AuthService auth,
  ) async {
    final controller = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nuova conversazione privata'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Titolo conversazione',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annulla'),
          ),
          ElevatedButton(
            onPressed: () {
              final chatNotifier = ref.read(chatControllerProvider.notifier);
              final id = chatNotifier.createConversation(
                title: controller.text.isEmpty
                    ? 'Conversazione con ${auth.currentUser?.username ?? 'contatto'}'
                    : controller.text,
                participantIds: [auth.currentUser?.id ?? ''],
              );
              Navigator.of(context).pop();
              GoRouter.of(context).go('/chats/$id');
            },
            child: const Text('Crea'),
          ),
        ],
      ),
    );
  }
}

class _EmptyChatState extends StatelessWidget {
  const _EmptyChatState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 72,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            const Text(
              'Non hai ancora conversazioni attive.\nCrea una nuova chat per iniziare a comunicare in modo anonimo.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
