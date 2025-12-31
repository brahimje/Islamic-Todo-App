import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/prayer_data.dart';
import '../../../../domain/providers/prayer_provider.dart';
import '../../../../domain/providers/nafila_provider.dart';
import '../../../../domain/providers/settings_provider.dart';

/// Widget showing today's prayer list with completion status
class PrayerListWidget extends ConsumerWidget {
  const PrayerListWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prayers = ref.watch(todayPrayersProvider);
    final nafilas = ref.watch(enabledNafilasProvider);
    final completionNotifier = ref.read(prayerCompletionProvider.notifier);
    final nafilaNotifier = ref.read(nafilaPrayerProvider.notifier);
    final settings = ref.watch(settingsProvider);
    final timeFormat = settings.use24HourFormat ? 'HH:mm' : 'h:mm a';
    
    // Get nafila prayer info for display
    final nafilaPrayerInfos = PrayerData.nafilaPrayers;
    
    // Combine prayers and enabled nafilas
    final List<_PrayerItem> allPrayers = [
      ...prayers.map((p) => _PrayerItem(
        id: p.id,
        name: p.name,
        time: DateFormat(timeFormat).format(p.time),
        isCompleted: p.isCompleted,
        isNafila: false,
      )),
      ...nafilas.map((n) {
        final info = nafilaPrayerInfos.firstWhere(
          (i) => i.id == n.prayerInfoId,
          orElse: () => nafilaPrayerInfos.first,
        );
        return _PrayerItem(
          id: n.id,
          name: info.name,
          time: info.timeDescription,
          isCompleted: n.isCompletedToday,
          isNafila: true,
        );
      }),
    ];

    final completedCount = allPrayers.where((p) => p.isCompleted).length;
    final totalCount = allPrayers.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppStrings.todaysPrayers,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingSm,
                vertical: AppDimensions.paddingXs,
              ),
              decoration: BoxDecoration(
                color: AppColors.gray100,
                borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
              ),
              child: Text(
                '$completedCount/$totalCount',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.spacingMd),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.gray200),
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: allPrayers.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final prayer = allPrayers[index];
              return _PrayerTile(
                prayer: prayer,
                onToggle: () {
                  if (prayer.isNafila) {
                    if (prayer.isCompleted) {
                      // Can't unmark nafila in current implementation
                    } else {
                      nafilaNotifier.markNafilaCompleted(prayer.id);
                    }
                  } else {
                    if (prayer.isCompleted) {
                      completionNotifier.unmarkPrayerCompleted(prayer.name);
                    } else {
                      completionNotifier.markPrayerCompleted(prayer.name);
                    }
                  }
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _PrayerItem {
  final String id;
  final String name;
  final String time;
  final bool isCompleted;
  final bool isNafila;

  _PrayerItem({
    required this.id,
    required this.name,
    required this.time,
    required this.isCompleted,
    required this.isNafila,
  });
}

class _PrayerTile extends StatelessWidget {
  final _PrayerItem prayer;
  final VoidCallback onToggle;

  const _PrayerTile({required this.prayer, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onToggle,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingMd,
          vertical: AppDimensions.paddingSm,
        ),
        child: Row(
          children: [
            // Checkbox
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: prayer.isCompleted ? AppColors.black : AppColors.white,
                border: Border.all(
                  color: prayer.isCompleted ? AppColors.black : AppColors.gray400,
                  width: 2,
                ),
              ),
              child: prayer.isCompleted
                  ? const Icon(
                      Icons.check,
                      size: 14,
                      color: AppColors.white,
                    )
                  : null,
            ),
            const SizedBox(width: AppDimensions.spacingMd),

            // Prayer name
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        prayer.name,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: prayer.isNafila
                                  ? AppColors.gray600
                                  : AppColors.black,
                              decoration: prayer.isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                      ),
                      if (prayer.isNafila) ...[
                        const SizedBox(width: AppDimensions.spacingXs),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.gray200,
                            borderRadius:
                                BorderRadius.circular(AppDimensions.radiusXs),
                          ),
                          child: Text(
                            'Nafila',
                            style:
                                Theme.of(context).textTheme.labelSmall?.copyWith(
                                      color: AppColors.gray600,
                                      fontSize: 10,
                                    ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // Time
            Text(
              prayer.time,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.gray500,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
