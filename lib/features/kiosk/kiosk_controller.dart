import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/attendance_service.dart';
import '../../data/services/device_service.dart';
import '../../data/services/location_service.dart';
import '../../data/providers/connectivity_provider.dart';
import '../../features/sync/sync_service.dart';
import '../../data/models/pending_log.dart';
import '../../core/constants.dart';

enum KioskStatus { ready, verifying, success, failure }

class KioskState {
  final KioskStatus status;
  final String? message;

  KioskState({
    required this.status,
    this.message,
  });

  KioskState copyWith({
    KioskStatus? status,
    String? message,
  }) {
    return KioskState(
      status: status ?? this.status,
      message: message,
    );
  }
}

final kioskControllerProvider =
    StateNotifierProvider<KioskController, KioskState>((ref) {
  final attendanceService = ref.watch(attendanceServiceProvider);
  final deviceService = ref.watch(deviceServiceProvider);
  final locationService = ref.watch(locationServiceProvider);
  final syncService = ref.watch(syncServiceProvider);
  final isOnline = ref.watch(isOnlineProvider);
  
  return KioskController(
    attendanceService,
    deviceService,
    locationService,
    syncService,
    isOnline,
  );
});

class KioskController extends StateNotifier<KioskState> {
  final AttendanceService _attendanceService;
  final DeviceService _deviceService;
  final LocationService _locationService;
  final SyncService _syncService;
  final bool _isOnline;
  
  bool _isProcessing = false;

  KioskController(
    this._attendanceService,
    this._deviceService,
    this._locationService,
    this._syncService,
    this._isOnline,
  ) : super(KioskState(status: KioskStatus.ready));

  Future<void> verifyAttendance(String employeeId, dynamic capturedImage) async {
    if (_isProcessing) return;
    _isProcessing = true;

    state = state.copyWith(
      status: KioskStatus.verifying,
      message: null,
    );

    try {
      final deviceId = await _deviceService.getStoredDeviceId();
      if (deviceId == null) {
        throw Exception('Device not registered');
      }

      final position = await _locationService.getCurrentPosition();
      
      if (capturedImage == null) {
        throw Exception('Failed to capture photo');
      }

      final compressedImage = await _attendanceService.compressImage(capturedImage);

      if (_isOnline) {
        final photoUrl = await _attendanceService.uploadPhoto(compressedImage);
        
        final message = await _attendanceService.logVerifiedAttendance(
          employeeId: employeeId,
          deviceUniqueId: deviceId,
          photoUrl: photoUrl,
          longitude: position.longitude,
          latitude: position.latitude,
        );

        state = state.copyWith(
          status: KioskStatus.success,
          message: message,
        );
      } else {
        final imagePath = await _attendanceService.saveTempImage(compressedImage);
        
        final pendingLog = PendingLog(
          employeeId: employeeId,
          timestamp: DateTime.now(),
          latitude: position.latitude,
          longitude: position.longitude,
          localImagePath: imagePath,
        );

        await _syncService.addPendingLog(pendingLog);

        state = state.copyWith(
          status: KioskStatus.success,
          message: 'Log saved. Will sync when online.',
        );
      }

      await Future.delayed(AppConstants.feedbackDisplayDuration);
      state = state.copyWith(status: KioskStatus.ready);
      
    } catch (e) {
      state = state.copyWith(
        status: KioskStatus.failure,
        message: e.toString(),
      );

      await Future.delayed(AppConstants.feedbackDisplayDuration);
      state = state.copyWith(status: KioskStatus.ready);
    } finally {
      _isProcessing = false;
    }
  }
}
