import 'dart:typed_data';
import 'dart:io' show File;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import '../providers/supabase_provider.dart';
import '../../core/constants.dart';

final attendanceServiceProvider = Provider<AttendanceService>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return AttendanceService(supabase);
});

class AttendanceService {
  final SupabaseClient _supabase;

  AttendanceService(this._supabase);

  Future<Uint8List> compressImage(dynamic imageFile) async {
    Uint8List bytes;
    
    if (imageFile is Uint8List) {
      bytes = imageFile;
    } else if (imageFile is File && !kIsWeb) {
      bytes = await imageFile.readAsBytes();
    } else {
      throw Exception('Invalid image type');
    }
    
    img.Image? image = img.decodeImage(bytes);
    
    if (image == null) throw Exception('Failed to decode image');

    // Resize to smaller dimensions for better compression
    int targetWidth = 400;
    if (image.width > targetWidth) {
      image = img.copyResize(image, width: targetWidth);
    }

    // Compress to JPG format with target size under 10KB
    int quality = 60;
    Uint8List compressed = Uint8List.fromList(
      img.encodeJpg(image, quality: quality),
    );

    // If still too large, reduce quality further
    while (compressed.length > 10240 && quality > 10) {
      quality -= 10;
      compressed = Uint8List.fromList(
        img.encodeJpg(image, quality: quality),
      );
    }

    return compressed;
  }

  Future<String> uploadPhoto(Uint8List imageBytes) async {
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';

    await _supabase.storage
        .from(AppConstants.supabaseStorageBucket)
        .uploadBinary(fileName, imageBytes);

    final publicUrl = _supabase.storage
        .from(AppConstants.supabaseStorageBucket)
        .getPublicUrl(fileName);

    return publicUrl;
  }

  Future<String> saveTempImage(Uint8List imageBytes) async {
    if (kIsWeb) {
      return 'web_temp_${DateTime.now().millisecondsSinceEpoch}';
    }
    
    try {
      final tempDir = await getTemporaryDirectory();
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(imageBytes);
      return file.path;
    } catch (e) {
      return 'temp_${DateTime.now().millisecondsSinceEpoch}';
    }
  }

  Future<String> logVerifiedAttendance({
    required String employeeId,
    required String deviceUniqueId,
    required String photoUrl,
    required double longitude,
    required double latitude,
  }) async {
    final response = await _supabase.rpc('log_verified_attendance', params: {
      'p_employee_id': employeeId,
      'p_device_unique_id': deviceUniqueId,
      'p_photo_url': photoUrl,
      'p_longitude': longitude,
      'p_latitude': latitude,
    });

    return response as String;
  }
}
