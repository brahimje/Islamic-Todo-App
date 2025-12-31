import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/router/app_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../data/services/location_service.dart';
import '../../../data/services/prayer_time_service.dart';
import '../../../data/services/free_time_service.dart';
import '../../../domain/providers/settings_provider.dart';
import '../../../domain/providers/prayer_provider.dart';
import '../../../domain/providers/free_time_provider.dart';
import '../../../domain/providers/backup_provider.dart';

/// Settings screen
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final locationInfo = ref.watch(locationInfoProvider);
    final prayerTimeSettings = ref.watch(prayerTimeSettingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(
          vertical: AppDimensions.screenPaddingVertical,
        ),
        children: [
          // Prayer Preparation Section
          _buildSection(
            context,
            title: 'Prayer Preparation',
            children: [
              _buildSectionDescription(
                context,
                'Set your preparation time for each prayer (includes wudu, travel to mosque if needed, etc.)',
              ),
              ...['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'].map((prayer) => 
                _SettingsSlider(
                  icon: _getPrayerIcon(prayer),
                  title: prayer,
                  value: prayerTimeSettings.preparationTimes[prayer] ?? 15,
                  min: 5,
                  max: 45,
                  suffix: 'min',
                  onChanged: (value) {
                    ref.read(prayerTimeSettingsProvider.notifier)
                        .setPreparationTime(prayer, value);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingMd),
          
          // Sleep & Qiyam Section
          _buildSection(
            context,
            title: 'Sleep & Qiyam al-Layl',
            children: [
              _SleepTimePicker(
                sleepHour: prayerTimeSettings.sleepHour,
                sleepMinute: prayerTimeSettings.sleepMinute,
                onChanged: (hour, minute) {
                  ref.read(prayerTimeSettingsProvider.notifier).setSleepTime(hour, minute);
                },
              ),
              _QiyamToggle(
                isEnabled: prayerTimeSettings.enableQiyam,
                onChanged: (value) {
                  ref.read(prayerTimeSettingsProvider.notifier).toggleQiyam();
                },
              ),
              if (prayerTimeSettings.enableQiyam) ...[
                _QiyamWakeTimeSelector(ref: ref),
                if (prayerTimeSettings.qiyamWakeOption == QiyamWakeTimeOption.custom)
                  _SettingsSlider(
                    icon: Icons.timer,
                    title: 'Minutes Before Fajr',
                    value: prayerTimeSettings.qiyamCustomMinutes,
                    min: 15,
                    max: 180,
                    suffix: 'min',
                    onChanged: (value) {
                      ref.read(prayerTimeSettingsProvider.notifier)
                          .setQiyamCustomMinutes(value);
                    },
                  ),
              ],
            ],
          ),
          const SizedBox(height: AppDimensions.spacingMd),
          _buildSection(
            context,
            title: 'Prayer Settings',
            children: [
              _SettingsTile(
                icon: Icons.location_on_outlined,
                title: 'Location',
                subtitle: locationInfo.displayName,
                onTap: () => _showLocationPicker(context, ref),
              ),
              _SettingsTile(
                icon: Icons.calculate_outlined,
                title: 'Calculation Method',
                subtitle: PrayerTimeService.getCalculationMethodName(settings.calculationMethod),
                onTap: () => _showCalculationMethodPicker(context, ref),
              ),
              _SettingsTile(
                icon: Icons.mosque_outlined,
                title: 'Madhab',
                subtitle: settings.madhab == 0 ? "Shafi'i (Standard Asr)" : "Hanafi (Later Asr)",
                onTap: () => _showMadhabPicker(context, ref),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingMd),
          _buildSection(
            context,
            title: 'Reminders',
            children: [
              _SettingsSwitch(
                icon: Icons.notifications_outlined,
                title: 'Enable Notifications',
                value: settings.notificationsEnabled,
                onChanged: (value) {
                  ref.read(settingsProvider.notifier).updateNotificationsEnabled(value);
                },
              ),
              if (settings.notificationsEnabled) ...[
                // Prayer Reminders
                _buildSubsectionHeader(context, 'Prayer'),
                _SettingsTile(
                  icon: Icons.timer_outlined,
                  title: 'Reminder Time',
                  subtitle: '${settings.defaultReminderMinutes} min before prayer',
                  onTap: () => _showReminderTimePicker(context, ref),
                ),
                _SettingsSwitch(
                  icon: Icons.brightness_5_outlined,
                  title: 'Nafila Reminders',
                  value: settings.showNafilaReminders,
                  onChanged: (value) {
                    ref.read(settingsProvider.notifier).saveSettings(
                      settings.copyWith(showNafilaReminders: value),
                    );
                  },
                ),
                
                // Adhkar Reminders
                _buildSubsectionHeader(context, 'Adhkar'),
                _SettingsSwitch(
                  icon: Icons.wb_sunny_outlined,
                  title: 'Morning Adhkar',
                  value: settings.showMorningAdhkarReminder,
                  onChanged: (value) {
                    ref.read(settingsProvider.notifier).saveSettings(
                      settings.copyWith(showMorningAdhkarReminder: value),
                    );
                  },
                ),
                if (settings.showMorningAdhkarReminder)
                  _SettingsTile(
                    icon: Icons.schedule_outlined,
                    title: 'Morning Time',
                    subtitle: _formatHour(settings.morningAdhkarHour, settings.use24HourFormat),
                    onTap: () => _showAdhkarTimePicker(context, ref, true),
                  ),
                _SettingsSwitch(
                  icon: Icons.nights_stay_outlined,
                  title: 'Evening Adhkar',
                  value: settings.showEveningAdhkarReminder,
                  onChanged: (value) {
                    ref.read(settingsProvider.notifier).saveSettings(
                      settings.copyWith(showEveningAdhkarReminder: value),
                    );
                  },
                ),
                if (settings.showEveningAdhkarReminder)
                  _SettingsTile(
                    icon: Icons.schedule_outlined,
                    title: 'Evening Time',
                    subtitle: _formatHour(settings.eveningAdhkarHour, settings.use24HourFormat),
                    onTap: () => _showAdhkarTimePicker(context, ref, false),
                  ),
                _SettingsSwitch(
                  icon: Icons.mosque_outlined,
                  title: 'After Prayer Adhkar',
                  value: settings.showAfterPrayerAdhkarReminder,
                  onChanged: (value) {
                    ref.read(settingsProvider.notifier).saveSettings(
                      settings.copyWith(showAfterPrayerAdhkarReminder: value),
                    );
                  },
                ),
                _SettingsSwitch(
                  icon: Icons.bedtime_outlined,
                  title: 'Sleep Adhkar',
                  value: settings.showSleepAdhkarReminder,
                  onChanged: (value) {
                    ref.read(settingsProvider.notifier).saveSettings(
                      settings.copyWith(showSleepAdhkarReminder: value),
                    );
                  },
                ),
                
                // Task Reminders
                _buildSubsectionHeader(context, 'Tasks'),
                _SettingsSwitch(
                  icon: Icons.task_alt_outlined,
                  title: 'Task Reminders',
                  value: settings.showTaskReminders,
                  onChanged: (value) {
                    ref.read(settingsProvider.notifier).saveSettings(
                      settings.copyWith(showTaskReminders: value),
                    );
                  },
                ),
              ],
            ],
          ),
          const SizedBox(height: AppDimensions.spacingMd),
          _buildSection(
            context,
            title: 'Preferences',
            children: [
              _SettingsSwitch(
                icon: Icons.access_time,
                title: '24-Hour Format',
                value: settings.use24HourFormat,
                onChanged: (value) {
                  ref.read(settingsProvider.notifier).saveSettings(
                    settings.copyWith(use24HourFormat: value),
                  );
                },
              ),
              _SettingsSwitch(
                icon: Icons.check_circle_outline,
                title: 'Show Completed Tasks',
                value: settings.showCompletedTasks,
                onChanged: (value) {
                  ref.read(settingsProvider.notifier).saveSettings(
                    settings.copyWith(showCompletedTasks: value),
                  );
                },
              ),
              _SettingsTile(
                icon: Icons.calendar_today_outlined,
                title: 'Week Starts On',
                subtitle: settings.weekStartDay == 1 ? 'Monday' : 'Sunday',
                onTap: () => _showWeekStartPicker(context, ref),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingMd),
          _buildSection(
            context,
            title: 'Data',
            children: [
              _SettingsTile(
                icon: Icons.backup_outlined,
                title: 'Backup Data',
                subtitle: 'Export your data to a file',
                onTap: () => _showBackupDialog(context, ref),
              ),
              _SettingsTile(
                icon: Icons.restore_outlined,
                title: 'Restore Data',
                subtitle: 'Import data from a backup file',
                onTap: () => _showRestoreDialog(context, ref),
              ),
              _SettingsTile(
                icon: Icons.delete_outline,
                title: 'Clear All Data',
                textColor: AppColors.error,
                onTap: () => _showClearDataConfirmation(context, ref),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingMd),
          _buildSection(
            context,
            title: 'About',
            children: [
              _SettingsTile(
                icon: Icons.info_outline,
                title: 'Version',
                subtitle: '1.0.0',
                showArrow: false,
                onTap: () {},
              ),
              _SettingsTile(
                icon: Icons.explore_outlined,
                title: 'Qibla Direction',
                subtitle: _formatQiblaDirection(ref),
                showArrow: false,
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingXl),
        ],
      ),
    );
  }

  IconData _getPrayerIcon(String prayer) {
    switch (prayer) {
      case 'Fajr':
        return Icons.wb_twilight;
      case 'Dhuhr':
        return Icons.wb_sunny;
      case 'Asr':
        return Icons.sunny_snowing;
      case 'Maghrib':
        return Icons.nightlight_round;
      case 'Isha':
        return Icons.nights_stay;
      default:
        return Icons.mosque;
    }
  }

  Widget _buildSectionDescription(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.paddingMd,
        AppDimensions.paddingSm,
        AppDimensions.paddingMd,
        AppDimensions.paddingMd,
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: AppColors.gray500,
        ),
      ),
    );
  }

  Widget _buildSubsectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.paddingMd,
        AppDimensions.paddingMd,
        AppDimensions.paddingMd,
        AppDimensions.paddingXs,
      ),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: AppColors.gray600,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  String _formatHour(int hour, bool use24Hour) {
    if (use24Hour) {
      return '${hour.toString().padLeft(2, '0')}:00';
    }
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:00 $period';
  }

  void _showAdhkarTimePicker(BuildContext context, WidgetRef ref, bool isMorning) {
    final settings = ref.read(settingsProvider);
    final currentHour = isMorning ? settings.morningAdhkarHour : settings.eveningAdhkarHour;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingLg),
              child: Text(
                isMorning ? 'Morning Adhkar Time' : 'Evening Adhkar Time',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Divider(height: 1),
            SizedBox(
              height: 200,
              child: ListView.builder(
                itemCount: isMorning ? 12 : 12, // Morning: 4-12, Evening: 12-24
                itemBuilder: (context, index) {
                  final hour = isMorning ? (index + 4) : (index + 12); // Morning 4AM-3PM, Evening 12PM-11PM
                  if (isMorning && hour > 11) return const SizedBox.shrink();
                  if (!isMorning && hour > 23) return const SizedBox.shrink();
                  
                  final isSelected = hour == currentHour;
                  return ListTile(
                    title: Text(_formatHour(hour, settings.use24HourFormat)),
                    trailing: isSelected
                        ? const Icon(Icons.check, color: AppColors.black)
                        : null,
                    onTap: () {
                      if (isMorning) {
                        ref.read(settingsProvider.notifier).saveSettings(
                          settings.copyWith(morningAdhkarHour: hour),
                        );
                      } else {
                        ref.read(settingsProvider.notifier).saveSettings(
                          settings.copyWith(eveningAdhkarHour: hour),
                        );
                      }
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatQiblaDirection(WidgetRef ref) {
    final direction = ref.watch(qiblaDirectionProvider);
    return '${direction.toStringAsFixed(1)}° from North';
  }

  void _showLocationPicker(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _LocationPickerSheet(ref: ref),
    );
  }

  void _showCalculationMethodPicker(BuildContext context, WidgetRef ref) {
    final settings = ref.read(settingsProvider);
    final methods = PrayerTimeService.getCalculationMethods();

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingLg),
              child: Text(
                'Calculation Method',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            const Divider(height: 1),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: methods.length,
                itemBuilder: (context, index) {
                  final method = methods[index];
                  final isSelected = method.index == settings.calculationMethod;
                  return ListTile(
                    title: Text(method.name),
                    subtitle: Text(method.region),
                    trailing: isSelected
                        ? const Icon(Icons.check, color: AppColors.black)
                        : null,
                    onTap: () {
                      ref.read(settingsProvider.notifier).updateCalculationMethod(method.index);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMadhabPicker(BuildContext context, WidgetRef ref) {
    final settings = ref.read(settingsProvider);

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingLg),
              child: Text(
                'Madhab (Asr Calculation)',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            const Divider(height: 1),
            ListTile(
              title: const Text("Shafi'i, Maliki, Hanbali"),
              subtitle: const Text('Standard Asr time (shadow equals object)'),
              trailing: settings.madhab == 0
                  ? const Icon(Icons.check, color: AppColors.black)
                  : null,
              onTap: () {
                ref.read(settingsProvider.notifier).saveSettings(
                  settings.copyWith(madhab: 0),
                );
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Hanafi'),
              subtitle: const Text('Later Asr time (shadow equals twice object)'),
              trailing: settings.madhab == 1
                  ? const Icon(Icons.check, color: AppColors.black)
                  : null,
              onTap: () {
                ref.read(settingsProvider.notifier).saveSettings(
                  settings.copyWith(madhab: 1),
                );
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: AppDimensions.spacingMd),
          ],
        ),
      ),
    );
  }

  void _showReminderTimePicker(BuildContext context, WidgetRef ref) {
    final settings = ref.read(settingsProvider);
    final options = [5, 10, 15, 20, 30, 45, 60];

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingLg),
              child: Text(
                'Reminder Time Before Prayer',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            const Divider(height: 1),
            ...options.map((minutes) => ListTile(
              title: Text('$minutes minutes'),
              trailing: settings.defaultReminderMinutes == minutes
                  ? const Icon(Icons.check, color: AppColors.black)
                  : null,
              onTap: () {
                ref.read(settingsProvider.notifier).updateDefaultReminderMinutes(minutes);
                Navigator.pop(context);
              },
            )),
            const SizedBox(height: AppDimensions.spacingMd),
          ],
        ),
      ),
    );
  }

  void _showWeekStartPicker(BuildContext context, WidgetRef ref) {
    final settings = ref.read(settingsProvider);

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingLg),
              child: Text(
                'Week Starts On',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            const Divider(height: 1),
            ListTile(
              title: const Text('Monday'),
              trailing: settings.weekStartDay == 1
                  ? const Icon(Icons.check, color: AppColors.black)
                  : null,
              onTap: () {
                ref.read(settingsProvider.notifier).saveSettings(
                  settings.copyWith(weekStartDay: 1),
                );
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Sunday'),
              trailing: settings.weekStartDay == 7
                  ? const Icon(Icons.check, color: AppColors.black)
                  : null,
              onTap: () {
                ref.read(settingsProvider.notifier).saveSettings(
                  settings.copyWith(weekStartDay: 7),
                );
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Saturday'),
              trailing: settings.weekStartDay == 6
                  ? const Icon(Icons.check, color: AppColors.black)
                  : null,
              onTap: () {
                ref.read(settingsProvider.notifier).saveSettings(
                  settings.copyWith(weekStartDay: 6),
                );
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: AppDimensions.spacingMd),
          ],
        ),
      ),
    );
  }

  void _showClearDataConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data?'),
        content: const Text(
          'This will permanently delete all your prayers, tasks, and settings. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final hiveService = ref.read(hiveServiceProvider);
              await hiveService.clearAllData();
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('All data cleared')),
                );
              }
            },
            child: Text(
              'Clear',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  void _showBackupDialog(BuildContext context, WidgetRef ref) async {
    final backupService = ref.read(backupServiceProvider);
    final stats = await backupService.getStats();
    
    if (!context.mounted) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Backup Data'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('This will export your data to a JSON file that you can share or save.'),
            const SizedBox(height: 16),
            Text('Data to backup:', style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 8),
            _buildStatRow(Icons.task_alt, '${stats.taskCount} Tasks'),
            _buildStatRow(Icons.check_circle, '${stats.completionCount} Prayer Completions'),
            _buildStatRow(Icons.settings, stats.hasSettings ? 'Settings' : 'No settings'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await backupService.exportAndShare();
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Backup failed: $e')),
                  );
                }
              }
            },
            icon: const Icon(Icons.share, size: 18),
            label: const Text('Export & Share'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.gray600),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  void _showRestoreDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restore Data'),
        content: const Text(
          'Select a backup file to restore. This will add the backup data to your current data (existing data will not be deleted).',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              Navigator.pop(context);
              await _pickAndRestoreBackup(context, ref);
            },
            icon: const Icon(Icons.folder_open, size: 18),
            label: const Text('Select File'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickAndRestoreBackup(BuildContext context, WidgetRef ref) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );
      
      if (result == null || result.files.isEmpty) return;
      
      final file = File(result.files.first.path!);
      final jsonString = await file.readAsString();
      
      final backupService = ref.read(backupServiceProvider);
      final importResult = await backupService.importData(jsonString);
      
      if (context.mounted) {
        if (importResult.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Restored: ${importResult.tasksImported} tasks, '
                '${importResult.completionsImported} completions'
                '${importResult.settingsImported ? ', settings' : ''}',
              ),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Restore failed: ${importResult.error}'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error reading file: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.screenPaddingHorizontal,
            vertical: AppDimensions.paddingSm,
          ),
          child: Text(
            title,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppColors.gray500,
                  letterSpacing: 0.5,
                ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(
            horizontal: AppDimensions.screenPaddingHorizontal,
          ),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.gray200),
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          ),
          child: Column(
            children: [
              for (int i = 0; i < children.length; i++) ...[
                children[i],
                if (i < children.length - 1) const Divider(height: 1),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// Location picker bottom sheet
class _LocationPickerSheet extends ConsumerStatefulWidget {
  final WidgetRef ref;

  const _LocationPickerSheet({required this.ref});

  @override
  ConsumerState<_LocationPickerSheet> createState() => _LocationPickerSheetState();
}

class _LocationPickerSheetState extends ConsumerState<_LocationPickerSheet> {
  final _searchController = TextEditingController();
  final _locationService = LocationService();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await _locationService.getCurrentLocation();

    if (result.isSuccess) {
      await widget.ref.read(settingsProvider.notifier).updateLocation(
        latitude: result.latitude!,
        longitude: result.longitude!,
        locationName: result.locationName,
      );
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Location updated to ${result.locationName ?? "your location"}')),
        );
      }
    } else {
      setState(() {
        _errorMessage = result.errorMessage;
        _isLoading = false;
      });
    }
  }

  Future<void> _searchLocation(String query) async {
    if (query.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await _locationService.searchLocation(query);

    if (result.isSuccess) {
      await widget.ref.read(settingsProvider.notifier).updateLocation(
        latitude: result.latitude!,
        longitude: result.longitude!,
        locationName: result.locationName,
      );
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Location updated to ${result.locationName}')),
        );
      }
    } else {
      setState(() {
        _errorMessage = result.errorMessage;
        _isLoading = false;
      });
    }
  }

  void _selectCity(PredefinedCity city) {
    widget.ref.read(settingsProvider.notifier).updateLocation(
      latitude: city.latitude,
      longitude: city.longitude,
      locationName: city.displayName,
    );
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Location updated to ${city.displayName}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) => SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingLg),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Set Location',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Current location button
            Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingMd),
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _getCurrentLocation,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.my_location),
                label: const Text('Use Current Location'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
            ),

            // Error message
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingMd),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(color: AppColors.error, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ),

            // Search
            Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingMd),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search city...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.arrow_forward),
                    onPressed: () => _searchLocation(_searchController.text),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  ),
                ),
                onSubmitted: _searchLocation,
              ),
            ),

            const Divider(height: 1),

            // Popular cities
            Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingMd),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Popular Cities',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: AppColors.gray500,
                      ),
                ),
              ),
            ),

            // Cities list
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: PredefinedCity.cities.length,
                itemBuilder: (context, index) {
                  final city = PredefinedCity.cities[index];
                  return ListTile(
                    leading: const Icon(Icons.location_city, size: 20),
                    title: Text(city.name),
                    subtitle: Text(city.country),
                    onTap: () => _selectCity(city),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final bool showArrow;
  final Color? textColor;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
    this.showArrow = true,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingMd),
        child: Row(
          children: [
            Icon(
              icon,
              size: 22,
              color: textColor ?? AppColors.gray700,
            ),
            const SizedBox(width: AppDimensions.spacingMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: textColor,
                        ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.gray500,
                          ),
                    ),
                  ],
                ],
              ),
            ),
            if (showArrow)
              Icon(
                Icons.chevron_right,
                size: 20,
                color: AppColors.gray400,
              ),
          ],
        ),
      ),
    );
  }
}

class _SettingsSwitch extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingsSwitch({
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingMd,
        vertical: AppDimensions.paddingSm,
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 22,
            color: AppColors.gray700,
          ),
          const SizedBox(width: AppDimensions.spacingMd),
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

/// Slider for numeric settings
class _SettingsSlider extends StatelessWidget {
  final IconData icon;
  final String title;
  final int value;
  final int min;
  final int max;
  final String suffix;
  final ValueChanged<int> onChanged;

  const _SettingsSlider({
    required this.icon,
    required this.title,
    required this.value,
    required this.min,
    required this.max,
    required this.suffix,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: AppColors.gray600),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.gray100,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '$value $suffix',
                  style: TextStyle(
                    color: AppColors.gray700,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          Slider(
            value: value.toDouble(),
            min: min.toDouble(),
            max: max.toDouble(),
            divisions: max - min,
            onChanged: (v) => onChanged(v.round()),
          ),
        ],
      ),
    );
  }
}

/// Sleep time picker widget
class _SleepTimePicker extends StatelessWidget {
  final int sleepHour;
  final int sleepMinute;
  final Function(int, int) onChanged;

  const _SleepTimePicker({
    required this.sleepHour,
    required this.sleepMinute,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final timeOfDay = TimeOfDay(hour: sleepHour, minute: sleepMinute);
    final formattedTime = timeOfDay.format(context);

    return InkWell(
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: timeOfDay,
          helpText: 'Set your sleep time',
        );
        if (picked != null) {
          onChanged(picked.hour, picked.minute);
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingMd),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.gray100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.bedtime,
                color: AppColors.gray700,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sleep Time',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    'When you usually go to bed',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.gray500,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.black,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                formattedTime,
                style: const TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right, color: AppColors.gray400),
          ],
        ),
      ),
    );
  }
}

/// Qiyam al-Layl toggle
class _QiyamToggle extends StatelessWidget {
  final bool isEnabled;
  final ValueChanged<bool> onChanged;

  const _QiyamToggle({
    required this.isEnabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingMd),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isEnabled ? AppColors.black : AppColors.gray100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.nights_stay,
              color: isEnabled ? AppColors.white : AppColors.gray500,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Qiyam al-Layl',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Enable night prayer time calculation',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.gray500,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: isEnabled,
            onChanged: onChanged,
            activeColor: AppColors.black,
          ),
        ],
      ),
    );
  }
}

/// Qiyam wake time selector with Sunnah-based options
class _QiyamWakeTimeSelector extends ConsumerWidget {
  final WidgetRef ref;
  
  const _QiyamWakeTimeSelector({required this.ref});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(prayerTimeSettingsProvider);
    final prayerTimes = ref.watch(prayerTimesProvider);
    final freeTimeService = ref.watch(freeTimeServiceProvider);
    
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.schedule, size: 20, color: AppColors.gray600),
              const SizedBox(width: 8),
              Text(
                'Wake Time (Based on Quran & Sunnah)',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Sunnah-based option buttons
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: QiyamWakeTimeOption.values.map((option) {
              final isSelected = settings.qiyamWakeOption == option;
              
              // Calculate actual time for this option
              String timeText = '';
              String durationText = '';
              
              if (prayerTimes != null) {
                final qiyamTimes = freeTimeService.calculateQiyamTimes(prayerTimes);
                final wakeTime = qiyamTimes.getWakeTimeForOption(
                  option, 
                  settings.qiyamCustomMinutes,
                );
                final duration = qiyamTimes.getQiyamDurationForOption(
                  option,
                  settings.qiyamCustomMinutes,
                );
                
                timeText = '${wakeTime.hour.toString().padLeft(2, '0')}:${wakeTime.minute.toString().padLeft(2, '0')}';
                final hours = duration.inHours;
                final mins = duration.inMinutes % 60;
                durationText = hours > 0 ? '${hours}h ${mins}m' : '${mins}m';
              }
              
              return GestureDetector(
                onTap: () {
                  ref.read(prayerTimeSettingsProvider.notifier)
                      .setQiyamWakeOption(option);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.black : AppColors.gray100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? AppColors.black : AppColors.gray200,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            QiyamTimes.getArabicName(option),
                            style: TextStyle(
                              color: isSelected ? AppColors.white : AppColors.black,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            QiyamTimes.getEnglishName(option),
                            style: TextStyle(
                              color: isSelected ? AppColors.gray300 : AppColors.gray500,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                      if (timeText.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 12,
                              color: isSelected ? AppColors.gray300 : AppColors.gray500,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              timeText,
                              style: TextStyle(
                                color: isSelected ? AppColors.gray300 : AppColors.gray600,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: isSelected 
                                    ? Colors.green.withValues(alpha: 0.3)
                                    : Colors.green.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                durationText,
                                style: TextStyle(
                                  color: isSelected ? Colors.green[200] : Colors.green[700],
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          
          // Reference text for selected option
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.gray50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.gray200),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.menu_book,
                  size: 16,
                  color: AppColors.gray600,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    QiyamTimes.getReference(settings.qiyamWakeOption),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.gray600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Night duration info
          if (prayerTimes != null) ...[
            const SizedBox(height: 8),
            Builder(
              builder: (context) {
                final qiyamTimes = freeTimeService.calculateQiyamTimes(prayerTimes);
                final nightHours = qiyamTimes.nightDuration.inHours;
                final nightMins = qiyamTimes.nightDuration.inMinutes % 60;
                
                return Text(
                  'Tonight: ${nightHours}h ${nightMins}m (Maghrib to Fajr)',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.gray500,
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}
