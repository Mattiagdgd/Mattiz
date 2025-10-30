import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'routes/app_router.dart';
import 'theme/theme.dart';

class MattizApp extends ConsumerWidget {
  const MattizApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Mattiz',
      theme: buildMattizTheme(),
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
