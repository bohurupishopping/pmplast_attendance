class Device {
  final String id;
  final String deviceName;
  final String deviceUniqueId;
  final bool isActive;
  final double latitude;
  final double longitude;

  Device({
    required this.id,
    required this.deviceName,
    required this.deviceUniqueId,
    required this.isActive,
    required this.latitude,
    required this.longitude,
  });

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      id: json['id'] as String,
      deviceName: json['device_name'] as String,
      deviceUniqueId: json['device_unique_id'] as String,
      isActive: json['is_active'] as bool? ?? true,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'device_name': deviceName,
      'device_unique_id': deviceUniqueId,
      'is_active': isActive,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
