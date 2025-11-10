# Wi-Fi Captive Portal SDK

Controls the detection of captive portals (authentication pages) on public Wi-Fi networks.

> [!WARNING]
> Supported from StartUp version 6.0.6 BETA.
>
> [Available on Android 11 and later](https://developer.android.com/about/versions/11/features/captive-portal),
> and is not supported on SL20 devices.

## Broadcast Actions

### Settings API

| Action                                         | Purpose                        | Features                               |
|------------------------------------------------|--------------------------------|----------------------------------------|
| `com.android.server.startupservice.config`     | Change Captive Portal settings | Saved in JSON, persists after reboot   |

---

## API Details

### Parameters

| Parameter | Type   | Value            | Description    |
|-----------|--------|------------------|----------------|
| `setting` | String | `captive_portal` | Settings Key   |
| `value`   | int    | `0`, `1`         | Enable/Disable |

### Feature Description

| Value | Status    | Behavior                                                                        |
|-------|-----------|---------------------------------------------------------------------------------|
| `0`   | Disabled  | Does not detect captive portals; only performs a standard internet connection check. |
| `1`   | Enabled   | Automatically detects captive portals and provides a notification if login is required. |

### Use Cases

- **Enabled (1)**: Environments with many public Wi-Fi networks like cafes, airports, and hotels.
- **Disabled (0)**: Environments where authentication is not required, such as corporate networks or home Wi-Fi.

### Kotlin Code Example

```kotlin
// Enable Captive Portal Detection
fun enableCaptivePortalDetection(context: Context) {
    val intent = Intent("com.android.server.startupservice.config").apply {
        putExtra("setting", "captive_portal")
        putExtra("value", 1) // Enable
    }
    context.sendBroadcast(intent)
}

// Disable Captive Portal Detection
fun disableCaptivePortalDetection(context: Context) {
    val intent = Intent("com.android.server.startupservice.config").apply {
        putExtra("setting", "captive_portal")
        putExtra("value", 0) // Disable
    }
    context.sendBroadcast(intent)
}
```

### ADB Command Example

```bash
# Enable Captive Portal
adb shell am broadcast -a com.android.server.startupservice.config --es setting "captive_portal" --ei value 1
```

```bash
# Disable Captive Portal
adb shell am broadcast -a com.android.server.startupservice.config --es setting "captive_portal" --ei value 0
```

### Response Information

- **Response Format**: No separate response broadcast.
- **Monitoring**: Can be checked in System Settings > Network > Wi-Fi > Advanced.
