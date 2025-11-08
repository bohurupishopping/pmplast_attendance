import 'package:hive/hive.dart';

part 'pending_log.g.dart';

@HiveType(typeId: 0)
class PendingLog extends HiveObject {
  @HiveField(0)
  final String employeeId;

  @HiveField(1)
  final DateTime timestamp;

  @HiveField(2)
  final double latitude;

  @HiveField(3)
  final double longitude;

  @HiveField(4)
  final String localImagePath;

  PendingLog({
    required this.employeeId,
    required this.timestamp,
    required this.latitude,
    required this.longitude,
    required this.localImagePath,
  });

  Map<String, dynamic> toJson() {
    return {
      'employee_id': employeeId,
      'timestamp': timestamp.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
      'local_image_path': localImagePath,
    };
  }
}
