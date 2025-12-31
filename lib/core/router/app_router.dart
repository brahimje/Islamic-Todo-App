import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/screens/calendar/calendar_screen.dart';
import '../../presentation/screens/progress/progress_screen.dart';
import '../../presentation/screens/settings/settings_screen.dart';
import '../../presentation/screens/prayers/prayer_planner_screen.dart';
import '../../presentation/screens/prayers/nafila_selector_screen.dart';
import '../../presentation/screens/tasks/add_edit_task_screen.dart';
import '../../presentation/screens/onboarding/onboarding_screen.dart';
import '../../presentation/screens/challenges/challenges_screen.dart';
import '../../presentation/widgets/shared/main_scaffold.dart';
import '../../data/datasources/local/hive_service.dart';

/// Route names for navigation
class AppRoutes {
  AppRoutes._();

  static const String home = '/';
  static const String calendar = '/calendar';
  static const String progress = '/progress';
  static const String settings = '/settings';
  static const String prayerPlanner = '/prayer-planner';
  static const String nafilaSelector = '/nafila-selector';
  static const String addTask = '/add-task';
  static const String editTask = '/edit-task';
  static const String onboarding = '/onboarding';
  static const String challenges = '/challenges';
}

/// Navigation shell key for nested navigation
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>();

/// App router configuration
class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoutes.home,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      // Check if onboarding is complete
      try {
        final settings = HiveService.instance.getSettings();
        final isOnboardingComplete = settings?.isOnboardingComplete ?? false;
        final isGoingToOnboarding = state.matchedLocation == AppRoutes.onboarding;
        
        if (!isOnboardingComplete && !isGoingToOnboarding) {
          return AppRoutes.onboarding;
        }
        
        if (isOnboardingComplete && isGoingToOnboarding) {
          return AppRoutes.home;
        }
      } catch (e) {
        // If there's an error reading settings, go to onboarding
        if (state.matchedLocation != AppRoutes.onboarding) {
          return AppRoutes.onboarding;
        }
      }
      
      return null;
    },
    routes: [
      // Onboarding route
      GoRoute(
        path: AppRoutes.onboarding,
        name: 'onboarding',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const OnboardingScreen(),
      ),
      // Main shell with bottom navigation
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return MainScaffold(child: child);
        },
        routes: [
          GoRoute(
            path: AppRoutes.home,
            name: 'home',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HomeScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.calendar,
            name: 'calendar',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: CalendarScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.progress,
            name: 'progress',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ProgressScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.settings,
            name: 'settings',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: SettingsScreen(),
            ),
          ),
        ],
      ),
      // Full-screen routes (outside the shell)
      GoRoute(
        path: AppRoutes.prayerPlanner,
        name: 'prayerPlanner',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const PrayerPlannerScreen(),
      ),
      GoRoute(
        path: AppRoutes.nafilaSelector,
        name: 'nafilaSelector',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const NafilaSelectorScreen(),
      ),
      GoRoute(
        path: AppRoutes.challenges,
        name: 'challenges',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const ChallengesScreen(),
      ),
      GoRoute(
        path: AppRoutes.addTask,
        name: 'addTask',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final blockId = state.uri.queryParameters['blockId'];
          return AddEditTaskScreen(initialPrayerBlockId: blockId);
        },
      ),
      GoRoute(
        path: '${AppRoutes.editTask}/:taskId',
        name: 'editTask',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final taskId = state.pathParameters['taskId']!;
          return AddEditTaskScreen(taskId: taskId);
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              state.uri.toString(),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.home),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
}
