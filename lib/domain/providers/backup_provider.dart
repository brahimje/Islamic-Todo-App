import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/backup_service.dart';
import 'prayer_provider.dart';

/// Provider for the backup service
final backupServiceProvider = Provider<BackupService>((ref) {
  final hiveService = ref.watch(hiveServiceProvider);
  return BackupService(hiveService);
});

/// Provider for backup statistics
final backupStatsProvider = FutureProvider<BackupStats>((ref) async {
  final backupService = ref.watch(backupServiceProvider);
  return backupService.getStats();
});
