import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../datasources/local/hive_service.dart';
import '../models/models.dart';

/// Service for backing up and restoring app data
class BackupService {
  final HiveService _hiveService;
  
  BackupService(this._hiveService);
  
  /// Export all data to JSON
  Future<Map<String, dynamic>> exportData() async {
    final tasks = _hiveService.tasksBox.values.map((t) => _taskToJson(t)).toList();
    final settings = _hiveService.getSettings();
    final prayerCompletions = _hiveService.prayerCompletionsBox.values
        .map((c) => _completionToJson(c))
        .toList();
    
    return {
      'version': '1.0.0',
      'exportedAt': DateTime.now().toIso8601String(),
      'tasks': tasks,
      'settings': settings != null ? _settingsToJson(settings) : null,
      'prayerCompletions': prayerCompletions,
    };
  }
  
  /// Export data to a JSON file and share it
  Future<void> exportAndShare() async {
    final data = await exportData();
    final jsonString = const JsonEncoder.withIndent('  ').convert(data);
    
    // Get temporary directory
    final directory = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final file = File('${directory.path}/islamic_todo_backup_$timestamp.json');
    
    // Write to file
    await file.writeAsString(jsonString);
    
    // Share the file
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path)],
        subject: 'Islamic Todo Backup',
        text: 'My Islamic Todo App backup',
      ),
    );
  }
  
  /// Import data from JSON
  Future<ImportResult> importData(String jsonString) async {
    try {
      final data = json.decode(jsonString) as Map<String, dynamic>;
      
      int tasksImported = 0;
      int completionsImported = 0;
      bool settingsImported = false;
      
      // Import tasks
      if (data['tasks'] != null) {
        final tasks = data['tasks'] as List<dynamic>;
        for (final taskJson in tasks) {
          final task = _taskFromJson(taskJson as Map<String, dynamic>);
          await _hiveService.tasksBox.put(task.id, task);
          tasksImported++;
        }
      }
      
      // Import settings
      if (data['settings'] != null) {
        final settings = _settingsFromJson(data['settings'] as Map<String, dynamic>);
        await _hiveService.saveSettings(settings);
        settingsImported = true;
      }
      
      // Import prayer completions
      if (data['prayerCompletions'] != null) {
        final completions = data['prayerCompletions'] as List<dynamic>;
        for (final completionJson in completions) {
          final completion = _completionFromJson(completionJson as Map<String, dynamic>);
          await _hiveService.prayerCompletionsBox.put(completion.id, completion);
          completionsImported++;
        }
      }
      
      return ImportResult(
        success: true,
        tasksImported: tasksImported,
        completionsImported: completionsImported,
        settingsImported: settingsImported,
      );
    } catch (e) {
      return ImportResult(
        success: false,
        error: e.toString(),
      );
    }
  }
  
  /// Get backup statistics
  Future<BackupStats> getStats() async {
    return BackupStats(
      taskCount: _hiveService.tasksBox.length,
      completionCount: _hiveService.prayerCompletionsBox.length,
      hasSettings: _hiveService.getSettings() != null,
    );
  }
  
  // Task serialization
  Map<String, dynamic> _taskToJson(Task task) {
    return {
      'id': task.id,
      'title': task.title,
      'description': task.description,
      'scheduledTime': task.scheduledTime?.toIso8601String(),
      'deadline': task.deadline?.toIso8601String(),
      'estimatedMinutes': task.estimatedMinutes,
      'isCompleted': task.isCompleted,
      'createdAt': task.createdAt.toIso8601String(),
      'completedAt': task.completedAt?.toIso8601String(),
      'priority': task.priority,
      'hasNotification': task.hasNotification,
      'category': task.category,
      'tags': task.tags,
      'reminderMinutesBefore': task.reminderMinutesBefore,
      'isRecurring': task.isRecurring,
      'recurringPattern': task.recurringPattern,
      'isReligious': task.isReligious,
      'prayerBlockId': task.prayerBlockId,
      'orderIndex': task.orderIndex,
    };
  }
  
  Task _taskFromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      scheduledTime: json['scheduledTime'] != null 
          ? DateTime.parse(json['scheduledTime'] as String)
          : null,
      deadline: json['deadline'] != null
          ? DateTime.parse(json['deadline'] as String)
          : null,
      estimatedMinutes: json['estimatedMinutes'] as int?,
      isCompleted: json['isCompleted'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      priority: json['priority'] as int? ?? 1,
      hasNotification: json['hasNotification'] as bool? ?? false,
      category: json['category'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      reminderMinutesBefore: json['reminderMinutesBefore'] as int? ?? 10,
      isRecurring: json['isRecurring'] as bool? ?? false,
      recurringPattern: json['recurringPattern'] as String?,
      isReligious: json['isReligious'] as bool? ?? false,
      prayerBlockId: json['prayerBlockId'] as String?,
      orderIndex: json['orderIndex'] as int? ?? 0,
    );
  }
  
  // Settings serialization
  Map<String, dynamic> _settingsToJson(UserSettings settings) {
    return {
      'calculationMethod': settings.calculationMethod,
      'latitude': settings.latitude,
      'longitude': settings.longitude,
      'locationName': settings.locationName,
      'notificationsEnabled': settings.notificationsEnabled,
      'defaultReminderMinutes': settings.defaultReminderMinutes,
      'showNafilaReminders': settings.showNafilaReminders,
      'showTaskReminders': settings.showTaskReminders,
      'language': settings.language,
      'dailyReviewHour': settings.dailyReviewHour,
      'dailyReviewMinute': settings.dailyReviewMinute,
      'isOnboardingComplete': settings.isOnboardingComplete,
      'useSilentNotifications': settings.useSilentNotifications,
      'madhab': settings.madhab,
      'use24HourFormat': settings.use24HourFormat,
      'showCompletedTasks': settings.showCompletedTasks,
      'autoArchiveCompletedTasks': settings.autoArchiveCompletedTasks,
      'weekStartDay': settings.weekStartDay,
    };
  }
  
  UserSettings _settingsFromJson(Map<String, dynamic> json) {
    return UserSettings(
      calculationMethod: json['calculationMethod'] as int? ?? 0,
      latitude: json['latitude'] as double?,
      longitude: json['longitude'] as double?,
      locationName: json['locationName'] as String?,
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
      defaultReminderMinutes: json['defaultReminderMinutes'] as int? ?? 10,
      showNafilaReminders: json['showNafilaReminders'] as bool? ?? true,
      showTaskReminders: json['showTaskReminders'] as bool? ?? true,
      language: json['language'] as String? ?? 'en',
      dailyReviewHour: json['dailyReviewHour'] as int?,
      dailyReviewMinute: json['dailyReviewMinute'] as int?,
      isOnboardingComplete: json['isOnboardingComplete'] as bool? ?? false,
      useSilentNotifications: json['useSilentNotifications'] as bool? ?? false,
      madhab: json['madhab'] as int? ?? 0,
      use24HourFormat: json['use24HourFormat'] as bool? ?? true,
      showCompletedTasks: json['showCompletedTasks'] as bool? ?? true,
      autoArchiveCompletedTasks: json['autoArchiveCompletedTasks'] as bool? ?? false,
      weekStartDay: json['weekStartDay'] as int? ?? 1,
    );
  }
  
  // Prayer completion serialization  
  Map<String, dynamic> _completionToJson(PrayerCompletion completion) {
    return {
      'id': completion.id,
      'date': completion.date.toIso8601String(),
      'fajrCompleted': completion.fajrCompleted,
      'dhuhrCompleted': completion.dhuhrCompleted,
      'asrCompleted': completion.asrCompleted,
      'maghribCompleted': completion.maghribCompleted,
      'ishaCompleted': completion.ishaCompleted,
      'nafilaCompleted': completion.nafilaCompleted,
      'fajrCompletedAt': completion.fajrCompletedAt?.toIso8601String(),
      'dhuhrCompletedAt': completion.dhuhrCompletedAt?.toIso8601String(),
      'asrCompletedAt': completion.asrCompletedAt?.toIso8601String(),
      'maghribCompletedAt': completion.maghribCompletedAt?.toIso8601String(),
      'ishaCompletedAt': completion.ishaCompletedAt?.toIso8601String(),
    };
  }
  
  PrayerCompletion _completionFromJson(Map<String, dynamic> json) {
    return PrayerCompletion(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      fajrCompleted: json['fajrCompleted'] as int? ?? 0,
      dhuhrCompleted: json['dhuhrCompleted'] as int? ?? 0,
      asrCompleted: json['asrCompleted'] as int? ?? 0,
      maghribCompleted: json['maghribCompleted'] as int? ?? 0,
      ishaCompleted: json['ishaCompleted'] as int? ?? 0,
      nafilaCompleted: (json['nafilaCompleted'] as List<dynamic>?)?.cast<String>() ?? [],
      fajrCompletedAt: json['fajrCompletedAt'] != null
          ? DateTime.parse(json['fajrCompletedAt'] as String)
          : null,
      dhuhrCompletedAt: json['dhuhrCompletedAt'] != null
          ? DateTime.parse(json['dhuhrCompletedAt'] as String)
          : null,
      asrCompletedAt: json['asrCompletedAt'] != null
          ? DateTime.parse(json['asrCompletedAt'] as String)
          : null,
      maghribCompletedAt: json['maghribCompletedAt'] != null
          ? DateTime.parse(json['maghribCompletedAt'] as String)
          : null,
      ishaCompletedAt: json['ishaCompletedAt'] != null
          ? DateTime.parse(json['ishaCompletedAt'] as String)
          : null,
    );
  }
}

/// Result of an import operation
class ImportResult {
  final bool success;
  final int tasksImported;
  final int completionsImported;
  final bool settingsImported;
  final String? error;
  
  ImportResult({
    required this.success,
    this.tasksImported = 0,
    this.completionsImported = 0,
    this.settingsImported = false,
    this.error,
  });
}

/// Statistics about data available for backup
class BackupStats {
  final int taskCount;
  final int completionCount;
  final bool hasSettings;
  
  BackupStats({
    required this.taskCount,
    required this.completionCount,
    required this.hasSettings,
  });
}
