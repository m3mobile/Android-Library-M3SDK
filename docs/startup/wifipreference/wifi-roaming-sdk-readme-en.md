# Wi-Fi Roaming Configuration SDK

> **Note** <br>
> Supported from StartUp version 6.0.6 BETA. <br>
> SL10 and SL10K devices are not supported.

## Overview

This SDK allows external Android applications to control the device's Wi-Fi roaming behavior through broadcast communication with the StartUp app.

Wi-Fi roaming is the process by which a device automatically switches from its currently connected Access Point (AP) to another AP that offers a stronger signal. This SDK provides control over two key parameters that govern this behavior:

-   **Roaming Trigger**: The RSSI threshold at which the device starts scanning for a new AP.
-   **Roaming Delta**: The minimum signal strength difference required for the device to switch to a new AP.

These two settings work together to define the device's roaming policy.

### Quick Start

#### Basic Usage

```java
// Set the Roaming Trigger to index 1 (-75 dBm)
Intent intentTrigger = new Intent("com.android.server.startupservice.config");
intentTrigger.putExtra("setting", "wifi_roam_trigger");
intentTrigger.putExtra("value", "1");
context.sendBroadcast(intentTrigger);

// Set the Roaming Delta to index 4 (10 dB)
Intent intentDelta = new Intent("com.android.server.startupservice.config");
intentDelta.putExtra("setting", "wifi_roam_delta");
intentDelta.putExtra("value", "4");
context.sendBroadcast(intentDelta);
```

### API Reference

#### Broadcast Action

**Action**: `com.android.server.startupservice.config`

#### Parameters

| Parameter | Type   | Required | Description                                                                          |
|-----------|--------|----------|--------------------------------------------------------------------------------------|
| `setting` | String | Yes      | The type of roaming setting to change: `"wifi_roam_trigger"` or `"wifi_roam_delta"`. |
| `value`   | int    | Yes      | The configuration value (integer index).                                             |

---

### Detailed Configuration Guide

#### 1. Roaming Trigger (Minimum Wi-Fi Signal Strength)

This setting prevents the device from attempting to connect to APs with a signal strength (RSSI) at or below a certain threshold. It effectively defines when to start looking for a better connection.

-   **`setting` value**: `"wifi_roam_trigger"`
-   **`value` type**: `int` (index)
-   **`value` options**:

| Index | RSSI Threshold | Description                                    | Use Case                                  |
|-------|----------------|------------------------------------------------|-------------------------------------------|
| `0`   | -80 dBm        | Maintain connection until signal is very weak. | Prioritizing connection stability.        |
| `1`   | -75 dBm        | Actively find a new AP when signal weakens.    | Environments with many APs; fast roaming. |
| `2`   | -70 dBm        | Moderate roaming behavior (Recommended).       | General use cases.                        |
| `3`   | -65 dBm        | Start roaming when signal is slightly weak.    | Prioritizing signal quality.              |
| `4`   | -60 dBm        | Only maintain very strong signal connections.  | When only the best signal is acceptable.  |

**Understanding RSSI**:
-   RSSI (Received Signal Strength Indicator) is measured in dBm.
-   Values closer to 0 indicate a stronger signal.
-   -60 dBm: Excellent signal
-   -70 dBm: Good signal
-   -80 dBm: Fair signal

#### 2. Roaming Delta

The device will only switch to a new AP if its signal strength is greater than the current AP's signal by at least this delta.

-   **`setting` value**: `"wifi_roam_delta"`
-   **`value` type**: `int` (index)
-   **`value` options**:

| Index | Signal Strength Difference | Description                                  | Use Case                                      |
|-------|----------------------------|----------------------------------------------|-----------------------------------------------|
| `0`   | 30 dB                      | Roam only when the new signal is much better. | Extremely stable connection required.         |
| `1`   | 25 dB                      | Roam only for a large signal improvement.    | Minimizing roaming frequency.                 |
| `2`   | 20 dB                      | Roam for a significant improvement.          | Balance between stability and quality.        |
| `3`   | 15 dB                      | Roam for a moderate improvement.             | General environments.                         |
| `4`   | 10 dB                      | Roam for a reasonable improvement (Recommended).| Balanced roaming behavior.                  |
| `5`   | 5 dB                       | Roam even for a small improvement.           | Always maintain the best connection quality.  |
| `6`   | 0 dB                       | Roam to any AP with a better signal.         | Hyper-aggressive roaming (not recommended).   |

---

### Roaming Policy Combination Guide

It is crucial to select the right combination of Roaming Trigger and Roaming Delta for your specific use case.

#### Recommended Combinations

| Scenario               | Trigger Index | Delta Index | Trigger Value | Delta Value | Description                                   |
|------------------------|---------------|-------------|---------------|-------------|-----------------------------------------------|
| **Aggressive Roaming** | 1             | 5           | -75 dBm       | 5 dB        | Quickly switch to a better AP.                |
| **Moderate (Default)** | 2             | 4           | -70 dBm       | 10 dB       | Balanced roaming behavior.                    |
| **Conservative**       | 0             | 3           | -80 dBm       | 15 dB       | Minimize unnecessary roaming.                 |

---

### Full Example

#### Client App Implementation

```java
import android.content.Context;
import android.content.Intent;
import android.util.Log;

public class WifiRoamingController {
    private Context context;

    public WifiRoamingController(Context context) {
        this.context = context;
    }

    /**
     * Sets the Roaming Trigger.
     *
     * @param triggerIndex Index (0: -80dBm, 1: -75dBm, 2: -70dBm, 3: -65dBm, 4: -60dBm)
     */
    public void setRoamTrigger(int triggerIndex) {
        if (triggerIndex < 0 || triggerIndex > 4) {
            Log.e("WifiRoamingController", "Invalid roam trigger index: " + triggerIndex);
            return;
        }
        setRoamingValue("wifi_roam_trigger", triggerIndex);
    }

    /**
     * Sets the Roaming Delta.
     *
     * @param deltaIndex Index (0: 30dB, 1: 25dB, ..., 6: 0dB)
     */
    public void setRoamDelta(int deltaIndex) {
        if (deltaIndex < 0 || deltaIndex > 6) {
            Log.e("WifiRoamingController", "Invalid roam delta index: " + deltaIndex);
            return;
        }
        setRoamingValue("wifi_roam_delta", deltaIndex);
    }

    private void setRoamingValue(String setting, int value) {
        Intent intent = new Intent("com.android.server.startupservice.config");
        intent.putExtra("setting", setting);
        intent.putExtra("value", String.valueOf(value));
        context.sendBroadcast(intent);
        Log.i("WifiRoamingController", setting + " set to index: " + value);
    }

    public void setAggressiveRoaming() {
        setRoamTrigger(1);
        setRoamDelta(5);
    }
}
```

---

### Testing with ADB

#### Set Individual Parameters

```bash
# Set Roaming Trigger to index 1 (-75dBm)
adb shell am broadcast -a com.android.server.startupservice.config --es setting "wifi_roam_trigger" --es value 1

# Set Roaming Delta to index 5 (5dB)
adb shell am broadcast -a com.android.server.startupservice.config --es setting "wifi_roam_delta" --es value 5
```

#### Apply a Recommended Combination

```bash
# Apply Aggressive Roaming policy
adb shell am broadcast -a com.android.server.startupservice.config --es setting "wifi_roam_trigger" --es value 1
adb shell am broadcast -a com.android.server.startupservice.config --es setting "wifi_roam_delta" --es value 5
```

---

### Important Notes

1.  **Independent Settings**: Trigger and Delta can be set independently, but they should be configured together to achieve the desired roaming behavior.
2.  **Default Values**: If not configured, system defaults will be used. The "Moderate" policy (Trigger=2, Delta=4) is the recommended starting point.
3.  **Validation**: The SDK will ignore values that are outside the valid index range for each parameter.
4.  **Testing**: Always test the roaming behavior in a real-world environment to ensure it meets your requirements.
