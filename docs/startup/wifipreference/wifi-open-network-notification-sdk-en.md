# Wi-Fi Open Network Notification SDK

> **Note** <br>
> Supported from StartUp version 6.0.6 BETA.

Controls the notification feature for detecting unsecured Wi-Fi networks.

## Broadcast Actions

### Settings API

| Action                                         | Purpose                                   | Features                             |
|------------------------------------------------|-------------------------------------------|--------------------------------------|
| `com.android.server.startupservice.config`     | Change Open Network Notification settings | Saved in JSON, persists after reboot |
| `com.android.server.startupservice.config.fin` | Settings completion signal                | Apply all config settings at once    |

---

## API Details

### Parameters

| Parameter | Type   | Value            | Description    |
|-----------|--------|------------------|----------------|
| `setting` | String | `wifi_open_noti` | Settings Key   |
| `value`   | int    | `0`, `1`         | Enable/Disable |

### Feature Description

| Value | Status    | Behavior                                                              |
|-------|-----------|-----------------------------------------------------------------------|
| `0`   | Disabled  | Does not notify about detected Open Networks (unsecured).             |
| `1`   | Enabled   | Automatically detects and displays notifications for Open Networks.   |

### Use Cases

- **Enabled (1)**: General user environments where raising security awareness is needed.
- **Disabled (0)**: Controlled environments (corporate/educational) where security settings are already configured.

### Kotlin Code Example

```kotlin
// Enable Open Network Notification
fun enableOpenNetworkNotification(context: Context) {
    val intent = Intent("com.android.server.startupservice.config").apply {
        putExtra("setting", "wifi_open_noti")
        putExtra("value", 1) // Enable
    }
    context.sendBroadcast(intent)
}

// Disable Open Network Notification
fun disableOpenNetworkNotification(context: Context) {
    val intent = Intent("com.android.server.startupservice.config").apply {
        putExtra("setting", "wifi_open_noti")
        putExtra("value", 0) // Disable
    }
    context.sendBroadcast(intent)
}
```

### ADB Command Example

```bash
# Enable Open Network Notification
adb shell am broadcast -a com.android.server.startupservice.config --es setting "wifi_open_noti" --ei value 1
```

```bash
# Disable Open Network Notification
adb shell am broadcast -a com.android.server.startupservice.config --es setting "wifi_open_noti" --ei value 0
```

### Response Information

- **Response Format**: No separate response broadcast.
- **Application Time**: Within about 1-2 seconds after receiving the `config.fin` action.
- **Notification Behavior**: Displays an "Open network available" notification in the system status bar.
