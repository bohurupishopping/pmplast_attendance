# PMPLAST KIOSK - Setup Guide

## Overview
PMPLAST KIOSK is a modern, professional attendance management system with QR code scanning, photo verification, GPS tracking, and offline-first architecture.

## Features
✅ **Modern UI Design** - Clean, rounded interface with no shadows
✅ **QR Code Scanning** - Fast employee identification
✅ **Photo Verification** - Front camera capture for attendance proof
✅ **GPS Tracking** - Location verification within 50m radius
✅ **Offline First** - Works without internet, syncs when online
✅ **Web & Mobile Support** - Runs on Chrome browser and mobile devices
✅ **Real-time Sync** - Background synchronization of pending logs

## Prerequisites

1. **Flutter SDK** (3.8.1 or higher)
2. **Supabase Account** (for backend)
3. **Chrome Browser** (for web testing)

## Supabase Setup

### Step 1: Create Supabase Project
1. Go to [https://supabase.com](https://supabase.com)
2. Create a new project
3. Save your project URL and anon key

### Step 2: Run Database Migration
1. Open Supabase SQL Editor
2. Copy and paste the content from `migrations/db.sql`
3. Execute the script

### Step 3: Create Storage Bucket
1. Go to Storage in Supabase Dashboard
2. Create a new bucket named `attendance-photos`
3. Make it **PUBLIC**
4. Storage policies are already created by the SQL script

### Step 4: Configure Environment
Update `lib/core/config.dart` with your Supabase credentials:

```dart
class SupabaseConfig {
  static const String url = 'YOUR_SUPABASE_URL';
  static const String anonKey = 'YOUR_SUPABASE_ANON_KEY';
}
```

## Installation

### 1. Install Dependencies
```bash
flutter pub get
```

### 2. Generate Hive Adapters
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 3. Run on Web (Chrome)
```bash
flutter run -d chrome --web-browser-flag "--disable-web-security"
```

**Note:** The `--disable-web-security` flag is needed for camera/location access during development.

### 4. Run on Mobile
```bash
# Android
flutter run -d android

# iOS
flutter run -d ios
```

## First Time Setup

### Device Registration (Admin Only)

1. **Launch the App**
   - First time you open the app, you'll see the Device Registration screen

2. **Enter Admin Credentials**
   - Email: Your Supabase admin email
   - Password: Your Supabase admin password
   - Device Name: e.g., "Main Entrance Kiosk"

3. **Grant Permissions**
   - Camera access (for QR scanning and photo capture)
   - Location access (for GPS verification)

4. **Complete Registration**
   - The app will capture the device's GPS location as the "office location"
   - This location is used to verify all future check-ins are within 50m

## Usage

### Employee Check-In/Check-Out

1. **Scan QR Code**
   - Employee holds their QR code in front of the camera
   - Code contains their `employee_id`

2. **Automatic Verification**
   - Photo is captured automatically
   - GPS location is verified
   - Data is uploaded to Supabase (or stored locally if offline)

3. **Feedback**
   - Success: Green screen with "Welcome, [Name]!" or "Goodbye, [Name]!"
   - Failure: Red screen with error message
   - Display duration: 3 seconds

### Offline Mode

- **Automatic Detection**: App monitors internet connectivity
- **Local Storage**: Attendance logs are saved locally using Hive
- **Background Sync**: When internet returns, logs are automatically uploaded
- **Status Indicator**: Orange "Offline" badge in top-right corner

## Permissions

### Web (Chrome)
- Camera permission required for QR scanning and photo capture
- Location permission required for GPS verification

### Android
Add to `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
<uses-permission android:name="android.permission.INTERNET"/>
```

### iOS
Add to `ios/Runner/Info.plist`:
```xml
<key>NSCameraUsageDescription</key>
<string>Camera access is required for QR code scanning and photo verification</string>
<key>NSLocationWhenInUseUsageDescription</key>
<string>Location access is required to verify attendance location</string>
```

## Architecture

### Folder Structure
```
lib/
├── core/              # Theme, constants, config
├── data/              # Data layer
│   ├── models/        # Data models
│   ├── providers/     # Riverpod providers
│   └── services/      # API and business logic
├── features/          # Feature modules
│   ├── registration/  # Device setup
│   ├── kiosk/        # Main scanning screen
│   └── sync/         # Offline sync service
└── main.dart         # App entry point
```

### Tech Stack
- **State Management**: Riverpod
- **Backend**: Supabase (PostgreSQL + Storage)
- **Local Storage**: Hive
- **QR Scanner**: mobile_scanner
- **Camera**: camera package
- **Location**: geolocator

## Troubleshooting

### Camera Not Working on Web
```bash
# Run with CORS disabled
flutter run -d chrome --web-browser-flag "--disable-web-security"
```

### Location Not Working
- Ensure location services are enabled on device
- Check app has location permissions granted
- For web, ensure HTTPS connection (or localhost)

### Supabase Connection Errors
- Verify URL and anon key in `config.dart`
- Check network connectivity
- Verify Supabase project is active

### Build Errors
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

## Database Schema

### Tables
- **employees**: Employee profiles with QR code IDs
- **devices**: Registered kiosk devices with fixed GPS locations
- **attendance_logs**: Check-in/check-out records with photos and GPS

### RPC Functions
- `log_verified_attendance`: Main function for logging attendance with verification

## Security

- ✅ Row Level Security (RLS) enabled on all tables
- ✅ Server-side verification in RPC functions
- ✅ Location verification within 50m radius
- ✅ Secure storage for device credentials
- ✅ Photo evidence for all attendance records

## Support

For issues or questions, refer to:
- Plan document: `plan.md`
- Database schema: `migrations/db.sql`
- Code documentation in source files

---

**Built with ❤️ for PMPLAST**
