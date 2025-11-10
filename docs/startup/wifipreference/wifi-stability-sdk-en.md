# Wi-Fi Stability SDK

Sets the stability level of the Wi-Fi connection. Controls the reconnection policy based on signal strength changes.

> **Note** <br>
> **Not compatible with Android 13 and higher** <br>
> Due to internal Wi-Fi policy changes starting from Android 13 (API 33), the stability settings via this SDK are no longer effective.

## Broadcast Actions

### Settings API

| Action                                         | Purpose                         |
|------------------------------------------------|---------------------------------|
| `com.android.server.startupservice.config`     | Change Wi-Fi Stability settings |

---

## API Details

### Parameters

| Parameter | Type   | Value            | Description     |
|-----------|--------|------------------|-----------------|
| `setting` | String | `wifi_stability` | Settings Key    |
| `value`   | int    | `1`, `2`         | Stability Mode  |

### Stability Modes

| Value | Mode   | Description                                                                                               |
|-------|--------|-----------------------------------------------------------------------------------------------------------|
| `1`   | Normal | Normal Wi-Fi stability (occasionally reconnects when the signal is weak).                                 |
| `2`   | High   | High stability (tries to maintain the connection even with a weak signal, increased battery consumption). |

### Kotlin Code Example

```kotlin
// Set Wi-Fi Stability - Normal Mode
fun setWifiStabilityNormal(context: Context) {
    val intent = Intent("com.android.server.startupservice.config").apply {
        putExtra("setting", "wifi_stability")
        putExtra("value", 1) // Normal
    }
    context.sendBroadcast(intent)
}

// Set Wi-Fi Stability - High Stability
fun setWifiStabilityHigh(context: Context) {
    val intent = Intent("com.android.server.startupservice.config").apply {
        putExtra("setting", "wifi_stability")
        putExtra("value", 2) // High
    }
    context.sendBroadcast(intent)
}
```

### ADB Command Example

```bash
# Set Wi-Fi Stability - Normal Mode
adb shell am broadcast -a com.android.server.startupservice.config --es setting "wifi_stability" --ei value 1
```

```bash
# Set Wi-Fi Stability - High Stability
adb shell am broadcast -a com.android.server.startupservice.config --es setting "wifi_stability" --ei value 2
```

### Response Information

- **Response Format**: No separate response broadcast.
