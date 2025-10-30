import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../screens/chat_list_screen.dart';
import '../screens/chat_screen.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
import '../services/auth_service.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authService = ref.watch(authServiceProvider);

  return GoRouter(
    initialLocation: '/login',
    refreshListenable: authService,
    redirect: (context, state) {
      final loggedIn = authService.isAuthenticated;
      final goingToAuth = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';

      if (!loggedIn && !goingToAuth) {
        return '/login';
      }

      if (loggedIn && goingToAuth) {
        return '/chats';
      }

      return null;
    },
    routes: <GoRoute>[
      GoRoute(
        path: '/login',
        name: LoginScreen.routeName,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: RegisterScreen.routeName,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/chats',
        name: ChatListScreen.routeName,
        builder: (context, state) => const ChatListScreen(),
        routes: [
          GoRoute(
            path: ':conversationId',
            name: ChatScreen.routeName,
            builder: (context, state) {
              final conversationId = state.pathParameters['conversationId'];
              return ChatScreen(conversationId: conversationId!);
            },
          ),
        ],
      ),
    ],
  );
});
