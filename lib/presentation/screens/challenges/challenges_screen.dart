import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import '../../../core/constants/app_colors.dart';
import '../../../core/extensions/localization_extensions.dart';
import '../../../domain/providers/challenges_provider.dart';

/// Daily Adhkar screen with Tasbih and Adhkar
class ChallengesScreen extends ConsumerStatefulWidget {
  const ChallengesScreen({super.key});

  @override
  ConsumerState<ChallengesScreen> createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends ConsumerState<ChallengesScreen> {
  // Track completion state for each adhkar challenge (local UI state)
  final Map<String, bool> _completedChallenges = {};
  
  // Track if vibration already happened for each counter (local UI state)
  bool _subhanAllahVibrated = false;
  bool _alhamdulillahVibrated = false;
  bool _allahuAkbarVibrated = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.black),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Daily Adhkar',
          style: TextStyle(
            color: AppColors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress summary
            _buildProgressSummary(),
            const SizedBox(height: 24),
            
            // Tasbih Section
            _buildSectionTitle('Tasbih', Icons.touch_app_outlined),
            const SizedBox(height: 12),
            _buildTasbihCard(),
            const SizedBox(height: 24),
            
            // Adhkar Sections
            _buildSectionTitle('Adhkar', Icons.menu_book_outlined),
            const SizedBox(height: 12),
            _buildAdhkarCard(
              id: 'adhkar_sabah',
              title: 'أذكار الصباح',
              subtitle: 'Morning Adhkar',
              icon: Icons.wb_sunny_outlined,
              recommendedTime: 'After Fajr',
            ),
            const SizedBox(height: 8),
            _buildAdhkarCard(
              id: 'adhkar_salat',
              title: 'أذكار بعد الصلاة',
              subtitle: 'After Prayer Adhkar',
              icon: Icons.mosque_outlined,
              recommendedTime: 'After each prayer',
            ),
            const SizedBox(height: 8),
            _buildAdhkarCard(
              id: 'adhkar_masa',
              title: 'أذكار المساء',
              subtitle: 'Evening Adhkar',
              icon: Icons.nights_stay_outlined,
              recommendedTime: 'After Asr',
            ),
            const SizedBox(height: 8),
            _buildAdhkarCard(
              id: 'adhkar_nawm',
              title: 'أذكار النوم',
              subtitle: 'Before Sleep Adhkar',
              icon: Icons.bedtime_outlined,
              recommendedTime: 'Before sleeping',
            ),
            const SizedBox(height: 24),
            
            // Quran Section
            _buildSectionTitle('Quran', Icons.auto_stories_outlined),
            const SizedBox(height: 12),
            _buildQuranCard(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressSummary() {
    final challenges = ref.watch(dailyChallengesProvider);
    final totalCompleted = challenges.completedChallenges;
    final totalChallenges = challenges.totalChallenges;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.black,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Circular progress
          SizedBox(
            width: 60,
            height: 60,
            child: Stack(
              children: [
                CircularProgressIndicator(
                  value: totalCompleted / totalChallenges,
                  strokeWidth: 6,
                  backgroundColor: AppColors.gray600,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.white),
                ),
                Center(
                  child: Text(
                    '$totalCompleted/$totalChallenges',
                    style: const TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Today\'s Progress',
                  style: TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  totalCompleted == totalChallenges
                      ? 'All challenges complete! 🎉'
                      : '${totalChallenges - totalCompleted} challenges remaining',
                  style: TextStyle(
                    color: AppColors.gray300,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.gray600),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.gray600,
          ),
        ),
      ],
    );
  }

  void _vibrateOnComplete() {
    HapticFeedback.heavyImpact();
    // Double vibration for emphasis
    Future.delayed(const Duration(milliseconds: 100), () {
      HapticFeedback.heavyImpact();
    });
  }

  void _incrementTasbih(String type) {
    final challenges = ref.read(dailyChallengesProvider);
    final notifier = ref.read(dailyChallengesProvider.notifier);
    
    switch (type) {
      case 'subhanallah':
        if (challenges.subhanAllahCount < challenges.subhanAllahTarget) {
          notifier.incrementTasbih('subhanAllah');
          HapticFeedback.lightImpact();
          if (challenges.subhanAllahCount + 1 >= challenges.subhanAllahTarget && !_subhanAllahVibrated) {
            _subhanAllahVibrated = true;
            _vibrateOnComplete();
          }
        }
        break;
      case 'alhamdulillah':
        if (challenges.alhamdulillahCount < challenges.alhamdulillahTarget) {
          notifier.incrementTasbih('alhamdulillah');
          HapticFeedback.lightImpact();
          if (challenges.alhamdulillahCount + 1 >= challenges.alhamdulillahTarget && !_alhamdulillahVibrated) {
            _alhamdulillahVibrated = true;
            _vibrateOnComplete();
          }
        }
        break;
      case 'allahuakbar':
        if (challenges.allahuAkbarCount < challenges.allahuAkbarTarget) {
          notifier.incrementTasbih('allahuAkbar');
          HapticFeedback.lightImpact();
          if (challenges.allahuAkbarCount + 1 >= challenges.allahuAkbarTarget && !_allahuAkbarVibrated) {
            _allahuAkbarVibrated = true;
            _vibrateOnComplete();
          }
        }
        break;
    }
  }

  void _resetTasbih(String type) {
    final notifier = ref.read(dailyChallengesProvider.notifier);
    
    switch (type) {
      case 'subhanallah':
        notifier.resetTasbih('subhanAllah');
        _subhanAllahVibrated = false;
        break;
      case 'alhamdulillah':
        notifier.resetTasbih('alhamdulillah');
        _alhamdulillahVibrated = false;
        break;
      case 'allahuakbar':
        notifier.resetTasbih('allahuAkbar');
        _allahuAkbarVibrated = false;
        break;
    }
    HapticFeedback.mediumImpact();
  }

  void _showTasbihSettings() {
    final challenges = ref.read(dailyChallengesProvider);
    final notifier = ref.read(dailyChallengesProvider.notifier);
    
    // Local state for the modal
    int subhanTarget = challenges.subhanAllahTarget;
    int hamdTarget = challenges.alhamdulillahTarget;
    int akbarTarget = challenges.allahuAkbarTarget;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.gray300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Customize Tasbih Count',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Set custom targets for each dhikr',
                style: TextStyle(
                  color: AppColors.gray500,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 20),
              
              // SubhanAllah target
              _buildTargetRow(
                'سُبْحَانَ اللَّهِ',
                'SubhanAllah',
                subhanTarget,
                (value) {
                  setModalState(() => subhanTarget = value);
                  notifier.setTasbihTargets(subhanAllah: value);
                },
              ),
              const SizedBox(height: 12),
              
              // Alhamdulillah target
              _buildTargetRow(
                'الْحَمْدُ لِلَّهِ',
                'Alhamdulillah',
                hamdTarget,
                (value) {
                  setModalState(() => hamdTarget = value);
                  notifier.setTasbihTargets(alhamdulillah: value);
                },
              ),
              const SizedBox(height: 12),
              
              // AllahuAkbar target
              _buildTargetRow(
                'اللَّهُ أَكْبَرُ',
                'AllahuAkbar',
                akbarTarget,
                (value) {
                  setModalState(() => akbarTarget = value);
                  notifier.setTasbihTargets(allahuAkbar: value);
                },
              ),
              const SizedBox(height: 20),
              
              // Quick presets
              const Text(
                'Quick presets',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                  color: AppColors.gray600,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildPresetButton('33 each', () {
                    setModalState(() {
                      subhanTarget = 33;
                      hamdTarget = 33;
                      akbarTarget = 33;
                    });
                    notifier.setTasbihTargets(subhanAllah: 33, alhamdulillah: 33, allahuAkbar: 33);
                  }),
                  const SizedBox(width: 8),
                  _buildPresetButton('100 each', () {
                    setModalState(() {
                      subhanTarget = 100;
                      hamdTarget = 100;
                      akbarTarget = 100;
                    });
                    notifier.setTasbihTargets(subhanAllah: 100, alhamdulillah: 100, allahuAkbar: 100);
                  }),
                  const SizedBox(width: 8),
                  _buildPresetButton('33-33-34', () {
                    setModalState(() {
                      subhanTarget = 33;
                      hamdTarget = 33;
                      akbarTarget = 34;
                    });
                    notifier.setTasbihTargets(subhanAllah: 33, alhamdulillah: 33, allahuAkbar: 34);
                  }),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTargetRow(String arabic, String name, int currentValue, Function(int) onChanged) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                arabic,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              Text(
                name,
                style: const TextStyle(
                  color: AppColors.gray500,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
        Row(
          children: [
            GestureDetector(
              onTap: () {
                if (currentValue > 1) onChanged(currentValue - 1);
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.gray100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.remove, size: 18),
              ),
            ),
            Container(
              width: 50,
              alignment: Alignment.center,
              child: Text(
                '$currentValue',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                if (currentValue < 1000) onChanged(currentValue + 1);
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.gray100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.add, size: 18),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPresetButton(String label, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.gray100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildTasbihCard() {
    final challenges = ref.watch(dailyChallengesProvider);
    final isComplete = challenges.tasbihCompleted;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isComplete ? AppColors.gray100 : AppColors.gray50,
        borderRadius: BorderRadius.circular(16),
        border: isComplete 
            ? Border.all(color: AppColors.black, width: 2)
            : null,
      ),
      child: Column(
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.touch_app_outlined, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Daily Tasbih',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      'Tap to count • Long press to reset',
                      style: const TextStyle(
                        color: AppColors.gray500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              // Add more tasbihat button
              GestureDetector(
                onTap: _showAddTasbihPicker,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.gray200),
                  ),
                  child: const Icon(Icons.add, size: 20, color: AppColors.gray600),
                ),
              ),
              if (isComplete) ...[
                const SizedBox(width: 8),
                const Icon(Icons.check_circle, color: AppColors.black, size: 24),
              ],
            ],
          ),
          const SizedBox(height: 16),
          
          // Main 3 Tasbih counters
          Row(
            children: [
              Expanded(child: _buildTasbihCounter(
                arabic: 'سُبْحَانَ اللَّهِ',
                transliteration: 'SubhanAllah',
                count: challenges.subhanAllahCount,
                target: challenges.subhanAllahTarget,
                onTap: () => _incrementTasbih('subhanallah'),
                onReset: () => _resetTasbih('subhanallah'),
              )),
              const SizedBox(width: 8),
              Expanded(child: _buildTasbihCounter(
                arabic: 'الْحَمْدُ لِلَّهِ',
                transliteration: 'Alhamdulillah',
                count: challenges.alhamdulillahCount,
                target: challenges.alhamdulillahTarget,
                onTap: () => _incrementTasbih('alhamdulillah'),
                onReset: () => _resetTasbih('alhamdulillah'),
              )),
              const SizedBox(width: 8),
              Expanded(child: _buildTasbihCounter(
                arabic: 'اللَّهُ أَكْبَرُ',
                transliteration: 'AllahuAkbar',
                count: challenges.allahuAkbarCount,
                target: challenges.allahuAkbarTarget,
                onTap: () => _incrementTasbih('allahuakbar'),
                onReset: () => _resetTasbih('allahuakbar'),
              )),
            ],
          ),
          
          // Display extra added tasbihat in rows of 3
          if (challenges.displayedTasbihat.isNotEmpty) ...[
            const SizedBox(height: 12),
            for (int i = 0; i < challenges.displayedTasbihat.length; i += 3)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    for (int j = i; j < i + 3 && j < challenges.displayedTasbihat.length; j++) ...[
                      if (j > i) const SizedBox(width: 8),
                      Expanded(
                        child: _buildExtraTasbihCounter(
                          type: challenges.displayedTasbihat[j],
                          challenges: challenges,
                        ),
                      ),
                    ],
                    // Fill remaining space if less than 3 items in row
                    for (int k = challenges.displayedTasbihat.length; k < i + 3; k++) ...[
                      const SizedBox(width: 8),
                      const Expanded(child: SizedBox()),
                    ],
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }

  // Available extra tasbihat definitions
  static const Map<String, Map<String, String>> _availableTasbihat = {
    'laIlahaIllallah': {
      'arabic': 'لَا إِلٰهَ إِلَّا اللَّهُ',
      'transliteration': 'La ilaha illallah',
      'translation': 'There is no god but Allah',
    },
    'laHawla': {
      'arabic': 'لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ',
      'transliteration': 'La hawla wa la quwwata illa billah',
      'translation': 'No power except with Allah',
    },
    'astaghfirullah': {
      'arabic': 'أَسْتَغْفِرُ اللَّهَ',
      'transliteration': 'Astaghfirullah',
      'translation': 'I seek forgiveness from Allah',
    },
    'salawat': {
      'arabic': 'اللَّهُمَّ صَلِّ عَلَى مُحَمَّدٍ',
      'transliteration': 'Allahumma salli ala Muhammad',
      'translation': 'O Allah, send blessings upon Muhammad',
    },
    'hasbunaAllah': {
      'arabic': 'حَسْبُنَا اللَّهُ وَنِعْمَ الْوَكِيلُ',
      'transliteration': 'Hasbunallahu wa ni\'mal wakeel',
      'translation': 'Allah is sufficient for us',
    },
  };

  int _getTasbihCount(String type, DailyChallenges challenges) {
    switch (type) {
      case 'laIlahaIllallah': return challenges.laIlahaIllallahCount;
      case 'laHawla': return challenges.laHawlaCount;
      case 'astaghfirullah': return challenges.astaghfirullahCount;
      case 'salawat': return challenges.salawatCount;
      case 'hasbunaAllah': return challenges.hasbunaAllahCount;
      default: return 0;
    }
  }

  int _getTasbihTarget(String type, DailyChallenges challenges) {
    switch (type) {
      case 'laIlahaIllallah': return challenges.laIlahaIllallahTarget;
      case 'laHawla': return challenges.laHawlaTarget;
      case 'astaghfirullah': return challenges.astaghfirullahTarget;
      case 'salawat': return challenges.salawatTarget;
      case 'hasbunaAllah': return challenges.hasbunaAllahTarget;
      default: return 33;
    }
  }

  Widget _buildExtraTasbihCounter({
    required String type,
    required DailyChallenges challenges,
  }) {
    final notifier = ref.read(dailyChallengesProvider.notifier);
    final info = _availableTasbihat[type];
    if (info == null) return const SizedBox.shrink();
    
    final count = _getTasbihCount(type, challenges);
    final target = _getTasbihTarget(type, challenges);
    final isComplete = count >= target;
    
    // Same exact UI as _buildTasbihCounter
    return GestureDetector(
      onTap: () => notifier.incrementTasbih(type),
      onLongPress: () => notifier.resetTasbih(type),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
        decoration: BoxDecoration(
          color: isComplete ? AppColors.black : AppColors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: AppColors.gray200.withOpacity(0.5),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              info['arabic']!,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isComplete ? AppColors.white : AppColors.black,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            // Large counter display
            Text(
              '$count',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: isComplete ? AppColors.white : AppColors.black,
              ),
            ),
            Text(
              'of $target',
              style: TextStyle(
                fontSize: 11,
                color: isComplete ? AppColors.gray300 : AppColors.gray500,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              info['transliteration']!,
              style: TextStyle(
                fontSize: 9,
                color: isComplete ? AppColors.gray300 : AppColors.gray500,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (isComplete) ...[
              const SizedBox(height: 4),
              const Icon(Icons.check_circle, color: AppColors.white, size: 18),
            ],
          ],
        ),
      ),
    );
  }

  void _showEditExtraTasbihTarget(String type, int currentTarget, {VoidCallback? onSaved}) {
    final notifier = ref.read(dailyChallengesProvider.notifier);
    int newTarget = currentTarget;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.gray300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Set Target for ${_availableTasbihat[type]?['transliteration'] ?? type}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 24),
              // Counter controls
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      if (newTarget > 1) {
                        newTarget -= 1;
                        setSheetState(() {});
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.gray100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.remove, size: 24),
                    ),
                  ),
                  Container(
                    width: 100,
                    alignment: Alignment.center,
                    child: Text(
                      '$newTarget',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 36,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (newTarget < 1000) {
                        newTarget += 1;
                        setSheetState(() {});
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.gray100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.add, size: 24),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Quick presets
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (final preset in [33, 50, 100])
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: GestureDetector(
                        onTap: () {
                          newTarget = preset;
                          setSheetState(() {});
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: newTarget == preset ? AppColors.black : AppColors.gray100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '$preset',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: newTarget == preset ? AppColors.white : AppColors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 24),
              // Save button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    notifier.setExtraTasbihTarget(type, newTarget);
                    Navigator.pop(context);
                    onSaved?.call();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.black,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Save'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddTasbihPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => StatefulBuilder(
          builder: (context, setSheetState) {
            final challenges = ref.watch(dailyChallengesProvider);
            final notifier = ref.read(dailyChallengesProvider.notifier);
            
            return Column(
              children: [
                // Handle
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.gray300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Manage Tasbihat',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Add, edit targets, or remove dhikr',
                              style: TextStyle(
                                color: AppColors.gray500,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Done'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      // Section: Currently Added
                      if (challenges.displayedTasbihat.isNotEmpty) ...[
                        const Padding(
                          padding: EdgeInsets.only(left: 4, bottom: 8),
                          child: Text(
                            'ADDED TO WIDGET',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.gray500,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                        ...challenges.displayedTasbihat.map((type) {
                          final info = _availableTasbihat[type];
                          if (info == null) return const SizedBox.shrink();
                          final target = _getTasbihTarget(type, challenges);
                          
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.gray100,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.gray200),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          info['arabic']!,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          info['transliteration']!,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AppColors.gray600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Target editor
                                  GestureDetector(
                                    onTap: () => _showEditExtraTasbihTarget(type, target, onSaved: () => setSheetState(() {})),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: AppColors.white,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: AppColors.gray200),
                                      ),
                                      child: Text(
                                        '$target',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  // Remove button
                                  GestureDetector(
                                    onTap: () {
                                      notifier.removeDisplayedTasbih(type);
                                      setSheetState(() {});
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: AppColors.gray200,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(Icons.close, size: 18, color: AppColors.gray600),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                        const SizedBox(height: 16),
                      ],
                      
                      // Section: Available to Add
                      Builder(
                        builder: (context) {
                          final availableTypes = _availableTasbihat.keys
                              .where((type) => !challenges.displayedTasbihat.contains(type))
                              .toList();
                          
                          if (availableTypes.isEmpty) {
                            return const SizedBox.shrink();
                          }
                          
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(left: 4, bottom: 8),
                                child: Text(
                                  'AVAILABLE TO ADD',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.gray500,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                              ...availableTypes.map((type) {
                                final info = _availableTasbihat[type]!;
                                final target = _getTasbihTarget(type, challenges);
                                
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: AppColors.gray50,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: AppColors.gray200),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                info['arabic']!,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                info['transliteration']!,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: AppColors.gray600,
                                                ),
                                              ),
                                              Text(
                                                info['translation']!,
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                  color: AppColors.gray500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        // Target editor before adding
                                        GestureDetector(
                                          onTap: () => _showEditExtraTasbihTarget(type, target, onSaved: () => setSheetState(() {})),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                            decoration: BoxDecoration(
                                              color: AppColors.white,
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border.all(color: AppColors.gray200),
                                            ),
                                            child: Text(
                                              '$target',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        // Add button
                                        GestureDetector(
                                          onTap: () {
                                            notifier.addDisplayedTasbih(type);
                                            setSheetState(() {});
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: AppColors.black,
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: const Icon(Icons.add, color: AppColors.white, size: 20),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showExtraTasbihat() {
    final challenges = ref.read(dailyChallengesProvider);
    final notifier = ref.read(dailyChallengesProvider.notifier);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => StatefulBuilder(
          builder: (context, setLocalState) {
            final currentChallenges = ref.watch(dailyChallengesProvider);
            return Column(
              children: [
                // Handle
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.gray300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'أذكار إضافية',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Extra Adhkar & Tasbihat',
                              style: TextStyle(
                                color: AppColors.gray500,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Done'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      _buildExtraTasbihTile(
                        arabic: 'لَا إِلٰهَ إِلَّا اللَّهُ',
                        transliteration: 'La ilaha illallah',
                        translation: 'There is no god but Allah',
                        count: currentChallenges.laIlahaIllallahCount,
                        target: currentChallenges.laIlahaIllallahTarget,
                        onTap: () => notifier.incrementTasbih('laIlahaIllallah'),
                        onReset: () => notifier.resetTasbih('laIlahaIllallah'),
                        onTargetChange: (t) => notifier.setTasbihTarget('laIlahaIllallah', t),
                      ),
                      const SizedBox(height: 12),
                      _buildExtraTasbihTile(
                        arabic: 'لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ',
                        transliteration: 'La hawla wa la quwwata illa billah',
                        translation: 'There is no power except with Allah',
                        count: currentChallenges.laHawlaCount,
                        target: currentChallenges.laHawlaTarget,
                        onTap: () => notifier.incrementTasbih('laHawla'),
                        onReset: () => notifier.resetTasbih('laHawla'),
                        onTargetChange: (t) => notifier.setTasbihTarget('laHawla', t),
                      ),
                      const SizedBox(height: 12),
                      _buildExtraTasbihTile(
                        arabic: 'أَسْتَغْفِرُ اللَّهَ',
                        transliteration: 'Astaghfirullah',
                        translation: 'I seek forgiveness from Allah',
                        count: currentChallenges.astaghfirullahCount,
                        target: currentChallenges.astaghfirullahTarget,
                        onTap: () => notifier.incrementTasbih('astaghfirullah'),
                        onReset: () => notifier.resetTasbih('astaghfirullah'),
                        onTargetChange: (t) => notifier.setTasbihTarget('astaghfirullah', t),
                      ),
                      const SizedBox(height: 12),
                      _buildExtraTasbihTile(
                        arabic: 'اللَّهُمَّ صَلِّ عَلَى مُحَمَّدٍ',
                        transliteration: 'Allahumma salli \'ala Muhammad',
                        translation: 'O Allah, send blessings upon Muhammad ﷺ',
                        count: currentChallenges.salawatCount,
                        target: currentChallenges.salawatTarget,
                        onTap: () => notifier.incrementTasbih('salawat'),
                        onReset: () => notifier.resetTasbih('salawat'),
                        onTargetChange: (t) => notifier.setTasbihTarget('salawat', t),
                      ),
                      const SizedBox(height: 12),
                      _buildExtraTasbihTile(
                        arabic: 'حَسْبُنَا اللَّهُ وَنِعْمَ الْوَكِيلُ',
                        transliteration: 'Hasbunallahu wa ni\'mal wakeel',
                        translation: 'Allah is sufficient for us',
                        count: currentChallenges.hasbunaAllahCount,
                        target: currentChallenges.hasbunaAllahTarget,
                        onTap: () => notifier.incrementTasbih('hasbunaAllah'),
                        onReset: () => notifier.resetTasbih('hasbunaAllah'),
                        onTargetChange: (t) => notifier.setTasbihTarget('hasbunaAllah', t),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildExtraTasbihTile({
    required String arabic,
    required String transliteration,
    required String translation,
    required int count,
    required int target,
    required VoidCallback onTap,
    required VoidCallback onReset,
    required Function(int) onTargetChange,
  }) {
    final isComplete = count >= target;
    final progress = target > 0 ? (count / target).clamp(0.0, 1.0) : 0.0;
    
    return GestureDetector(
      onTap: onTap,
      onLongPress: onReset,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isComplete ? AppColors.black : AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: isComplete ? null : Border.all(color: AppColors.gray200),
          boxShadow: [
            BoxShadow(
              color: AppColors.gray200.withOpacity(0.5),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        arabic,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: isComplete ? AppColors.white : AppColors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        transliteration,
                        style: TextStyle(
                          fontSize: 12,
                          color: isComplete ? AppColors.gray300 : AppColors.gray600,
                        ),
                      ),
                      Text(
                        translation,
                        style: TextStyle(
                          fontSize: 11,
                          color: isComplete ? AppColors.gray400 : AppColors.gray500,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Text(
                      '$count',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: isComplete ? AppColors.white : AppColors.black,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _showTargetPicker(target, onTargetChange),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: isComplete 
                              ? AppColors.white.withOpacity(0.2)
                              : AppColors.gray100,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '/ $target',
                          style: TextStyle(
                            fontSize: 12,
                            color: isComplete ? AppColors.gray300 : AppColors.gray500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: isComplete 
                    ? AppColors.white.withOpacity(0.2) 
                    : AppColors.gray200,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isComplete ? AppColors.white : AppColors.black,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap to count • Long press to reset',
              style: TextStyle(
                fontSize: 10,
                color: isComplete ? AppColors.gray400 : AppColors.gray400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTargetPicker(int currentTarget, Function(int) onTargetChange) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Set Target',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [33, 50, 100, 200, 500, 1000].map((t) {
                final isSelected = currentTarget == t;
                return GestureDetector(
                  onTap: () {
                    onTargetChange(t);
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.black : AppColors.gray100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$t',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isSelected ? AppColors.white : AppColors.black,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTasbihCounter({
    required String arabic,
    required String transliteration,
    required int count,
    required int target,
    required VoidCallback onTap,
    required VoidCallback onReset,
  }) {
    final isComplete = count >= target;
    
    return GestureDetector(
      onTap: onTap,
      onLongPress: onReset,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
        decoration: BoxDecoration(
          color: isComplete ? AppColors.black : AppColors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: AppColors.gray200.withOpacity(0.5),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              arabic,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isComplete ? AppColors.white : AppColors.black,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            // Large counter display
            Text(
              '$count',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: isComplete ? AppColors.white : AppColors.black,
              ),
            ),
            Text(
              'of $target',
              style: TextStyle(
                fontSize: 11,
                color: isComplete ? AppColors.gray300 : AppColors.gray500,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              transliteration,
              style: TextStyle(
                fontSize: 10,
                color: isComplete ? AppColors.gray300 : AppColors.gray500,
              ),
              textAlign: TextAlign.center,
            ),
            if (isComplete) ...[  
              const SizedBox(height: 4),
              const Icon(Icons.check_circle, color: AppColors.white, size: 18),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildQuranCard() {
    final challenges = ref.watch(dailyChallengesProvider);
    final notifier = ref.read(dailyChallengesProvider.notifier);
    final currentPosition = challenges.currentPosition;
    final dailyTarget = challenges.dailyHizbTarget;
    final completedToday = challenges.hizbsCompletedToday;
    final quranDoneToday = completedToday >= dailyTarget;
    final currentJuz = ((currentPosition - 1) ~/ 2) + 1;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: quranDoneToday ? AppColors.gray100 : AppColors.gray50,
        borderRadius: BorderRadius.circular(16),
        border: quranDoneToday 
            ? Border.all(color: AppColors.black, width: 2)
            : null,
      ),
      child: Column(
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.auto_stories_outlined, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Daily Quran',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      'Juz $currentJuz • Hizb $currentPosition/60',
                      style: const TextStyle(
                        color: AppColors.gray500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              // Target selector
              GestureDetector(
                onTap: () => _showTargetSelector(),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.gray200),
                  ),
                  child: Text(
                    '$dailyTarget hizb/day',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.gray600,
                    ),
                  ),
                ),
              ),
              if (quranDoneToday) ...[
                const SizedBox(width: 8),
                const Icon(Icons.check_circle, color: AppColors.black, size: 24),
              ],
            ],
          ),
          const SizedBox(height: 16),
          
          // Big Quran Button + Counter
          Row(
            children: [
              // Big Read Button
              Expanded(
                flex: 2,
                child: GestureDetector(
                  onTap: () => _showQuranReader(),
                  child: Container(
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.black,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.menu_book, size: 36, color: AppColors.white),
                        SizedBox(height: 8),
                        Text(
                          'Read Quran',
                          style: TextStyle(
                            color: AppColors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Counter
              Expanded(
                flex: 1,
                child: Container(
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.gray200),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$completedToday/$dailyTarget',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        'hizb today',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.gray500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // +/- buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () => notifier.decrementHizb(),
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: AppColors.gray100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.remove, size: 18),
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => notifier.incrementHizb(),
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: AppColors.black,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.add, size: 18, color: AppColors.white),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Stats row (compact)
          Row(
            children: [
              _buildMiniStat(Icons.local_fire_department, '${challenges.quranReadingStreak}', 'streak', AppColors.black),
              const SizedBox(width: 8),
              _buildMiniStat(Icons.check_circle_outline, '${challenges.totalHizbsCompleted}', 'total', AppColors.gray600),
              const SizedBox(width: 8),
              // Position picker
              Expanded(
                child: GestureDetector(
                  onTap: () => _showHizbSelector(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.gray200),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.location_on_outlined, size: 14, color: AppColors.gray500),
                        const SizedBox(width: 4),
                        Text(
                          'حزب $currentPosition',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildMiniStat(IconData icon, String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.gray200),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              value,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildQuranStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Column(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.gray500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuranButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.gray200),
        ),
        child: Icon(icon, size: 20),
      ),
    );
  }

  void _showHizbSelector() {
    final challenges = ref.read(dailyChallengesProvider);
    final notifier = ref.read(dailyChallengesProvider.notifier);
    final currentPosition = challenges.currentPosition;
    final currentJuz = ((currentPosition - 1) ~/ 2) + 1;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        height: 400,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.gray300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Select Position',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Choose your current position in the Quran',
              style: TextStyle(
                color: AppColors.gray500,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 16),
            
            // Juz quick select
            const Text(
              'Quick select by Juz',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 13,
                color: AppColors.gray600,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 30,
                itemBuilder: (context, index) {
                  final juz = index + 1;
                  final isSelected = currentJuz == juz;
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: GestureDetector(
                      onTap: () {
                        notifier.setCurrentPosition((juz - 1) * 2 + 1);
                        Navigator.pop(context);
                      },
                      child: Container(
                        width: 40,
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.black : AppColors.gray100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            '$juz',
                            style: TextStyle(
                              color: isSelected ? AppColors.white : AppColors.black,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            
            // Hizb grid
            const Text(
              'All Hizb',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 13,
                color: AppColors.gray600,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6,
                  crossAxisSpacing: 6,
                  mainAxisSpacing: 6,
                ),
                itemCount: 60,
                itemBuilder: (context, index) {
                  final hizb = index + 1;
                  final isSelected = currentPosition == hizb;
                  final isCompleted = hizb < currentPosition;
                  return GestureDetector(
                    onTap: () {
                      notifier.setCurrentPosition(hizb);
                      Navigator.pop(context);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? AppColors.black 
                            : isCompleted 
                                ? AppColors.gray200 
                                : AppColors.gray50,
                        borderRadius: BorderRadius.circular(8),
                        border: isSelected 
                            ? null 
                            : Border.all(color: AppColors.gray200),
                      ),
                      child: Center(
                        child: Text(
                          '$hizb',
                          style: TextStyle(
                            color: isSelected ? AppColors.white : AppColors.black,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTargetSelector() {
    final challenges = ref.read(dailyChallengesProvider);
    final notifier = ref.read(dailyChallengesProvider.notifier);
    int selectedTarget = challenges.dailyHizbTarget;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) {
          return Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.gray300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Daily Hizb Target',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Set how many hizb you want to read per day',
                  style: TextStyle(
                    color: AppColors.gray500,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Counter controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (selectedTarget > 1) {
                          selectedTarget -= 1;
                          setSheetState(() {});
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.gray100,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.remove, size: 24),
                      ),
                    ),
                    Container(
                      width: 100,
                      alignment: Alignment.center,
                      child: Text(
                        '$selectedTarget',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 40,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        if (selectedTarget < 60) {
                          selectedTarget += 1;
                          setSheetState(() {});
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.gray100,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.add, size: 24),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Center(
                  child: Text(
                    'hizb per day',
                    style: TextStyle(
                      color: AppColors.gray500,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Quick presets
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (final preset in [1, 2, 4, 8])
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: GestureDetector(
                          onTap: () {
                            selectedTarget = preset;
                            setSheetState(() {});
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: selectedTarget == preset ? AppColors.black : AppColors.gray100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '$preset',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: selectedTarget == preset ? AppColors.white : AppColors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                
                // Info text
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.gray50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline, size: 20, color: AppColors.gray500),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          '2 hizb = 1 juz. Reading 2 hizb/day completes Quran in 1 month.',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.gray600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                
                // Save button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      notifier.setDailyHizbTarget(selectedTarget);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.black,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Save'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showQuranReader() {
    final challenges = ref.read(dailyChallengesProvider);
    final currentPosition = challenges.currentPosition;
    final currentJuz = ((currentPosition - 1) ~/ 2) + 1;
    
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _QuranReaderScreen(
          initialJuz: currentJuz,
          initialHizb: currentPosition,
        ),
      ),
    );
  }

  Widget _buildAdhkarCard({
    required String id,
    required String title,
    required String subtitle,
    required IconData icon,
    required String recommendedTime,
  }) {
    final challenges = ref.watch(dailyChallengesProvider);
    
    // Map id to provider state
    bool isComplete;
    switch (id) {
      case 'adhkar_sabah':
        isComplete = challenges.adhkarSabahCompleted;
        break;
      case 'adhkar_salat':
        isComplete = challenges.adhkarSalatCompleted;
        break;
      case 'adhkar_masa':
        isComplete = challenges.adhkarMasaCompleted;
        break;
      case 'adhkar_nawm':
        isComplete = challenges.adhkarNawmCompleted;
        break;
      default:
        isComplete = _completedChallenges[id] ?? false;
    }
    
    return GestureDetector(
      onTap: () {
        _showAdhkarSheet(context, id, title, subtitle, icon);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isComplete ? AppColors.gray100 : AppColors.gray50,
          borderRadius: BorderRadius.circular(14),
          border: isComplete 
              ? Border.all(color: AppColors.black, width: 2)
              : null,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 22, color: AppColors.black),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.gray600,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    recommendedTime,
                    style: const TextStyle(
                      color: AppColors.gray400,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            if (isComplete)
              const Icon(Icons.check_circle, color: AppColors.black, size: 24)
            else
              const Icon(Icons.chevron_right, color: AppColors.gray400, size: 24),
          ],
        ),
      ),
    );
  }

  void _showAdhkarSheet(BuildContext context, String id, String title, String subtitle, IconData icon) {
    final adhkarList = _getAdhkarList(id);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.gray300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(icon, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            color: AppColors.gray500,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // Map id to provider type
                      final notifier = ref.read(dailyChallengesProvider.notifier);
                      switch (id) {
                        case 'adhkar_sabah':
                          notifier.toggleAdhkar('sabah', true);
                          break;
                        case 'adhkar_salat':
                          notifier.toggleAdhkar('salat', true);
                          break;
                        case 'adhkar_masa':
                          notifier.toggleAdhkar('masa', true);
                          break;
                        case 'adhkar_nawm':
                          notifier.toggleAdhkar('nawm', true);
                          break;
                      }
                      _completedChallenges[id] = true;
                      Navigator.pop(context);
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: AppColors.black,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text('Done'),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            
            // Adhkar list
            Expanded(
              child: ListView.separated(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: adhkarList.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final adhkar = adhkarList[index];
                  return _buildAdhkarItem(adhkar);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdhkarItem(Map<String, String> adhkar) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.gray50,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Arabic text
          Text(
            adhkar['arabic'] ?? '',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              height: 1.8,
            ),
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
          ),
          if (adhkar['transliteration'] != null) ...[
            const SizedBox(height: 8),
            Text(
              adhkar['transliteration']!,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.gray600,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          if (adhkar['translation'] != null) ...[
            const SizedBox(height: 6),
            Text(
              adhkar['translation']!,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.gray500,
              ),
            ),
          ],
          if (adhkar['count'] != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.black,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${adhkar['count']}×',
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  List<Map<String, String>> _getAdhkarList(String id) {
    switch (id) {
      case 'adhkar_sabah':
        return [
          {
            'arabic': 'أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلَّهِ، وَالْحَمْدُ لِلَّهِ، لاَ إِلَـهَ إِلاَّ اللهُ وَحْدَهُ لاَ شَرِيكَ لَهُ',
            'transliteration': 'Asbahna wa asbahal-mulku lillah walhamdu lillah la ilaha illallah wahdahu la shareeka lah',
            'translation': 'We have reached the morning and at this very time the kingdom belongs to Allah. All praise is for Allah.',
            'count': '1',
          },
          {
            'arabic': 'اللَّهُمَّ بِكَ أَصْبَحْنَا، وَبِكَ أَمْسَيْنَا، وَبِكَ نَحْيَا، وَبِكَ نَمُوتُ وَإِلَيْكَ النُّشُورُ',
            'transliteration': 'Allahumma bika asbahna, wa bika amsayna, wa bika nahya, wa bika namootu wa ilaykan-nushoor',
            'translation': 'O Allah, by Your leave we have reached the morning and by Your leave we have reached the evening...',
            'count': '1',
          },
          {
            'arabic': 'سُبْحَانَ اللهِ وَبِحَمْدِهِ',
            'transliteration': 'Subhanallahi wa bihamdihi',
            'translation': 'Glory is to Allah and praise is to Him',
            'count': '100',
          },
          {
            'arabic': 'لَا إِلَهَ إِلَّا اللهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ، وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ',
            'transliteration': 'La ilaha illallahu wahdahu la shareeka lah, lahul-mulku wa lahul-hamdu wa huwa ala kulli shay\'in qadeer',
            'translation': 'None has the right to be worshipped except Allah, alone, without partner...',
            'count': '10',
          },
          {
            'arabic': 'أَعُوذُ بِكَلِمَاتِ اللَّهِ التَّامَّاتِ مِنْ شَرِّ مَا خَلَقَ',
            'transliteration': 'A\'udhu bikalimatillahit-tammati min sharri ma khalaq',
            'translation': 'I seek refuge in the perfect words of Allah from the evil of what He has created',
            'count': '3',
          },
        ];
      case 'adhkar_salat':
        return [
          {
            'arabic': 'أَسْتَغْفِرُ اللهَ',
            'transliteration': 'Astaghfirullah',
            'translation': 'I seek forgiveness from Allah',
            'count': '3',
          },
          {
            'arabic': 'اللَّهُمَّ أَنْتَ السَّلاَمُ، وَمِنْكَ السَّلاَمُ، تَبَارَكْتَ يَا ذَا الْجَلاَلِ وَالإِكْرَامِ',
            'transliteration': 'Allahumma antas-salamu wa minkas-salamu, tabarakta ya dhal-jalali wal-ikram',
            'translation': 'O Allah, You are Peace and from You comes peace. Blessed are You, O Owner of majesty and honor.',
            'count': '1',
          },
          {
            'arabic': 'سُبْحَانَ اللَّهِ',
            'transliteration': 'SubhanAllah',
            'translation': 'Glory be to Allah',
            'count': '33',
          },
          {
            'arabic': 'الْحَمْدُ لِلَّهِ',
            'transliteration': 'Alhamdulillah',
            'translation': 'Praise be to Allah',
            'count': '33',
          },
          {
            'arabic': 'اللَّهُ أَكْبَرُ',
            'transliteration': 'Allahu Akbar',
            'translation': 'Allah is the Greatest',
            'count': '33',
          },
          {
            'arabic': 'آيَةُ الْكُرْسِيِّ',
            'transliteration': 'Ayat al-Kursi',
            'translation': 'The Verse of the Throne (Al-Baqarah 2:255)',
            'count': '1',
          },
        ];
      case 'adhkar_masa':
        return [
          {
            'arabic': 'أَمْسَيْنَا وَأَمْسَى الْمُلْكُ لِلَّهِ، وَالْحَمْدُ لِلَّهِ، لاَ إِلَـهَ إِلاَّ اللهُ وَحْدَهُ لاَ شَرِيكَ لَهُ',
            'transliteration': 'Amsayna wa amsal-mulku lillah walhamdu lillah la ilaha illallah wahdahu la shareeka lah',
            'translation': 'We have reached the evening and at this very time the kingdom belongs to Allah.',
            'count': '1',
          },
          {
            'arabic': 'اللَّهُمَّ بِكَ أَمْسَيْنَا، وَبِكَ أَصْبَحْنَا، وَبِكَ نَحْيَا، وَبِكَ نَمُوتُ وَإِلَيْكَ الْمَصِيرُ',
            'transliteration': 'Allahumma bika amsayna, wa bika asbahna, wa bika nahya, wa bika namootu wa ilaykal-maseer',
            'translation': 'O Allah, by Your leave we have reached the evening...',
            'count': '1',
          },
          {
            'arabic': 'سُبْحَانَ اللهِ وَبِحَمْدِهِ',
            'transliteration': 'Subhanallahi wa bihamdihi',
            'translation': 'Glory is to Allah and praise is to Him',
            'count': '100',
          },
          {
            'arabic': 'أَعُوذُ بِكَلِمَاتِ اللَّهِ التَّامَّاتِ مِنْ شَرِّ مَا خَلَقَ',
            'transliteration': 'A\'udhu bikalimatillahit-tammati min sharri ma khalaq',
            'translation': 'I seek refuge in the perfect words of Allah from the evil of what He has created',
            'count': '3',
          },
        ];
      case 'adhkar_nawm':
        return [
          {
            'arabic': 'بِاسْمِكَ اللَّهُمَّ أَمُوتُ وَأَحْيَا',
            'transliteration': 'Bismika Allahumma amootu wa ahya',
            'translation': 'In Your name O Allah, I die and I live',
            'count': '1',
          },
          {
            'arabic': 'اللَّهُمَّ قِنِي عَذَابَكَ يَوْمَ تَبْعَثُ عِبَادَكَ',
            'transliteration': 'Allahumma qini adhabaka yawma tab\'athu ibadak',
            'translation': 'O Allah, protect me from Your punishment on the Day You resurrect Your servants',
            'count': '3',
          },
          {
            'arabic': 'سُبْحَانَ اللَّهِ',
            'transliteration': 'SubhanAllah',
            'translation': 'Glory be to Allah',
            'count': '33',
          },
          {
            'arabic': 'الْحَمْدُ لِلَّهِ',
            'transliteration': 'Alhamdulillah',
            'translation': 'Praise be to Allah',
            'count': '33',
          },
          {
            'arabic': 'اللَّهُ أَكْبَرُ',
            'transliteration': 'Allahu Akbar',
            'translation': 'Allah is the Greatest',
            'count': '34',
          },
          {
            'arabic': 'قُلْ هُوَ اللَّهُ أَحَدٌ - قُلْ أَعُوذُ بِرَبِّ الْفَلَقِ - قُلْ أَعُوذُ بِرَبِّ النَّاسِ',
            'transliteration': 'Al-Ikhlas, Al-Falaq, An-Nas',
            'translation': 'Recite Surah Al-Ikhlas, Al-Falaq, and An-Nas',
            'count': '3× each',
          },
          {
            'arabic': 'آيَةُ الْكُرْسِيِّ',
            'transliteration': 'Ayat al-Kursi',
            'translation': 'The Verse of the Throne (Al-Baqarah 2:255)',
            'count': '1',
          },
        ];
      default:
        return [];
    }
  }
}

// ============ QURAN READER SCREEN ============

class _QuranReaderScreen extends StatefulWidget {
  final int initialJuz;
  final int initialHizb;

  const _QuranReaderScreen({
    required this.initialJuz,
    required this.initialHizb,
  });

  @override
  State<_QuranReaderScreen> createState() => _QuranReaderScreenState();
}

class _QuranReaderScreenState extends State<_QuranReaderScreen> {
  late int _selectedSurah;
  late PageController _pageController;
  
  // Surah list with basic info
  static const List<Map<String, dynamic>> _surahs = [
    {'number': 1, 'name': 'الفاتحة', 'english': 'Al-Fatiha', 'verses': 7, 'type': 'Meccan'},
    {'number': 2, 'name': 'البقرة', 'english': 'Al-Baqara', 'verses': 286, 'type': 'Medinan'},
    {'number': 3, 'name': 'آل عمران', 'english': 'Ali \'Imran', 'verses': 200, 'type': 'Medinan'},
    {'number': 4, 'name': 'النساء', 'english': 'An-Nisa', 'verses': 176, 'type': 'Medinan'},
    {'number': 5, 'name': 'المائدة', 'english': 'Al-Ma\'idah', 'verses': 120, 'type': 'Medinan'},
    {'number': 6, 'name': 'الأنعام', 'english': 'Al-An\'am', 'verses': 165, 'type': 'Meccan'},
    {'number': 7, 'name': 'الأعراف', 'english': 'Al-A\'raf', 'verses': 206, 'type': 'Meccan'},
    {'number': 8, 'name': 'الأنفال', 'english': 'Al-Anfal', 'verses': 75, 'type': 'Medinan'},
    {'number': 9, 'name': 'التوبة', 'english': 'At-Tawba', 'verses': 129, 'type': 'Medinan'},
    {'number': 10, 'name': 'يونس', 'english': 'Yunus', 'verses': 109, 'type': 'Meccan'},
    {'number': 11, 'name': 'هود', 'english': 'Hud', 'verses': 123, 'type': 'Meccan'},
    {'number': 12, 'name': 'يوسف', 'english': 'Yusuf', 'verses': 111, 'type': 'Meccan'},
    {'number': 13, 'name': 'الرعد', 'english': 'Ar-Ra\'d', 'verses': 43, 'type': 'Medinan'},
    {'number': 14, 'name': 'إبراهيم', 'english': 'Ibrahim', 'verses': 52, 'type': 'Meccan'},
    {'number': 15, 'name': 'الحجر', 'english': 'Al-Hijr', 'verses': 99, 'type': 'Meccan'},
    {'number': 16, 'name': 'النحل', 'english': 'An-Nahl', 'verses': 128, 'type': 'Meccan'},
    {'number': 17, 'name': 'الإسراء', 'english': 'Al-Isra', 'verses': 111, 'type': 'Meccan'},
    {'number': 18, 'name': 'الكهف', 'english': 'Al-Kahf', 'verses': 110, 'type': 'Meccan'},
    {'number': 19, 'name': 'مريم', 'english': 'Maryam', 'verses': 98, 'type': 'Meccan'},
    {'number': 20, 'name': 'طه', 'english': 'Ta-Ha', 'verses': 135, 'type': 'Meccan'},
    {'number': 21, 'name': 'الأنبياء', 'english': 'Al-Anbiya', 'verses': 112, 'type': 'Meccan'},
    {'number': 22, 'name': 'الحج', 'english': 'Al-Hajj', 'verses': 78, 'type': 'Medinan'},
    {'number': 23, 'name': 'المؤمنون', 'english': 'Al-Mu\'minun', 'verses': 118, 'type': 'Meccan'},
    {'number': 24, 'name': 'النور', 'english': 'An-Nur', 'verses': 64, 'type': 'Medinan'},
    {'number': 25, 'name': 'الفرقان', 'english': 'Al-Furqan', 'verses': 77, 'type': 'Meccan'},
    {'number': 26, 'name': 'الشعراء', 'english': 'Ash-Shu\'ara', 'verses': 227, 'type': 'Meccan'},
    {'number': 27, 'name': 'النمل', 'english': 'An-Naml', 'verses': 93, 'type': 'Meccan'},
    {'number': 28, 'name': 'القصص', 'english': 'Al-Qasas', 'verses': 88, 'type': 'Meccan'},
    {'number': 29, 'name': 'العنكبوت', 'english': 'Al-Ankabut', 'verses': 69, 'type': 'Meccan'},
    {'number': 30, 'name': 'الروم', 'english': 'Ar-Rum', 'verses': 60, 'type': 'Meccan'},
    {'number': 31, 'name': 'لقمان', 'english': 'Luqman', 'verses': 34, 'type': 'Meccan'},
    {'number': 32, 'name': 'السجدة', 'english': 'As-Sajda', 'verses': 30, 'type': 'Meccan'},
    {'number': 33, 'name': 'الأحزاب', 'english': 'Al-Ahzab', 'verses': 73, 'type': 'Medinan'},
    {'number': 34, 'name': 'سبأ', 'english': 'Saba', 'verses': 54, 'type': 'Meccan'},
    {'number': 35, 'name': 'فاطر', 'english': 'Fatir', 'verses': 45, 'type': 'Meccan'},
    {'number': 36, 'name': 'يس', 'english': 'Ya-Sin', 'verses': 83, 'type': 'Meccan'},
    {'number': 37, 'name': 'الصافات', 'english': 'As-Saffat', 'verses': 182, 'type': 'Meccan'},
    {'number': 38, 'name': 'ص', 'english': 'Sad', 'verses': 88, 'type': 'Meccan'},
    {'number': 39, 'name': 'الزمر', 'english': 'Az-Zumar', 'verses': 75, 'type': 'Meccan'},
    {'number': 40, 'name': 'غافر', 'english': 'Ghafir', 'verses': 85, 'type': 'Meccan'},
    {'number': 41, 'name': 'فصلت', 'english': 'Fussilat', 'verses': 54, 'type': 'Meccan'},
    {'number': 42, 'name': 'الشورى', 'english': 'Ash-Shura', 'verses': 53, 'type': 'Meccan'},
    {'number': 43, 'name': 'الزخرف', 'english': 'Az-Zukhruf', 'verses': 89, 'type': 'Meccan'},
    {'number': 44, 'name': 'الدخان', 'english': 'Ad-Dukhan', 'verses': 59, 'type': 'Meccan'},
    {'number': 45, 'name': 'الجاثية', 'english': 'Al-Jathiya', 'verses': 37, 'type': 'Meccan'},
    {'number': 46, 'name': 'الأحقاف', 'english': 'Al-Ahqaf', 'verses': 35, 'type': 'Meccan'},
    {'number': 47, 'name': 'محمد', 'english': 'Muhammad', 'verses': 38, 'type': 'Medinan'},
    {'number': 48, 'name': 'الفتح', 'english': 'Al-Fath', 'verses': 29, 'type': 'Medinan'},
    {'number': 49, 'name': 'الحجرات', 'english': 'Al-Hujurat', 'verses': 18, 'type': 'Medinan'},
    {'number': 50, 'name': 'ق', 'english': 'Qaf', 'verses': 45, 'type': 'Meccan'},
    {'number': 51, 'name': 'الذاريات', 'english': 'Adh-Dhariyat', 'verses': 60, 'type': 'Meccan'},
    {'number': 52, 'name': 'الطور', 'english': 'At-Tur', 'verses': 49, 'type': 'Meccan'},
    {'number': 53, 'name': 'النجم', 'english': 'An-Najm', 'verses': 62, 'type': 'Meccan'},
    {'number': 54, 'name': 'القمر', 'english': 'Al-Qamar', 'verses': 55, 'type': 'Meccan'},
    {'number': 55, 'name': 'الرحمن', 'english': 'Ar-Rahman', 'verses': 78, 'type': 'Medinan'},
    {'number': 56, 'name': 'الواقعة', 'english': 'Al-Waqi\'a', 'verses': 96, 'type': 'Meccan'},
    {'number': 57, 'name': 'الحديد', 'english': 'Al-Hadid', 'verses': 29, 'type': 'Medinan'},
    {'number': 58, 'name': 'المجادلة', 'english': 'Al-Mujadila', 'verses': 22, 'type': 'Medinan'},
    {'number': 59, 'name': 'الحشر', 'english': 'Al-Hashr', 'verses': 24, 'type': 'Medinan'},
    {'number': 60, 'name': 'الممتحنة', 'english': 'Al-Mumtahina', 'verses': 13, 'type': 'Medinan'},
    {'number': 61, 'name': 'الصف', 'english': 'As-Saff', 'verses': 14, 'type': 'Medinan'},
    {'number': 62, 'name': 'الجمعة', 'english': 'Al-Jumu\'a', 'verses': 11, 'type': 'Medinan'},
    {'number': 63, 'name': 'المنافقون', 'english': 'Al-Munafiqun', 'verses': 11, 'type': 'Medinan'},
    {'number': 64, 'name': 'التغابن', 'english': 'At-Taghabun', 'verses': 18, 'type': 'Medinan'},
    {'number': 65, 'name': 'الطلاق', 'english': 'At-Talaq', 'verses': 12, 'type': 'Medinan'},
    {'number': 66, 'name': 'التحريم', 'english': 'At-Tahrim', 'verses': 12, 'type': 'Medinan'},
    {'number': 67, 'name': 'الملك', 'english': 'Al-Mulk', 'verses': 30, 'type': 'Meccan'},
    {'number': 68, 'name': 'القلم', 'english': 'Al-Qalam', 'verses': 52, 'type': 'Meccan'},
    {'number': 69, 'name': 'الحاقة', 'english': 'Al-Haqqa', 'verses': 52, 'type': 'Meccan'},
    {'number': 70, 'name': 'المعارج', 'english': 'Al-Ma\'arij', 'verses': 44, 'type': 'Meccan'},
    {'number': 71, 'name': 'نوح', 'english': 'Nuh', 'verses': 28, 'type': 'Meccan'},
    {'number': 72, 'name': 'الجن', 'english': 'Al-Jinn', 'verses': 28, 'type': 'Meccan'},
    {'number': 73, 'name': 'المزمل', 'english': 'Al-Muzzammil', 'verses': 20, 'type': 'Meccan'},
    {'number': 74, 'name': 'المدثر', 'english': 'Al-Muddathir', 'verses': 56, 'type': 'Meccan'},
    {'number': 75, 'name': 'القيامة', 'english': 'Al-Qiyama', 'verses': 40, 'type': 'Meccan'},
    {'number': 76, 'name': 'الإنسان', 'english': 'Al-Insan', 'verses': 31, 'type': 'Medinan'},
    {'number': 77, 'name': 'المرسلات', 'english': 'Al-Mursalat', 'verses': 50, 'type': 'Meccan'},
    {'number': 78, 'name': 'النبأ', 'english': 'An-Naba', 'verses': 40, 'type': 'Meccan'},
    {'number': 79, 'name': 'النازعات', 'english': 'An-Nazi\'at', 'verses': 46, 'type': 'Meccan'},
    {'number': 80, 'name': 'عبس', 'english': 'Abasa', 'verses': 42, 'type': 'Meccan'},
    {'number': 81, 'name': 'التكوير', 'english': 'At-Takwir', 'verses': 29, 'type': 'Meccan'},
    {'number': 82, 'name': 'الانفطار', 'english': 'Al-Infitar', 'verses': 19, 'type': 'Meccan'},
    {'number': 83, 'name': 'المطففين', 'english': 'Al-Mutaffifin', 'verses': 36, 'type': 'Meccan'},
    {'number': 84, 'name': 'الانشقاق', 'english': 'Al-Inshiqaq', 'verses': 25, 'type': 'Meccan'},
    {'number': 85, 'name': 'البروج', 'english': 'Al-Buruj', 'verses': 22, 'type': 'Meccan'},
    {'number': 86, 'name': 'الطارق', 'english': 'At-Tariq', 'verses': 17, 'type': 'Meccan'},
    {'number': 87, 'name': 'الأعلى', 'english': 'Al-A\'la', 'verses': 19, 'type': 'Meccan'},
    {'number': 88, 'name': 'الغاشية', 'english': 'Al-Ghashiya', 'verses': 26, 'type': 'Meccan'},
    {'number': 89, 'name': 'الفجر', 'english': 'Al-Fajr', 'verses': 30, 'type': 'Meccan'},
    {'number': 90, 'name': 'البلد', 'english': 'Al-Balad', 'verses': 20, 'type': 'Meccan'},
    {'number': 91, 'name': 'الشمس', 'english': 'Ash-Shams', 'verses': 15, 'type': 'Meccan'},
    {'number': 92, 'name': 'الليل', 'english': 'Al-Layl', 'verses': 21, 'type': 'Meccan'},
    {'number': 93, 'name': 'الضحى', 'english': 'Ad-Duha', 'verses': 11, 'type': 'Meccan'},
    {'number': 94, 'name': 'الشرح', 'english': 'Ash-Sharh', 'verses': 8, 'type': 'Meccan'},
    {'number': 95, 'name': 'التين', 'english': 'At-Tin', 'verses': 8, 'type': 'Meccan'},
    {'number': 96, 'name': 'العلق', 'english': 'Al-Alaq', 'verses': 19, 'type': 'Meccan'},
    {'number': 97, 'name': 'القدر', 'english': 'Al-Qadr', 'verses': 5, 'type': 'Meccan'},
    {'number': 98, 'name': 'البينة', 'english': 'Al-Bayyina', 'verses': 8, 'type': 'Medinan'},
    {'number': 99, 'name': 'الزلزلة', 'english': 'Az-Zalzala', 'verses': 8, 'type': 'Medinan'},
    {'number': 100, 'name': 'العاديات', 'english': 'Al-Adiyat', 'verses': 11, 'type': 'Meccan'},
    {'number': 101, 'name': 'القارعة', 'english': 'Al-Qari\'a', 'verses': 11, 'type': 'Meccan'},
    {'number': 102, 'name': 'التكاثر', 'english': 'At-Takathur', 'verses': 8, 'type': 'Meccan'},
    {'number': 103, 'name': 'العصر', 'english': 'Al-Asr', 'verses': 3, 'type': 'Meccan'},
    {'number': 104, 'name': 'الهمزة', 'english': 'Al-Humaza', 'verses': 9, 'type': 'Meccan'},
    {'number': 105, 'name': 'الفيل', 'english': 'Al-Fil', 'verses': 5, 'type': 'Meccan'},
    {'number': 106, 'name': 'قريش', 'english': 'Quraysh', 'verses': 4, 'type': 'Meccan'},
    {'number': 107, 'name': 'الماعون', 'english': 'Al-Ma\'un', 'verses': 7, 'type': 'Meccan'},
    {'number': 108, 'name': 'الكوثر', 'english': 'Al-Kawthar', 'verses': 3, 'type': 'Meccan'},
    {'number': 109, 'name': 'الكافرون', 'english': 'Al-Kafirun', 'verses': 6, 'type': 'Meccan'},
    {'number': 110, 'name': 'النصر', 'english': 'An-Nasr', 'verses': 3, 'type': 'Medinan'},
    {'number': 111, 'name': 'المسد', 'english': 'Al-Masad', 'verses': 5, 'type': 'Meccan'},
    {'number': 112, 'name': 'الإخلاص', 'english': 'Al-Ikhlas', 'verses': 4, 'type': 'Meccan'},
    {'number': 113, 'name': 'الفلق', 'english': 'Al-Falaq', 'verses': 5, 'type': 'Meccan'},
    {'number': 114, 'name': 'الناس', 'english': 'An-Nas', 'verses': 6, 'type': 'Meccan'},
  ];

  @override
  void initState() {
    super.initState();
    _selectedSurah = 1;
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Quran Reader',
          style: TextStyle(
            color: AppColors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_outline, color: AppColors.black),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Bookmark saved'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Ayah: When you recite the Quran, seek refuge in Allah
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            color: AppColors.gray50,
            child: Column(
              children: [
                const Text(
                  'وَإِذَا قَرَأْتَ الْقُرْآنَ فَاسْتَعِذْ بِاللَّهِ مِنَ الشَّيْطَانِ الرَّجِيمِ',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    height: 1.8,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  'When you recite the Quran, seek refuge in Allah from Satan',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.gray500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.auto_stories_outlined, size: 14, color: AppColors.gray600),
                    const SizedBox(width: 6),
                    Text(
                      'Juz ${widget.initialJuz} • Hizb ${widget.initialHizb}',
                      style: const TextStyle(
                        color: AppColors.gray600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Surah list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _surahs.length,
              itemBuilder: (context, index) {
                final surah = _surahs[index];
                return _buildSurahItem(surah);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSurahItem(Map<String, dynamic> surah) {
    return GestureDetector(
      onTap: () {
        _openSurahReader(surah);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.gray50,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Surah number
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  '${surah['number']}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            
            // Surah info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    surah['english'],
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    '${surah['verses']} verses • ${surah['type']}',
                    style: const TextStyle(
                      color: AppColors.gray500,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            
            // Arabic name
            Text(
              surah['name'],
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openSurahReader(Map<String, dynamic> surah) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _SurahReaderSheet(
        surah: surah,
        onClose: () {
          Navigator.pop(context);
        },
      ),
    );
  }
}

/// Stateful widget for reading Surah with API-fetched verses
class _SurahReaderSheet extends StatefulWidget {
  final Map<String, dynamic> surah;
  final VoidCallback onClose;

  const _SurahReaderSheet({
    required this.surah,
    required this.onClose,
  });

  @override
  State<_SurahReaderSheet> createState() => _SurahReaderSheetState();
}

class _SurahReaderSheetState extends State<_SurahReaderSheet> {
  List<Map<String, dynamic>> _verses = [];
  bool _isLoading = true;
  String? _error;
  double _fontSize = 28;

  @override
  void initState() {
    super.initState();
    _fetchVerses();
  }

  Future<void> _fetchVerses() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    
    try {
      // Use edition parameter for Arabic text only
      final url = 'https://api.alquran.cloud/v1/surah/${widget.surah['number']}/ar.alafasy';
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 20));

      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['data'] != null && data['data']['ayahs'] != null) {
          final ayahs = data['data']['ayahs'] as List;
          
          if (mounted) {
            setState(() {
              _verses = ayahs.map((a) => {
                'number': a['numberInSurah'] as int,
                'text': a['text'] as String,
              }).toList();
              _isLoading = false;
            });
          }
        } else {
          if (mounted) {
            setState(() {
              _error = 'Invalid API response format';
              _isLoading = false;
            });
          }
        }
      } else {
        if (mounted) {
          setState(() {
            _error = 'Failed to load (${response.statusCode})';
            _isLoading = false;
          });
        }
      }
    } on http.ClientException catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Connection failed. Please check your internet.';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Network error. Tap to retry.';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) => Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.gray300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.gray100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${widget.surah['number']}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.surah['english'],
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        '${widget.surah['name']} • ${widget.surah['verses']} verses',
                        style: const TextStyle(
                          color: AppColors.gray500,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: widget.onClose,
                  style: TextButton.styleFrom(
                    backgroundColor: AppColors.black,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(context.l10n.close),
                ),
              ],
            ),
          ),
          
          // Font size controls
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () => setState(() => _fontSize = (_fontSize - 2).clamp(20, 40)),
                  icon: const Icon(Icons.text_decrease, size: 20),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.gray100,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    '${_fontSize.toInt()}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => setState(() => _fontSize = (_fontSize + 2).clamp(20, 40)),
                  icon: const Icon(Icons.text_increase, size: 20),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.gray100,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 8),
          const Divider(height: 1),
          
          // Quran content
          Expanded(
            child: _isLoading
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          color: AppColors.black,
                          strokeWidth: 2,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Loading verses...',
                          style: TextStyle(
                            color: AppColors.gray500,
                          ),
                        ),
                      ],
                    ),
                  )
                : _error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 48,
                              color: AppColors.gray400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _error!,
                              style: TextStyle(color: AppColors.gray500),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            OutlinedButton(
                              onPressed: () {
                                setState(() {
                                  _isLoading = true;
                                  _error = null;
                                });
                                _fetchVerses();
                              },
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : SingleChildScrollView(
                        controller: scrollController,
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            // Bismillah (except Surah 9 - At-Tawbah)
                            if (widget.surah['number'] != 9)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 24),
                                child: Text(
                                  'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                                  style: TextStyle(
                                    fontSize: _fontSize + 2,
                                    fontWeight: FontWeight.w500,
                                    height: 2,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            
                            // Verses in flowing text format
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.gray50,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Directionality(
                                textDirection: TextDirection.rtl,
                                child: Wrap(
                                  alignment: WrapAlignment.center,
                                  children: _verses.map((verse) {
                                    // Skip first verse of Al-Fatiha (it's Bismillah)
                                    if (widget.surah['number'] == 1 && verse['number'] == 1) {
                                      return const SizedBox.shrink();
                                    }
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 4),
                                      child: RichText(
                                        textAlign: TextAlign.center,
                                        text: TextSpan(
                                          style: TextStyle(
                                            fontSize: _fontSize,
                                            color: AppColors.black,
                                            height: 2.2,
                                            fontFamily: 'System',
                                          ),
                                          children: [
                                            TextSpan(text: '${verse['text']} '),
                                            TextSpan(
                                              text: '﴿${_toArabicNumber(verse['number'])}﴾ ',
                                              style: TextStyle(
                                                fontSize: _fontSize - 6,
                                                color: AppColors.gray400,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                            
                            const SizedBox(height: 24),
                            
                            // Close button at bottom
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: widget.onClose,
                                icon: const Icon(Icons.check_circle_outline),
                                label: Text(context.l10n.doneReading),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.black,
                                  foregroundColor: AppColors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                            
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  String _toArabicNumber(int number) {
    const arabicNumbers = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return number.toString().split('').map((d) => arabicNumbers[int.parse(d)]).join();
  }
}
