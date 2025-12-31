import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../domain/providers/settings_provider.dart';

/// Widget displaying daily inspirational quote from Quran/Hadith
class DailyQuoteWidget extends ConsumerWidget {
  const DailyQuoteWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quote = ref.watch(dailyQuoteProvider);
    
    final englishText = quote?.translation ?? 
        'And seek help through patience and prayer, and indeed, it is difficult except for the humbly submissive [to Allah].';
    final source = quote?.reference ?? 'Quran 2:45';
    final arabicText = quote?.arabicText;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingSm + 4, vertical: AppDimensions.paddingSm),
      decoration: BoxDecoration(
        color: AppColors.gray50,
        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.format_quote,
            size: 16,
            color: AppColors.gray400,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (arabicText != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      arabicText,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontFamily: 'Amiri',
                            height: 1.5,
                            fontSize: 13,
                          ),
                      textDirection: TextDirection.rtl,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                Text(
                  '"$englishText"',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontStyle: FontStyle.italic,
                        height: 1.4,
                        color: AppColors.gray700,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '— $source',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.gray500,
                        fontSize: 10,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
