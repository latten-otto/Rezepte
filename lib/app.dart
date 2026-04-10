import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rezepte/core/router/app_router.dart';
import 'package:rezepte/core/theme/app_theme.dart';

class RezepteApp extends ConsumerWidget {
  const RezepteApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Rezepte',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
      locale: const Locale('de', 'DE'),
      supportedLocales: const [
        Locale('de', 'DE'),
      ],
    );
  }
}
