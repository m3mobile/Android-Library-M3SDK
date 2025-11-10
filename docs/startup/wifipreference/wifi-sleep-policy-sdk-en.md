# Wi-Fi Sleep Policy SDK

> **Note** <br>
> Supported from StartUp version 6.0.6 BETA.

Controls the Wi-Fi behavior when the screen is off (standby mode).

## Broadcast Actions

### Settings API

| Action                                         | Purpose                            |
|------------------------------------------------|------------------------------------|
| `com.android.server.startupservice.config`     | Change Wi-Fi Sleep Policy settings |

---

## API Details

### Parameters

| Parameter | Type   | Value         | Description        |
|-----------|--------|---------------|--------------------|
| `setting` | String | `wifi_sleep`  | Settings Key       |
| `value`   | int    | `0`, `1`, `2` | Sleep Policy Mode  |

### Sleep Policy Modes

| Value | Mode                 | Description                                                                    |
|-------|----------------------|--------------------------------------------------------------------------------|
| `0`   | Never                | Keeps Wi-Fi connection even when the screen is off (high battery consumption). |
| `1`   | Only when plugged in | Keeps Wi-Fi on only when plugged into an AC power source.                      |
| `2`   | Always               | Disables Wi-Fi when the screen turns off (saves battery).                      |

### Kotlin Code Example

```kotlin
// Set Wi-Fi Sleep Policy - Never
fun setWifiSleepPolicyNever(context: Context) {
    val intent = Intent("com.android.server.startupservice.config").apply {
        putExtra("setting", "wifi_sleep")
        putExtra("value", 0) // Never
    }
    context.sendBroadcast(intent)
}

// Set Wi-Fi Sleep Policy - Always
fun setWifiSleepPolicyAlways(context: Context) {
    val intent = Intent("com.android.server.startupservice.config").apply {
        putExtra("setting", "wifi_sleep")
        putExtra("value", 2) // Always
    }
    context.sendBroadcast(intent)
}

// Set Wi-Fi Sleep Policy - Only when plugged in
fun setWifiSleepPolicyPluggedOnly(context: Context) {
    val intent = Intent("com.android.server.startupservice.config").apply {
        putExtra("setting", "wifi_sleep")
        putExtra("value", 1) // Only when plugged in
    }
    context.sendBroadcast(intent)
}
```

### ADB Command Example

```bash
# Keep Wi-Fi on always (Sleep Policy: Never)
adb shell am broadcast -a com.android.server.startupservice.config --es setting "wifi_sleep" --ei value 0
```

```bash
# Keep Wi-Fi on only when plugged in (Sleep Policy: Only when plugged in)
adb shell am broadcast -a com.android.server.startupservice.config --es setting "wifi_sleep" --ei value 1
```

```bash
# Disable Wi-Fi when screen is off (Sleep Policy: Always)
adb shell am broadcast -a com.android.server.startupservice.config --es setting "wifi_sleep" --ei value 2
```

### Response Information

- **Response Format**: No separate response broadcast.
