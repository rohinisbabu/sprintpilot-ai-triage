import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'routes/app_router.dart';

void main() {
  runApp(const ProviderScope(child: SprintPilotApp()));
}

class SprintPilotApp extends StatelessWidget {
  const SprintPilotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'SprintPilot AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(),
      routerConfig: AppRouter.router,
    );
  }
}
