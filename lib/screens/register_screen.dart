import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../services/auth_service.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  static const routeName = 'register';

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _usernameController = TextEditingController();
  String? _errorMessage;

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    final auth = ref.read(authServiceProvider);
    try {
      await auth.register(_usernameController.text.trim());
      if (!mounted) return;
      GoRouter.of(context).go('/chats');
    } on Exception catch (error) {
      setState(() {
        _errorMessage = error.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authServiceProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Crea un profilo anonimo')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Username anonimo',
                hintText: 'Es. NebulaFox',
              ),
            ),
            const SizedBox(height: 16),
            if (_errorMessage != null) ...[
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 12),
            ],
            ElevatedButton(
              onPressed: auth.isLoading ? null : _handleRegister,
              child: auth.isLoading
                  ? const CircularProgressIndicator.adaptive()
                  : const Text('Completa registrazione'),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                GoRouter.of(context).go('/login');
              },
              child: const Text('Ho già un account'),
            ),
          ],
        ),
      ),
    );
  }
}
