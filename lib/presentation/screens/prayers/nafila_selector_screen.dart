import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/prayer_data.dart';
import '../../../domain/providers/nafila_provider.dart';

/// Screen for selecting which Nafila prayers to track
class NafilaSelectorScreen extends ConsumerWidget {
  const NafilaSelectorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nafilas = ref.watch(nafilaPrayerProvider);
    final nafilaNotifier = ref.read(nafilaPrayerProvider.notifier);
    
    // Get set of enabled nafila IDs
    final selectedIds = nafilas.where((n) => n.isEnabled).map((n) => n.id).toSet();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nafila Prayers'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.screenPaddingHorizontal,
          vertical: AppDimensions.screenPaddingVertical,
        ),
        children: [
          Text(
            'Select the Nafila prayers you want to track. These voluntary prayers bring you closer to Allah.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.gray600,
                ),
          ),
          const SizedBox(height: AppDimensions.spacingLg),
          ...PrayerData.nafilaPrayers.map((prayer) {
            final isSelected = selectedIds.contains(prayer.id);
            return _NafilaCard(
              prayer: prayer,
              isSelected: isSelected,
              onToggle: () {
                nafilaNotifier.toggleNafilaEnabled(prayer.id);
              },
            );
          }),
          const SizedBox(height: AppDimensions.spacingXl),
        ],
      ),
    );
  }
}

class _NafilaCard extends StatelessWidget {
  final NafilaPrayerInfo prayer;
  final bool isSelected;
  final VoidCallback onToggle;

  const _NafilaCard({
    required this.prayer,
    required this.isSelected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.spacingMd),
      decoration: BoxDecoration(
        border: Border.all(
          color: isSelected ? AppColors.black : AppColors.gray200,
          width: isSelected ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      child: InkWell(
        onTap: onToggle,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Checkbox
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      color: isSelected ? AppColors.black : AppColors.white,
                      border: Border.all(
                        color: isSelected ? AppColors.black : AppColors.gray400,
                        width: 2,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(
                            Icons.check,
                            size: 16,
                            color: AppColors.white,
                          )
                        : null,
                  ),
                  const SizedBox(width: AppDimensions.spacingMd),

                  // Title
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              prayer.name,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            const SizedBox(width: AppDimensions.spacingSm),
                            Text(
                              prayer.arabicName,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: AppColors.gray500,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${prayer.recommendedRakah} rakah • ${prayer.timeDescription}',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.gray500,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.spacingSm),

              // Description
              Text(
                prayer.description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.gray600,
                      height: 1.4,
                    ),
              ),

              // References
              if (prayer.hadithReference.isNotEmpty) ...[
                const SizedBox(height: AppDimensions.spacingSm),
                Container(
                  padding: const EdgeInsets.all(AppDimensions.paddingSm),
                  decoration: BoxDecoration(
                    color: AppColors.gray50,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                  ),
                  child: Text(
                    prayer.hadithReference,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.gray600,
                          fontStyle: FontStyle.italic,
                          fontSize: 11,
                        ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
