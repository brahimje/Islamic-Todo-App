import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/constants/app_strings.dart';
import 'data/datasources/local/hive_service.dart';
import 'data/services/notification_service.dart';
import 'data/services/daily_reset_service.dart';
import 'generated_files/l10n/app_localizations.dart';
import 'domain/providers/locale_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await HiveService.instance.initialize();
  
  // Initialize notification service
  await NotificationService().initialize();

  // Perform daily reset for recurring tasks
  await _performDailyReset();

  runApp(
    const ProviderScope(
      child: IslamicTodoApp(),
    ),
  );
}

/// Perform daily reset of recurring tasks
Future<void> _performDailyReset() async {
  try {
    final dailyResetService = DailyResetService(
      HiveService.instance.tasksBox,
    );
    
    final newTasks = await dailyResetService.performDailyReset();
    print('Daily reset completed. Generated ${newTasks.length} recurring task instances.');
    
    // Archive old completed tasks (older than 7 days)
    final archivedCount = await dailyResetService.archiveOldCompletedTasks(daysOld: 7);
    print('Archived $archivedCount old completed tasks.');
    
    // Clean up expired recurring tasks
    final cleanedCount = await dailyResetService.cleanupExpiredRecurringTasks();
    print('Cleaned up $cleanedCount expired recurring tasks.');
  } catch (e) {
    print('Error performing daily reset: $e');
  }
}

/// Main app widget
class IslamicTodoApp extends ConsumerWidget {
  const IslamicTodoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    
    return MaterialApp.router(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: AppRouter.router,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
