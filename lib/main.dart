import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'services/app_state.dart';
import 'theme/app_theme.dart';
import 'screens/screen_pairing.dart';
import 'screens/screen_main.dart';
import 'screens/screen_confirmation.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState(),
      child: const MedGateApp(),
    ),
  );
}

class MedGateApp extends StatelessWidget {
  const MedGateApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    final router = GoRouter(
      initialLocation: appState.session == null ? '/' : '/main',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const ScreenPairing(),
        ),
        GoRoute(
          path: '/main',
          builder: (context, state) => const ScreenMain(),
        ),
        GoRoute(
          path: '/confirmation',
          builder: (context, state) => const ScreenConfirmation(),
        ),
      ],
    );

    return MaterialApp.router(
      title: 'MedGate Mobile',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: router,
    );
  }
}
