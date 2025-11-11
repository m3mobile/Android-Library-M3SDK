# APK Installation SDK

> **Note** <br> 
> 
> Supported since Startup version 5.3.4.

## Overview

This SDK provides an API that allows external applications to install APK files on the device via a broadcast intent. 
It supports two methods: installing from a local file path or downloading and installing from a URL.

### Quick Start

#### Basic Usage (Local File)

```kotlin
// Install APK from a local file
val intent = Intent("com.android.server.startupservice.system").apply {
    putExtra("setting", "apk_install")
    putExtra("type", 0)  // Local file
    putExtra("path", "/sdcard/downloads/myapp.apk")
}
context.sendBroadcast(intent)
```

#### Basic Usage (URL)

```kotlin
// Download and install APK from a URL
val intent = Intent("com.android.server.startupservice.system").apply {
    putExtra("setting", "apk_install")
    putExtra("type", 1)  // URL download
    putExtra("url", "https://github.com/skydoves/pokedex-compose/releases/download/1.0.3/pokedex-compose.apk")
}
context.sendBroadcast(intent)
```

### API Reference

#### Broadcast Action

**Action**: `com.android.server.startupservice.system`

#### Parameters

| Parameter | Type   | Required             | Description                                                                                                         |
|-----------|--------|----------------------|---------------------------------------------------------------------------------------------------------------------|
| `setting` | String | Yes                  | Setting type. Use `"apk_install"` for APK installation.                                                             |
| `type`    | int    | Yes                  | Installation method. `0`: Local file, `1`: URL download.                                                            |
| `path`    | String | Required if `type=0` | Absolute path of the APK file (e.g., `/sdcard/downloads/myapp.apk`).                                                |
| `url`     | String | Required if `type=1` | APK download URL (e.g., `https://github.com/skydoves/pokedex-compose/releases/download/1.0.3/pokedex-compose.apk`). |

### Full Examples

#### Local File Installation

**Kotlin Example:**

```kotlin
// Install APK from a local file
val intent = Intent("com.android.server.startupservice.system").apply {
    putExtra("setting", "apk_install")
    putExtra("type", 0)  // Local file
    putExtra("path", "/sdcard/downloads/myapp.apk")
}
context.sendBroadcast(intent)
```

**Java Example:**
```java
// Install APK from a local file
Intent intent = new Intent("com.android.server.startupservice.system");
intent.putExtra("setting", "apk_install");
intent.putExtra("type", 0);  // Local file
intent.putExtra("path", "/sdcard/downloads/myapp.apk");
context.sendBroadcast(intent);
```

#### Download and Install from URL

**Kotlin Example:**

```kotlin
// Download and install APK from a URL
val intent = Intent("com.android.server.startupservice.system").apply {
    putExtra("setting", "apk_install")
    putExtra("type", 1)  // URL download
    putExtra("url", "https://github.com/skydoves/pokedex-compose/releases/download/1.0.3/pokedex-compose.apk")
}
context.sendBroadcast(intent)
```

**Java Example:**

```java
// Download and install APK from a URL
Intent intent = new Intent("com.android.server.startupservice.system");
intent.putExtra("setting", "apk_install");
intent.putExtra("type", 1);  // URL download
intent.putExtra("url", "https://github.com/skydoves/pokedex-compose/releases/download/1.0.3/pokedex-compose.apk");
context.sendBroadcast(intent);
```

### Testing with ADB

#### Local File Installation

```bash
# Install APK from a local file
adb shell am broadcast -a com.android.server.startupservice.system --es setting "apk_install" --ei type 0 --es path "/sdcard/downloads/myapp.apk"
```

#### Download and Install from URL

```bash
# Download and install APK from a URL
adb shell am broadcast -a com.android.server.startupservice.system --es setting "apk_install" --ei type 1 --es url "https://github.com/skydoves/pokedex-compose/releases/download/1.0.3/pokedex-compose.apk"
```

### Notes

- When downloading from a URL, the APK is saved in the `/data/downloads/` directory.
- URL installation requires a network connection.
- Download progress can be monitored via broadcast (`android.app.DownloadManager.ACTION_DOWNLOAD_COMPLETE`).
- Attempting to enable an app or set its permissions immediately after installation may cause timing issues. Ensure installation is complete before proceeding with subsequent actions.

### Troubleshooting

If APK installation fails, check the following:

```bash
# 1. Check logs
adb logcat | grep -i "apk\|install"

# 2. Check if the file exists
adb shell ls -la /data/downloads/myapp.apk

# 3. Check file permissions
adb shell stat /data/downloads/myapp.apk

# 4. Verify APK integrity
adb shell md5sum /data/downloads/myapp.apk
```
