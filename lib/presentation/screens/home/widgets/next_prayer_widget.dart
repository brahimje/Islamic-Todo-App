import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../domain/providers/prayer_provider.dart';
import '../../../../domain/providers/settings_provider.dart';

/// Widget showing countdown to the next prayer
class NextPrayerWidget extends ConsumerStatefulWidget {
  const NextPrayerWidget({super.key});

  @override
  ConsumerState<NextPrayerWidget> createState() => _NextPrayerWidgetState();
}

class _NextPrayerWidgetState extends ConsumerState<NextPrayerWidget> {
  Timer? _timer;
  String _countdown = '';

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          _updateCountdown();
        });
      }
    });
    _updateCountdown();
  }

  void _updateCountdown() {
    final nextPrayer = ref.read(nextPrayerProvider);
    if (nextPrayer != null) {
      final now = DateTime.now();
      final diff = nextPrayer.time.difference(now);
      
      if (diff.isNegative) {
        _countdown = 'Now';
      } else {
        final hours = diff.inHours;
        final minutes = diff.inMinutes.remainder(60);
        final seconds = diff.inSeconds.remainder(60);
        
        if (hours > 0) {
          _countdown = '${hours}h ${minutes}m';
        } else if (minutes > 0) {
          _countdown = '${minutes}m ${seconds}s';
        } else {
          _countdown = '${seconds}s';
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final nextPrayer = ref.watch(nextPrayerProvider);
    final settings = ref.watch(settingsProvider);
    final timeFormat = settings.use24HourFormat ? 'HH:mm' : 'h:mm a';
    
    final prayerName = nextPrayer?.name ?? 'Dhuhr';
    final prayerTime = nextPrayer != null 
        ? DateFormat(timeFormat).format(nextPrayer.time) 
        : '12:45';
    final countdown = _countdown.isEmpty ? '...' : _countdown;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.paddingLg),
      decoration: BoxDecoration(
        color: AppColors.black,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      child: Column(
        children: [
          Text(
            'Next Prayer',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppColors.gray400,
                  letterSpacing: 1,
                ),
          ),
          const SizedBox(height: AppDimensions.spacingSm),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                prayerName,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(width: AppDimensions.spacingSm),
              Text(
                'in',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.gray400,
                    ),
              ),
              const SizedBox(width: AppDimensions.spacingSm),
              Text(
                countdown,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingXs),
          Text(
            prayerTime,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.gray400,
                ),
          ),
        ],
      ),
    );
  }
}
