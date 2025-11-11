# App Enable/Disable SDK

> **Note** <br>
> 
> Supported since StartUp version 6.2.21.

## Overview

This SDK allows external applications to enable or disable installed apps via a broadcast intent. 
A disabled app cannot be launched and does not consume system resources.

### Quick Start

#### Enable App

```kotlin
// Enable app
val intent = Intent("com.android.server.startupservice.system").apply {
    putExtra("setting", "application")
    putExtra("package_name", "com.google.android.gms")
    putExtra("enable", true)
}
context.sendBroadcast(intent)
```

#### Disable App

```kotlin
// Disable app
val intent = Intent("com.android.server.startupservice.system").apply {
    putExtra("setting", "application")
    putExtra("package_name", "com.example.unwantedapp")
    putExtra("enable", false)
}
context.sendBroadcast(intent)
```

### API Reference

#### Broadcast Action

**Action**: `com.android.server.startupservice.system`

#### Parameters

| Parameter      | Type    | Required | Description                                                 |
|----------------|---------|----------|-------------------------------------------------------------|
| `setting`      | String  | Yes      | Setting type. Use `"application"` for app control.          |
| `package_name` | String  | Yes      | Package name of the target app (e.g., `com.example.myapp`). |
| `enable`       | boolean | Yes      | `true` to enable, `false` to disable.                       |

### Full Examples

#### Enable App

**Kotlin Example:**

```kotlin
// Enable app
val intent = Intent("com.android.server.startupservice.system").apply {
    putExtra("setting", "application")
    putExtra("package_name", "com.google.android.calculator")
    putExtra("enable", true)
}
context.sendBroadcast(intent)
```

**Java Example:**

```java
// Enable app
Intent intent = new Intent("com.android.server.startupservice.system");
intent.putExtra("setting", "application");
intent.putExtra("package_name", "com.google.android.calculator");
intent.putExtra("enable", true);
context.sendBroadcast(intent);
```

#### Disable App

**Kotlin Example:**

```kotlin
// Disable app
val intent = Intent("com.android.server.startupservice.system").apply {
    putExtra("setting", "application")
    putExtra("package_name", "com.google.android.calculator")
    putExtra("enable", false)
}
context.sendBroadcast(intent)
```

**Java Example:**

```java
// Disable app
Intent intent = new Intent("com.android.server.startupservice.system");
intent.putExtra("setting", "application");
intent.putExtra("package_name", "com.google.android.calculator");
intent.putExtra("enable", false);
context.sendBroadcast(intent);
```

### Testing with ADB

#### Enable App

```bash
# Enable app
adb shell am broadcast -a com.android.server.startupservice.system --es setting "application" --es package_name "com.google.android.calculator" --ez enable true
```

#### Disable App

```bash
# Disable app
adb shell am broadcast -a com.android.server.startupservice.system --es setting "application" --es package_name "com.google.android.calculator" --ez enable false
```

### Notes

- System apps can also be disabled, but caution is advised as it may affect system stability.
- A disabled app will not run in the background and will not send notifications.
- To re-enable a disabled app, simply send the broadcast again with `enable: true`.

### Troubleshooting

If you encounter issues after disabling an app, check the following:

```bash
# 1. List disabled apps
adb shell pm list packages -d

# 2. Re-enable the app
adb shell pm enable com.example.app

# 3. Force-stop and then enable the app
adb shell am force-stop com.example.app
adb shell pm enable com.example.app
```
