import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/constants/app_strings.dart';
import 'data/datasources/local/hive_service.dart';
import 'data/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await HiveService.instance.initialize();
  
  // Initialize notification service
  await NotificationService().initialize();

  runApp(
    const ProviderScope(
      child: IslamicTodoApp(),
    ),
  );
}

/// Main app widget
class IslamicTodoApp extends StatelessWidget {
  const IslamicTodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: AppRouter.router,
    );
  }
}
