# Volume and Sound SDK

## Overview

The Volume and Sound Settings SDK for Android-App-StartUp provides two APIs that allow external apps
to control the volume of various audio streams on the device via broadcast intents.

- **CONFIG API:** Used to save settings as JSON, which is necessary when settings need to be
  preserved after a reboot.
- **SYSTEM API:** Used for immediate, one-time volume changes without saving the settings.

---

## Broadcast Actions

### 1. CONFIG API

- **Action:** `com.android.server.startupservice.config`
- **Feature:** The volume changes immediately upon receiving the broadcast.

### 2. SYSTEM API

- **Action:** `com.android.server.startupservice.system`
- **Feature:** The volume changes immediately upon receiving the broadcast.

The two APIs are identical in operation, differing only in the action string.

---

## CONFIG API

Uses the `com.android.server.startupservice.config` action, and parameter names start with the
`volume_` prefix.

### 1. Media Volume

| Parameter      | Type | Range | Description                                            |
|----------------|------|-------|--------------------------------------------------------|
| `volume_media` | int  | 0-15  | Playback volume for media (music, videos, games, etc.) |

> **Compatibility**
> - Supported on all devices.

**ADB Test Example:**

```bash
# Set media volume to 10
adb shell am broadcast -a com.android.server.startupservice.config --es setting "volume" --ei volume_media 10
```

### 2. Ringer Volume

| Parameter         | Type | Range       | Description                                       |
|-------------------|------|-------------|---------------------------------------------------|
| `volume_ringtone` | int  | 0-7 or 0-15 | Incoming call volume. The range varies by device. |

> **Compatibility**
> - **Max value 15:** `SL10`, `SL10K`, `SL20`, `SL20K`, `SL20P`, `SL25`, `PC10`
> - **Max value 7:** All other models
>
> **Functional Constraint (Android 14+):**
> - If `volume_ringtone` is set to `0`, `volume_notification` is automatically set to `0`.
>
> **Functional Constraint (Android 13 and below):**
> - Independent control of `volume_ringtone` and `volume_notification` is not possible.

**ADB Test Example:**

```bash
# Set ringer volume to 5
adb shell am broadcast -a com.android.server.startupservice.config --es setting "volume" --ei volume_ringtone 5
```

### 3. Notification Volume

| Parameter             | Type | Range       | Description                                      |
|-----------------------|------|-------------|--------------------------------------------------|
| `volume_notification` | int  | 0-7 or 0-15 | Notification volume. The range varies by device. |

> **Compatibility**
> - **OS Dependency:** This parameter operates independently only on **Android 14 (API 34) and
    higher**.
> - **Backward Compatibility:** On Android 13 and below, controlling the notification volume via the
    `volume_notification` broadcast does not work. In this case, adjusting the ringer volume using
    the `volume_ringtone` broadcast will also adjust the notification volume.
> - **Max Value (Android 14+):**
>   - **Max value 15:** `SL10`, `SL10K`, `SL20`, `SL20K`, `SL20P`, `SL25`, `PC10`
>   - **Max value 7:** All other models
>   **Functional Constraint (Android 14+):**
> - If `volume_ringtone` is set to `0`, `volume_notification` cannot be set to a value greater than `0`.

**ADB Test Example:**

```bash
# Set notification volume to 5 (Android 14+)
adb shell am broadcast -a com.android.server.startupservice.config --es setting "volume" --ei volume_notification 5
```

### 4. Alarm Volume

| Parameter      | Type | Range       | Description                               |
|----------------|------|-------------|-------------------------------------------|
| `volume_alarm` | int  | 0-7 or 0-15 | Alarm volume. The range varies by device. |

> **Compatibility**
> - **Max value 15:** `SL10`, `SL10K`, `SL20`, `SL20K`, `SL20P`, `PC10`
> - **Max value 7:** All other models

**ADB Test Example:**

```bash
# Set alarm volume to 7
adb shell am broadcast -a com.android.server.startupservice.config --es setting "volume" --ei volume_alarm 7
```

### 5. Vibrate Mode

| Parameter         | Type    | Description                                                |
|-------------------|---------|------------------------------------------------------------|
| `volume_vibrator` | boolean | `true`: Enable vibrate mode, `false`: Disable vibrate mode |

> **Compatibility**
> - Supported on all devices.
>
> **Functional Constraint:**
> - When set to vibrate mode, `volume_ringtone` and `volume_notification` are automatically adjusted
    to 0.

**ADB Test Example:**

```bash
# Enable vibrate mode
adb shell am broadcast -a com.android.server.startupservice.config --es setting "volume" --ez volume_vibrator true
```

### CONFIG API Full Example

**Kotlin Example:**

```kotlin
// Configure multiple volume settings at once
val intent = Intent("com.android.server.startupservice.config").apply {
    putExtra("setting", "volume")
    putExtra("volume_media", 10)
    putExtra("volume_ringtone", 5)
    putExtra("volume_alarm", 7)
    putExtra("volume_vibrator", false)

    if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
        putExtra("volume_notification", 5)
    }
}
context.sendBroadcast(intent)
```

**Java Example:**

```java
// Configure multiple volume settings at once
Intent intent = new Intent("com.android.server.startupservice.config");
intent.putExtra("setting","volume");
intent.putExtra("volume_media",10);
intent.putExtra("volume_ringtone",5);
intent.putExtra("volume_alarm",7);
intent.putExtra("volume_vibrator",false);

if(android.os.Build.VERSION.SDK_INT >=android.os.Build.VERSION_CODES.UPSIDE_DOWN_CAKE){
    intent.putExtra("volume_notification",5);
}
context.sendBroadcast(intent);
```

**ADB Example:**

```bash
# Set and apply multiple volumes at once (based on Android 14+)
adb shell am broadcast -a com.android.server.startupservice.config --es setting "volume" --ei volume_media 10 --ei volume_ringtone 5 --ei volume_notification 5 --ei volume_alarm 7 --ez volume_vibrator false
```

---

## SYSTEM API

Uses the `com.android.server.startupservice.system` action, and parameter names do not have the
`volume_` prefix.

### 1. Media Volume

| Parameter | Type | Range | Description                                            |
|-----------|------|-------|--------------------------------------------------------|
| `media`   | int  | 0-15  | Playback volume for media (music, videos, games, etc.) |

> **Compatibility**
> - Supported on all devices.

**ADB Test Example:**

```bash
# Immediately set media volume to 10
adb shell am broadcast -a com.android.server.startupservice.system --es setting "volume" --ei media 10
```

### 2. Ringer Volume

| Parameter  | Type | Range       | Description                                       |
|------------|------|-------------|---------------------------------------------------|
| `ringtone` | int  | 0-7 or 0-15 | Incoming call volume. The range varies by device. |

> **Compatibility**
> - **Max value 15:** `SL10`, `SL10K`, `SL20`, `SL20K`, `SL20P`, `SL25`, `PC10`
> - **Max value 7:** All other models
>
> **Functional Constraint (Android 14+):**
> - If `ringtone` is set to `0`, `notification` is automatically set to `0`.
>
> **Functional Constraint (Android 13 and below):**
> - Independent control of `ringtone` and `notification` is not possible.

**ADB Test Example:**

```bash
# Immediately set ringer volume to 5
adb shell am broadcast -a com.android.server.startupservice.system --es setting "volume" --ei ringtone 5
```

### 3. Notification Volume

| Parameter      | Type | Range       | Description                                      |
|----------------|------|-------------|--------------------------------------------------|
| `notification` | int  | 0-7 or 0-15 | Notification volume. The range varies by device. |

> **Compatibility**
> - **OS Dependency:** This parameter operates independently only on **Android 14 (API 34) and
    higher**.
> - **Backward Compatibility:** On Android 13 and below, controlling the notification volume via the
    `notification` broadcast does not work. In this case, adjusting the ringer volume using the
    `ringtone` broadcast will also adjust the notification volume.
> - **Max Value (Android 14+):**
    >
- **Max value 15:** `SL10`, `SL10K`, `SL20`, `SL20K`, `SL20P`, `SL25`, `PC10`
>   - **Max value 7:** All other models
>
> **Functional Constraint (Android 14+):**
> - If `ringtone` is set to `0`, `notification` cannot be set to a value greater than `0`.

**ADB Test Example:**

```bash
# Immediately set notification volume to 5 (Android 14+)
adb shell am broadcast -a com.android.server.startupservice.system --es setting "volume" --ei notification 5
```

### 4. Alarm Volume

| Parameter | Type | Range       | Description                               |
|-----------|------|-------------|-------------------------------------------|
| `alarm`   | int  | 0-7 or 0-15 | Alarm volume. The range varies by device. |

> **Compatibility**
> - **Max value 15:** `SL10`, `SL10K`, `SL20`, `SL20K`, `SL20P`, `PC10`
> - **Max value 7:** All other models

**ADB Test Example:**

```bash
# Immediately set alarm volume to 7
adb shell am broadcast -a com.android.server.startupservice.system --es setting "volume" --ei alarm 7
```

### 5. Vibrate Mode

| Parameter  | Type    | Description                                                |
|------------|---------|------------------------------------------------------------|
| `vibrator` | boolean | `true`: Enable vibrate mode, `false`: Disable vibrate mode |

> **Compatibility**
> - Supported on all devices.
>
> **Functional Constraint:**
> - When set to vibrate mode, `ringtone` and `notification` are automatically adjusted to 0.

**ADB Test Example:**

```bash
# Enable vibrate mode
adb shell am broadcast -a com.android.server.startupservice.system --es setting "volume" --ez vibrator true
```

### SYSTEM API Full Example

**Kotlin Example:**

```kotlin
// Immediately set the media volume to 12
val intent = Intent("com.android.server.startupservice.system").apply {
    putExtra("setting", "volume")
    putExtra("media", 12)
}
context.sendBroadcast(intent)
```

**Java Example:**

```java
// Immediately set the ringer volume to maximum
Intent intent = new Intent("com.android.server.startupservice.system");
intent.putExtra("setting","volume");
intent.putExtra("ringtone",7); // Max value needs to be checked depending on the device model
context.sendBroadcast(intent);
```

**ADB Example:**

```bash
# Immediately set media volume to 12 and alarm volume to 5
adb shell am broadcast -a com.android.server.startupservice.system --es setting "volume" --ei media 12 --ei alarm 5
```

---
