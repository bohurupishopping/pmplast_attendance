import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/supabase_provider.dart';
import '../providers/storage_provider.dart';
import '../../core/constants.dart';

final deviceServiceProvider = Provider<DeviceService>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  final storage = ref.watch(secureStorageProvider);
  return DeviceService(supabase, storage);
});

class DeviceService {
  final SupabaseClient _supabase;
  final FlutterSecureStorage _storage;

  DeviceService(this._supabase, this._storage);

  Future<String> getDeviceUniqueId() async {
    final deviceInfo = DeviceInfoPlugin();
    
    if (kIsWeb) {
      final webInfo = await deviceInfo.webBrowserInfo;
      return 'web_${webInfo.userAgent?.hashCode ?? DateTime.now().millisecondsSinceEpoch}';
    }
    
    try {
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        return androidInfo.id;
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        return iosInfo.identifierForVendor ?? '';
      }
    } catch (e) {
      // Platform not available
    }
    
    return 'unknown_${DateTime.now().millisecondsSinceEpoch}';
  }

  Future<String?> getStoredDeviceId() async {
    return await _storage.read(key: AppConstants.deviceIdKey);
  }

  Future<void> saveDeviceId(String deviceId) async {
    await _storage.write(key: AppConstants.deviceIdKey, value: deviceId);
  }

  Future<void> registerDevice({
    required String deviceName,
    required String deviceUniqueId,
    required double latitude,
    required double longitude,
  }) async {
    await _supabase.from('devices').insert({
      'device_name': deviceName,
      'device_unique_id': deviceUniqueId,
      'is_active': true,
      'location': 'POINT($longitude $latitude)',
    }).select().single();

    await saveDeviceId(deviceUniqueId);
  }
}
