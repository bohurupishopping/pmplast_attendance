# How PMPLAST KIOSK Works

## Overview
PMPLAST KIOSK is an attendance management system that uses QR code scanning, photo verification, and GPS tracking to securely log employee check-ins and check-outs.

---

## The Flow

### 1. **First Time Setup (Admin)**
- Admin registers the device with email and password
- App captures the device's GPS location (office address)
- This location becomes the "verification zone" (50m radius)

### 2. **Employee Check-In**
- Employee scans their QR code using the camera
- App automatically captures a photo of the employee
- App verifies the GPS location is within office zone
- Success message appears: **"Welcome, [Name]!"**

### 3. **Employee Check-Out**
- Same process as check-in
- App recognizes employee already checked in
- Logs the check-out instead
- Success message appears: **"Goodbye, [Name]!"**

---

## Key Features

### 📱 **Offline First**
- If no internet: Attendance is saved locally on device
- Green badge shows "Offline" status
- When internet returns: Automatically syncs pending logs to cloud

### 📸 **Photo Verification**
- Front camera captures photo at each check-in/out
- Photo is compressed and uploaded to cloud storage
- Proof of attendance is stored permanently

### 📍 **GPS Verification**
- App verifies employee is within 50m of office location
- Prevents fake check-ins from remote locations
- Security check runs automatically

### 🎨 **Modern Design**
- Clean, rounded interface (no shadows)
- Works perfectly on mobile and Chrome browser
- Responsive layout adapts to any screen size
- Large status messages for visibility

---

## What Happens Behind the Scenes

```
Employee scans QR code
        ↓
App pauses scanner
        ↓
Capture photo + GPS location
        ↓
Check internet connection
        ↓
ONLINE:                          OFFLINE:
├─ Upload photo                  ├─ Save photo locally
├─ Send to database              ├─ Save log to device
└─ Show result                   └─ Show "Will sync when online"
                                      ↓
                                 (Auto-syncs when online)
```

---

## Status Indicators

| Icon | Meaning |
|------|---------|
| 🟢 **Green checkmark** | Check-in/out successful |
| 🔴 **Red X** | Failed (employee not found, location error, etc.) |
| 🟠 **Orange cloud** | Offline - logs saved locally |
| 🟢 **Green cloud** | Online - ready to log |

---

## Error Messages

| Error | Reason |
|-------|--------|
| Employee not found | QR code not in system |
| Location verification failed | Outside 50m office zone |
| Device not registered | Device wasn't set up properly |
| No permission | Camera/location access denied |

---

## Data Flow

```
DEVICE (Mobile/Web)
    ↓ (Offline: Hive local storage)
    ↓ (Online: Upload to cloud)
    ↓
SUPABASE (Cloud Backend)
    ├─ PostgreSQL Database
    │   ├─ employees table
    │   ├─ devices table
    │   └─ attendance_logs table
    │
    └─ Storage (Photos)
        └─ attendance-photos bucket
```

---

## Security

✅ **Device Verification** - Only registered devices can log attendance  
✅ **Location Verification** - GPS check within office zone  
✅ **Photo Evidence** - Every log has accompanying photo  
✅ **Secure Storage** - Credentials encrypted on device  
✅ **Server-Side Validation** - All checks done on secure backend  

---

## Permissions Required

### Android
- 📷 Camera (for QR scanning and photos)
- 📍 Location (for GPS verification)
- 🌐 Internet (for cloud sync)

### iOS
- 📷 Camera (for QR scanning and photos)
- 📍 Location (for GPS verification)
- 🌐 Internet (for cloud sync)

### Web (Chrome)
- 📷 Camera (for QR scanning and photos)
- 📍 Location (for GPS verification)

---

## Typical Workflow

**Morning:**
1. Employee enters office
2. Walks to kiosk
3. Scans QR code
4. Takes photo (automatic)
5. GPS verified
6. Green screen: "Welcome, John Doe!"

**Evening:**
1. Employee leaves office
2. Walks to kiosk
3. Scans QR code
4. Takes photo (automatic)
5. GPS verified
6. Red screen: "Goodbye, John Doe!"

---

## What Gets Saved

For each attendance log:
- ✅ Employee name & ID
- ✅ Check-in & check-out time
- ✅ Photo of employee
- ✅ GPS coordinates
- ✅ Device ID
- ✅ Date

---

## Offline Sync Example

```
9:00 AM - No Internet
├─ Employee scans QR
├─ Photo captured
├─ Log saved locally
└─ Message: "Log saved. Will sync when online."

2:00 PM - Internet Returns
├─ App detects connection
├─ Uploads all pending logs
├─ Sends all pending photos
├─ Updates database
└─ Pending queue cleared
```

---

## That's It! 🎉

The app handles all the complexity automatically. Employees just scan and smile! 📸

---

**Need help?** See `SETUP_GUIDE.md` for installation and configuration.
