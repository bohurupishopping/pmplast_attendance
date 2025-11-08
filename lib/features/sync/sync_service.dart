import 'dart:io' show File;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../../data/models/pending_log.dart';
import '../../data/services/attendance_service.dart';
import '../../data/services/device_service.dart';
import '../../core/constants.dart';

final syncServiceProvider = Provider<SyncService>((ref) {
  final attendanceService = ref.watch(attendanceServiceProvider);
  final deviceService = ref.watch(deviceServiceProvider);
  return SyncService(attendanceService, deviceService);
});

class SyncService {
  final AttendanceService _attendanceService;
  final DeviceService _deviceService;

  SyncService(this._attendanceService, this._deviceService);

  Future<void> syncPendingLogs() async {
    final box = await Hive.openBox<PendingLog>(AppConstants.pendingLogsBoxName);
    
    if (box.isEmpty) return;

    final deviceId = await _deviceService.getStoredDeviceId();
    if (deviceId == null) return;

    final keys = box.keys.toList();
    
    for (var key in keys) {
      final log = box.get(key);
      if (log == null) continue;

      try {
        if (kIsWeb) {
          await box.delete(key);
          continue;
        }
        
        try {
          final imageFile = File(log.localImagePath);
          if (!await imageFile.exists()) {
            await box.delete(key);
            continue;
          }

          final imageBytes = await imageFile.readAsBytes();
          final compressedBytes = await _attendanceService.compressImage(imageBytes);
          
          final photoUrl = await _attendanceService.uploadPhoto(compressedBytes);
          
          await _attendanceService.logVerifiedAttendance(
            employeeId: log.employeeId,
            deviceUniqueId: deviceId,
            photoUrl: photoUrl,
            longitude: log.longitude,
            latitude: log.latitude,
          );

          await imageFile.delete();
          await box.delete(key);
        } catch (e) {
          await box.delete(key);
        }
      } catch (e) {
        break;
      }
    }
  }

  Future<void> addPendingLog(PendingLog log) async {
    final box = await Hive.openBox<PendingLog>(AppConstants.pendingLogsBoxName);
    await box.add(log);
  }

  Future<int> getPendingLogsCount() async {
    final box = await Hive.openBox<PendingLog>(AppConstants.pendingLogsBoxName);
    return box.length;
  }
}
