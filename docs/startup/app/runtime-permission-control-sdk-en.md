# Runtime Permission Control SDK

> **Note** <br>
> **Supported Devices**: Android 6.0 (API 23) and higher
> Supported since StartUp app version 6.4.17.

## Overview

This SDK allows external applications to grant or revoke dangerous permissions for other apps via a broadcast intent. 
This feature is useful in scenarios where permissions need to be controlled without user interaction.

### Quick Start

#### Grant Permission

```kotlin
// Grant CAMERA permission
val intent = Intent("com.android.server.startupservice.system").apply {
    putExtra("setting", "permission")
    putExtra("package", "com.example.cameraapp")
    putExtra("permission", "android.permission.CAMERA")
    putExtra("permission_mode", 1)  // Grant
}
context.sendBroadcast(intent)
```

#### Deny Permission

```kotlin
// Deny CAMERA permission
val intent = Intent("com.android.server.startupservice.system").apply {
    putExtra("setting", "permission")
    putExtra("package", "com.example.cameraapp")
    putExtra("permission", "android.permission.CAMERA")
    putExtra("permission_mode", 2)  // Deny (Important: use 2)
}
context.sendBroadcast(intent)
```

### API Reference

#### Broadcast Action

**Action**: `com.android.server.startupservice.system`

#### Parameters

| Parameter         | Type   | Required | Description                                              |
|-------------------|--------|----------|----------------------------------------------------------|
| `setting`         | String | Yes      | Setting type. Use `"permission"` for permission control. |
| `package`         | String | Yes      | Package name of the target app.                          |
| `permission`      | String | Yes      | Permission name (e.g., `android.permission.CAMERA`).     |
| `permission_mode` | int    | Yes      | `1`=Grant, `2`=Deny.                                     |

**Detailed `permission_mode` values**:
- **1 (GRANT)**: Grants the permission. The app can use the corresponding feature.
- **2 (DENY)**: Denies the permission. The app cannot use the corresponding feature.

#### Supported Dangerous Permissions

This SDK supports all **Android Dangerous Permissions**. Key permissions include:

- **Camera**: `android.permission.CAMERA`
- **Location**: `android.permission.ACCESS_FINE_LOCATION`, `android.permission.ACCESS_COARSE_LOCATION`
- **Contacts**: `android.permission.READ_CONTACTS`, `android.permission.WRITE_CONTACTS`
- **Phone**: `android.permission.CALL_PHONE`, `android.permission.READ_CALL_LOG`, `android.permission.WRITE_CALL_LOG`, `android.permission.READ_PHONE_STATE`
- **Microphone**: `android.permission.RECORD_AUDIO`
- **Files/Media** (Android 12 and below): `android.permission.READ_EXTERNAL_STORAGE`, `android.permission.WRITE_EXTERNAL_STORAGE`
- **Media** (Android 13+): `android.permission.READ_MEDIA_IMAGES`, `android.permission.READ_MEDIA_VIDEO`, `android.permission.READ_MEDIA_AUDIO`
- **Calendar**: `android.permission.READ_CALENDAR`, `android.permission.WRITE_CALENDAR`
- **SMS**: `android.permission.READ_SMS`, `android.permission.SEND_SMS`
- **Sensors**: `android.permission.BODY_SENSORS`
- **Notifications** (Android 13+): `android.permission.POST_NOTIFICATIONS`
- **Other**: `android.permission.ACCESS_MEDIA_LOCATION`

#### Constraints

Permission control is **not possible** in the following cases:

1.  **Permission not declared by the app**: The target app must declare the permission in its `AndroidManifest.xml`.
2.  **System-fixed permissions**: Permissions with the `SYSTEM_FIXED` or `POLICY_FIXED` flag cannot be changed.
    -   E.g., The CAMERA permission for the system camera app, or the CALL_PHONE permission for the default phone app.
3.  **Install-time permissions**: Normal permissions are not subject to runtime control.

**How to check permission flags**:
```bash
adb shell dumpsys package [package_name] | findstr "[permission_name]"
```

Example output:
```
android.permission.CAMERA: granted=true, flags=[ SYSTEM_FIXED|GRANTED_BY_DEFAULT ]
```
In this case, control is not possible due to the `SYSTEM_FIXED` flag.

### Full Examples

#### Grant Permission

**Kotlin Example:**

```kotlin
// Grant CAMERA permission
val intent = Intent("com.android.server.startupservice.system").apply {
    putExtra("setting", "permission")
    putExtra("package", "com.example.cameraapp")
    putExtra("permission", "android.permission.CAMERA")
    putExtra("permission_mode", 1)  // Grant
}
context.sendBroadcast(intent)
```

**Java Example:**

```java
// Grant CAMERA permission
Intent intent = new Intent("com.android.server.startupservice.system");
intent.putExtra("setting", "permission");
intent.putExtra("package", "com.example.cameraapp");
intent.putExtra("permission", "android.permission.CAMERA");
intent.putExtra("permission_mode", 1);  // Grant
context.sendBroadcast(intent);
```

#### Deny Permission

**Kotlin Example:**

```kotlin
// Deny CAMERA permission
val intent = Intent("com.android.server.startupservice.system").apply {
    putExtra("setting", "permission")
    putExtra("package", "com.example.cameraapp")
    putExtra("permission", "android.permission.CAMERA")
    putExtra("permission_mode", 2)  // Deny (Important: use 2)
}
context.sendBroadcast(intent)
```

**Java Example:**

```java
// Deny CAMERA permission
Intent intent = new Intent("com.android.server.startupservice.system");
intent.putExtra("setting", "permission");
intent.putExtra("package", "com.example.cameraapp");
intent.putExtra("permission", "android.permission.CAMERA");
intent.putExtra("permission_mode", 2);  // Deny (Important: use 2)
context.sendBroadcast(intent);
```

#### Batch Permission Control

To control multiple permissions simultaneously, send a separate broadcast for each permission.

```kotlin
// Grant multiple permissions at once
fun grantMultiplePermissions(
    context: Context,
    packageName: String,
    permissions: List<String>
) {
    permissions.forEach { permission ->
        val intent = Intent("com.android.server.startupservice.system").apply {
            putExtra("setting", "permission")
            putExtra("package", packageName)
            putExtra("permission", permission)
            putExtra("permission_mode", 1)  // Grant
        }
        context.sendBroadcast(intent)
    }
}

// Example usage
grantMultiplePermissions(
    context,
    "com.example.app",
    listOf(
        "android.permission.CAMERA",
        "android.permission.RECORD_AUDIO",
        "android.permission.ACCESS_FINE_LOCATION"
    )
)
```

### Testing with ADB

#### Grant Permission

```bash
# Grant microphone permission to YouTube
adb shell am broadcast -a com.android.server.startupservice.system --es setting "permission" --es package "com.google.android.youtube" --es permission "android.permission.RECORD_AUDIO" --ei permission_mode 1  
```

#### Deny Permission

```bash
# Deny microphone permission to YouTube
adb shell am broadcast -a com.android.server.startupservice.system --es setting "permission" --es package "com.google.android.youtube" --es permission "android.permission.RECORD_AUDIO" --ei permission_mode 2
```

#### Check Permission Status

```bash
# Check status of a specific permission (Windows)
adb shell dumpsys package com.google.android.youtube | findstr "RECORD_AUDIO"

# Example output:
# android.permission.RECORD_AUDIO: granted=true, flags=[ POLICY_FIXED|USER_SENSITIVE_WHEN_GRANTED ]
```

```bash
# Check all runtime permissions (Windows)
adb shell dumpsys package com.google.android.youtube | findstr "granted"
```

### Troubleshooting

#### Permission change is not applied

**1. Check if the app declared the permission**

```bash
# Check permission on Windows
adb shell dumpsys package com.example.app | findstr "android.permission.CAMERA"

# If there is no output, the app has not declared the permission.
```

**2. Check permission flags**

```bash
adb shell dumpsys package com.example.app | findstr "CAMERA"

# Example output:
# android.permission.CAMERA: granted=true, flags=[ SYSTEM_FIXED|GRANTED_BY_DEFAULT ]
```

- If `SYSTEM_FIXED` or `POLICY_FIXED` flag is present, it cannot be controlled.
- This is often set for core permissions of system or default apps.

**3. Check if `permission_mode` value is correct**

```bash
# Incorrect example (using 0 to deny)
--ei permission_mode 0  # Restores to default (not a denial!)

# Correct example (deny)
--ei permission_mode 2  # Explicit denial
```

**4. Check system permission list**

```bash
# Check all dangerous permission groups
adb shell pm list permissions -g -d

# Check permissions requested by a specific app
adb shell dumpsys package com.example.app | findstr "requested permissions"
```

#### Common Error Scenarios

| Symptom                                              | Cause                                                       | Solution                                           |
|------------------------------------------------------|-------------------------------------------------------------|----------------------------------------------------|
| Log shows `result: true` but permission is unchanged | Using `permission_mode=0` (restores default)                | Use `permission_mode=2` (to deny)                  |
| Permission not in app's permission list              | App did not declare the permission in `AndroidManifest.xml` | Test with another app that declares the permission |
| `SYSTEM_FIXED` flag                                  | Core permission of a system app                             | Cannot be controlled, test with another app        |
| Permission changes but app behavior doesn't          | App is using a cached permission state                      | Force-stop and restart the app                     |
