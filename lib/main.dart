import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flowora/core/theme/app_theme.dart';
import 'package:flowora/core/router.dart';
import 'package:flowora/services/api_client.dart';
import 'package:flowora/services/seed_data_loader.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await ApiClient.loadToken();
  await SeedDataLoader.loadIfFirstRun();
  runApp(const ProviderScope(child: FlowOraApp()));
}

class FlowOraApp extends ConsumerWidget {
  const FlowOraApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'Flowora',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}

final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);

final authStateProvider = StateProvider<bool>((ref) => ApiClient.isLoggedIn);
