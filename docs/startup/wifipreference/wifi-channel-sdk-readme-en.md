# Wi-Fi Channel Configuration SDK

> **Note** <br>
> Supported from StartUp version 6.0.6 BETA. <br>
> Not supported on SM15, SL10, SL10K devices.

## Overview

This SDK allows external Android applications to restrict the device's Wi-Fi scanning and connection to specific channels through broadcast communication with the StartUp app.

By limiting Wi-Fi channels, the device will only scan for and connect to Access Points (APs) on the specified channels. This can improve connection speed by avoiding congested channels or be used to enforce specific network policies.

Supported Channels:
- **2.4 GHz Band**: Channels 1 - 13
- **5 GHz Band**: Channels 36, 40, 44, 48, 52, 56, 60, 64, 100, 104, 108, 112, 116, 120, 124, 128, 132, 136, 140, 144, 149, 153, 157, 161, 165

### Quick Start

#### Basic Usage

```java
// Restrict Wi-Fi channels to 1, 6, 11 (2.4GHz) and 36, 40 (5GHz)
Intent intent = new Intent("com.android.server.startupservice.config");
intent.putExtra("setting", "wifi_channel");
String[] channels = {"1", "6", "11", "36", "40"};
intent.putExtra("value", channels);
context.sendBroadcast(intent);

// Use only 2.4GHz channels (1, 6, 11)
Intent intent24 = new Intent("com.android.server.startupservice.config");
intent24.putExtra("setting", "wifi_channel");
String[] channels24 = {"1", "6", "11"};
intent24.putExtra("value", channels24);
context.sendBroadcast(intent24);

// Use only 5GHz channels (36, 40, 149, 153)
Intent intent5 = new Intent("com.android.server.startupservice.config");
intent5.putExtra("setting", "wifi_channel");
String[] channels5 = {"36", "40", "149", "153"};
intent5.putExtra("value", channels5);
context.sendBroadcast(intent5);
```

### API Reference

#### Broadcast Action

**Action**: `com.android.server.startupservice.config`

#### Parameters

| Parameter | Type     | Required | Description                                                                   |
|-----------|----------|----------|-------------------------------------------------------------------------------|
| `setting` | String   | Yes      | Must be set to `"wifi_channel"`.                                              |
| `value`   | String[] | Yes      | A string array of Wi-Fi channel numbers to enable (e.g., `{"1", "6", "11"}`). |

---

### Detailed Configuration Guide

#### Restricting Wi-Fi Channels

This setting limits Wi-Fi scanning and connections to a specific list of channels. You can specify both 2.4 GHz and 5 GHz channels simultaneously.

-   **`setting` value**: `"wifi_channel"`
-   **`value` type**: `String[]` (String array)
-   **`value` description**: A list of channel numbers to activate.

#### 2.4 GHz Channels (Channels 1 - 14)

| Channel | Center Frequency | Region       | Notes                                 |
|---------|------------------|--------------|---------------------------------------|
| 1       | 2412 MHz         | Worldwide    | Non-overlapping channel (Recommended) |
| 2       | 2417 MHz         | Worldwide    |                                       |
| 3       | 2422 MHz         | Worldwide    |                                       |
| 4       | 2427 MHz         | Worldwide    |                                       |
| 5       | 2432 MHz         | Worldwide    |                                       |
| 6       | 2437 MHz         | Worldwide    | Non-overlapping channel (Recommended) |
| 7       | 2442 MHz         | Worldwide    |                                       |
| 8       | 2447 MHz         | Worldwide    |                                       |
| 9       | 2452 MHz         | Worldwide    |                                       |
| 10      | 2457 MHz         | Worldwide    |                                       |
| 11      | 2462 MHz         | Worldwide    | Non-overlapping channel (Recommended) |
| 12      | 2467 MHz         | Europe, Asia |                                       |
| 13      | 2472 MHz         | Europe, Asia |                                       |
| 14      | 2484 MHz         | Japan only   | Special channel (802.11b only)        |

**2.4 GHz Channel Selection Guide**:
- **Non-overlapping Channels (1, 6, 11)**: Recommended combination to minimize interference.
- **Channels 12, 13**: Available only in certain countries (requires correct country code setting).
- **Channel 14**: Available only in Japan and is exclusive to 802.11b.

#### 5 GHz Channels

The 5 GHz band offers more channels and is generally less congested.

**UNII-1 (Indoor, Low Power)**

| Channel | Center Frequency | Bandwidth |
|---------|------------------|-----------|
| 36      | 5180 MHz         | 20 MHz    |
| 40      | 5200 MHz         | 20 MHz    |
| 44      | 5220 MHz         | 20 MHz    |
| 48      | 5240 MHz         | 20 MHz    |

**UNII-2 (DFS Required)**

| Channel | Center Frequency | Bandwidth | Notes       |
|---------|------------------|-----------|-------------|
| 52      | 5260 MHz         | 20 MHz    | DFS Channel |
| 56      | 5280 MHz         | 20 MHz    | DFS Channel |
| 60      | 5300 MHz         | 20 MHz    | DFS Channel |
| 64      | 5320 MHz         | 20 MHz    | DFS Channel |
| 100     | 5500 MHz         | 20 MHz    | DFS Channel |
| ...     | ...              | ...       | ...         |
| 144     | 5720 MHz         | 20 MHz    | DFS Channel |

**UNII-3 (Outdoor, High Power)**

| Channel | Center Frequency | Bandwidth | Notes                 |
|---------|------------------|-----------|-----------------------|
| 149     | 5745 MHz         | 20 MHz    | Non-DFS (Recommended) |
| 153     | 5765 MHz         | 20 MHz    | Non-DFS (Recommended) |
| 157     | 5785 MHz         | 20 MHz    | Non-DFS (Recommended) |
| 161     | 5805 MHz         | 20 MHz    | Non-DFS (Recommended) |
| 165     | 5825 MHz         | 20 MHz    | Non-DFS (Recommended) |

**5 GHz Channel Selection Guide**:
- **Recommended Non-DFS Channels**: 36, 40, 44, 48, 149, 153, 157, 161, 165.
  - These channels do not require DFS (Dynamic Frequency Selection), leading to faster and more stable connections.
- **DFS Channels**: Channels in the 52-144 range.
  - These channels require a DFS scan (can take over a minute) before use and may switch automatically if radar signals are detected, causing temporary disconnections.

---

### Common Use Cases

#### Scenario 1: Use Only 2.4 GHz Non-overlapping Channels

To minimize interference, use only the non-overlapping 2.4 GHz channels (1, 6, 11).

```java
Intent intent = new Intent("com.android.server.startupservice.config");
intent.putExtra("setting", "wifi_channel");
String[] channels = {"1", "6", "11"};
intent.putExtra("value", channels);
context.sendBroadcast(intent);
```

#### Scenario 2: Use Only 5 GHz Non-DFS Channels

For fast and stable connections, use only the 5 GHz Non-DFS channels.

```java
Intent intent = new Intent("com.android.server.startupservice.config");
intent.putExtra("setting", "wifi_channel");
String[] channels = {"36", "40", "44", "48", "149", "153", "157", "161", "165"};
intent.putExtra("value", channels);
context.sendBroadcast(intent);
```

---

### Full Example

#### Client App Implementation

```java
import android.content.Context;
import android.content.Intent;
import android.util.Log;
import java.util.Arrays;

public class WifiChannelController {
    private Context context;

    public WifiChannelController(Context context) {
        this.context = context;
    }

    /**
     * Set allowed Wi-Fi channels.
     *
     * @param channels An array of channel numbers to enable (e.g., {"1", "6", "149"}).
     */
    public void setWifiChannels(String[] channels) {
        for (String channel : channels) {
            if (!isValidChannel(channel)) {
                Log.e("WifiChannelController", "Invalid channel detected: " + channel);
                return;
            }
        }

        Intent intent = new Intent("com.android.server.startupservice.config");
        intent.putExtra("setting", "wifi_channel");
        intent.putExtra("value", channels);
        context.sendBroadcast(intent);

        Log.i("WifiChannelController", "Wi-Fi channels set to: " + Arrays.toString(channels));
    }

    /**
     * Clears all channel restrictions by sending an empty array.
     */
    public void clearChannelRestrictions() {
        setWifiChannels(new String[]{});
    }

    private boolean isValidChannel(String channel) {
        try {
            int ch = Integer.parseInt(channel);
            if (ch >= 1 && ch <= 14) return true; // 2.4 GHz
            int[] valid5GHz = {36, 40, 44, 48, 52, 56, 60, 64, 100, 104, 108, 112, 116, 120, 124, 128, 132, 136, 140, 144, 149, 153, 157, 161, 165};
            for (int validCh : valid5GHz) {
                if (ch == validCh) return true;
            }
            return false;
        } catch (NumberFormatException e) {
            return false;
        }
    }
}
```

---

### Testing with ADB

#### Set 2.4 GHz Channels

```bash
# Set non-overlapping channels (1, 6, 11)
adb shell am broadcast -a com.android.server.startupservice.config --es setting "wifi_channel" --esa value "1,6,11"
```

#### Set 5 GHz Channels

```bash
# Set 5GHz Non-DFS channels
adb shell am broadcast -a com.android.server.startupservice.config --es setting "wifi_channel" --esa value "36,40,44,48,149,153,157,161,165"
```

#### Clear Restrictions

```bash
# Send an empty array to clear all channel restrictions
adb shell am broadcast -a com.android.server.startupservice.config --es setting "wifi_channel" --esa value ""
```

---

### Important Notes

1.  **Country Code**: The availability of Wi-Fi channels depends on the device's country code setting. Ensure the correct country code is set before configuring channels.
2.  **Empty Array**: Sending an empty array for the `value` parameter will remove all channel restrictions, enabling all available channels.
3.  **Invalid Channels**: If an unsupported channel number is included in the array, it will be ignored.
4.  **DFS Channels**: Channels in the 52-144 range require DFS scans, which can delay connection and are not recommended for time-sensitive applications.
5.  **Restart Required**: After changing the channel configuration, toggling Wi-Fi off and on or restarting the device may be necessary for the settings to take full effect.
6.  **ADB Array Format**: When using ADB, pass string arrays with the `--esa` flag and separate values with a comma (no spaces).
