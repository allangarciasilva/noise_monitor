import 'package:flutter/material.dart';
import 'package:noise_monitor/providers/current_user.dart';
import 'package:noise_monitor/view/home.dart';
import 'package:noise_monitor/view/login.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(
    ProviderScope(
      child: App(),
    ),
  );
}

class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ref.watch(currentUserProvider).when(
            data: (user) {
              if (user == null) {
                return LoginView();
              }
              return HomeView();
            },
            error: (error, _) => Placeholder(),
            loading: () => CircularProgressIndicator(),
          ),
    );
  }
}
