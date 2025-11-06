# Wakeup Control SDK (Deprecated)

>**Note:** This feature is available in KeyTool V1.2.5 or higher and only on SL20P.

## Overview

This SDK allows external Android applications to enable or disable the Wake-up function for specific physical keys (Left/Right Scan keys) through broadcast communication with the KeyToolSL20 application.

**Warning: This feature is deprecated.**

This receiver (`WakeupControlReceiver`) exists solely to maintain backward compatibility with existing clients (DIXI).

**For new development, you must use the integrated API, `KeySettingReceiver`.** `KeySettingReceiver` provides comprehensive control over all keys, including Wake-up function settings. For more details, please refer to the `KEY_SETTING_SDK_EN.md` document.

### Quick Start

#### Java Example

```java
// Enable Wake-up for the Left Scan key
Intent intent = new Intent("net.m3.keytool.WAKEUP_CONTROL_LEFT");
intent.putExtra("wakeup_enable", true);
context.sendBroadcast(intent);

// Disable Wake-up for the Right Scan key
Intent intentRight = new Intent("net.m3.keytool.WAKEUP_CONTROL_RIGHT");
intentRight.putExtra("wakeup_enable", false);
context.sendBroadcast(intentRight);
```

#### Kotlin Example

```kotlin
// Enable Wake-up for the Left Scan key
val intent = Intent("net.m3.keytool.WAKEUP_CONTROL_LEFT").apply {
    putExtra("wakeup_enable", true)
}
context.sendBroadcast(intent)

// Disable Wake-up for the Right Scan key
val intentRight = Intent("net.m3.keytool.WAKEUP_CONTROL_RIGHT").apply {
    putExtra("wakeup_enable", false)
}
context.sendBroadcast(intentRight)
```

## API Reference

### Broadcast Actions

| Action                                | Description                              |
|---------------------------------------|------------------------------------------|
| `net.m3.keytool.WAKEUP_CONTROL_LEFT`  | Controls Wake-up for the Left Scan key.  |
| `net.m3.keytool.WAKEUP_CONTROL_RIGHT` | Controls Wake-up for the Right Scan key. |

### Parameters

| Parameter       | Type    | Required | Description                                          |
|-----------------|---------|----------|------------------------------------------------------|
| `wakeup_enable` | boolean | Yes      | Set to `true` to enable Wake-up, `false` to disable. |

## Testing with ADB

You can test the Wake-up setting feature using ADB (Android Debug Bridge) commands from the terminal.

### Enable Left Scan Key Wake-up

```bash
adb shell am broadcast -a net.m3.keytool.WAKEUP_CONTROL_LEFT --ez wakeup_enable true
```

### Disable Left Scan Key Wake-up

```bash
adb shell am broadcast -a net.m3.keytool.WAKEUP_CONTROL_LEFT --ez wakeup_enable false
```

### Enable Right Scan Key Wake-up

```bash
adb shell am broadcast -a net.m3.keytool.WAKEUP_CONTROL_RIGHT --ez wakeup_enable true
```

### Disable Right Scan Key Wake-up

```bash
adb shell am broadcast -a net.m3.keytool.WAKEUP_CONTROL_RIGHT --ez wakeup_enable false
```

## Limitations

- This SDK is only applicable to the **SL20P model**.
- Control is limited to the Left Scan (`LSCAN`) and Right Scan (`RSCAN`) keys.
- This feature is **Deprecated** and not recommended for new development. For new projects, please refer to the `KEY_SETTING_SDK_EN.md` document and use the `com.m3.keytoolsl20.ACTION_SET_KEY` action.
