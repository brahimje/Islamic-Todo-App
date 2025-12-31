import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/router/app_router.dart';
import '../../../domain/providers/notification_provider.dart';
import 'widgets/daily_quote_widget.dart';
import 'widgets/next_prayer_widget.dart';
import 'widgets/prayer_timeline_widget.dart';

/// Home screen - Main dashboard showing prayers and tasks
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Initialize notifications on home screen load
    ref.watch(notificationManagerProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.appName),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu_book, color: AppColors.black, size: 24),
            onPressed: () => context.push(AppRoutes.challenges),
            tooltip: 'Daily Adhkar',
          ),
          IconButton(
            icon: const Icon(Icons.schedule),
            onPressed: () => context.push(AppRoutes.prayerPlanner),
            tooltip: 'Day Timeline',
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push(AppRoutes.settings),
            tooltip: 'Settings',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppDimensions.spacingSm),
              
              // Next Prayer Countdown
              const Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppDimensions.screenPaddingHorizontal,
                ),
                child: NextPrayerWidget(),
              ),
              const SizedBox(height: AppDimensions.spacingLg),

              // Daily Quote
              const Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppDimensions.screenPaddingHorizontal,
                ),
                child: DailyQuoteWidget(),
              ),
              const SizedBox(height: AppDimensions.spacingLg),

              // Unified Prayer Timeline with Tasks
              const Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppDimensions.screenPaddingHorizontal,
                ),
                child: PrayerTimelineWidget(),
              ),
              const SizedBox(height: AppDimensions.spacingXl),
            ],
          ),
        ),
      ),
    );
  }
}
