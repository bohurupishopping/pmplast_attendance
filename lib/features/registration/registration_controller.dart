import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/device_service.dart';
import '../../data/services/location_service.dart';

final registrationControllerProvider =
    StateNotifierProvider<RegistrationController, RegistrationState>((ref) {
  final authService = ref.watch(authServiceProvider);
  final deviceService = ref.watch(deviceServiceProvider);
  final locationService = ref.watch(locationServiceProvider);
  return RegistrationController(authService, deviceService, locationService);
});

class RegistrationState {
  final bool isLoading;
  final bool isSuccess;
  final String? errorMessage;

  RegistrationState({
    this.isLoading = false,
    this.isSuccess = false,
    this.errorMessage,
  });

  RegistrationState copyWith({
    bool? isLoading,
    bool? isSuccess,
    String? errorMessage,
  }) {
    return RegistrationState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: errorMessage,
    );
  }
}

class RegistrationController extends StateNotifier<RegistrationState> {
  final AuthService _authService;
  final DeviceService _deviceService;
  final LocationService _locationService;

  RegistrationController(
    this._authService,
    this._deviceService,
    this._locationService,
  ) : super(RegistrationState());

  Future<void> registerDevice({
    required String email,
    required String password,
    required String deviceName,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      await _authService.signInWithEmailPassword(
        email: email,
        password: password,
      );

      final deviceUniqueId = await _deviceService.getDeviceUniqueId();

      final position = await _locationService.getCurrentPosition();

      await _deviceService.registerDevice(
        deviceName: deviceName,
        deviceUniqueId: deviceUniqueId,
        latitude: position.latitude,
        longitude: position.longitude,
      );

      state = state.copyWith(isLoading: false, isSuccess: true);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Registration failed: ${e.toString()}',
      );
    }
  }
}
