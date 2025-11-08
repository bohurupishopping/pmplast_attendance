class AppConstants {
  static const String appName = 'PMPLAST KIOSK';
  static const String deviceIdKey = 'device_unique_id';
  static const String pendingLogsBoxName = 'pending_logs';
  
  static const int locationVerificationRadius = 50;
  static const int imageMaxWidth = 800;
  static const int imageQuality = 85;
  static const int maxImageSizeKB = 200;
  
  static const Duration feedbackDisplayDuration = Duration(seconds: 3);
  static const Duration scanCooldownDuration = Duration(seconds: 2);
  
  static const String supabaseStorageBucket = 'attendance-photos';
}
