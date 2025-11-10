# Wi-Fi Frequency Band Setting SDK

> **Note** <br>
> Supported from StartUp version 6.0.6 BETA. <br>
> SL10 and SL10K devices are not supported.

## Overview

This SDK allows external Android applications to restrict device Wi-Fi scanning and connection to specific frequency bands (2.4GHz or 5GHz) through broadcast communication with the StartUp app.

By restricting frequency bands, the device will only scan and connect to APs on the specified band, enabling optimized Wi-Fi settings for your network environment.

Supported frequency bands:
- **AUTO (0)**: Use both 2.4GHz + 5GHz (default)
- **5GHz only (1)**: Scan and connect only to 5GHz band
- **2.4GHz only (2)**: Scan and connect only to 2.4GHz band

### Quick Start

#### Basic Usage

```java
// AUTO mode (use both 2.4GHz + 5GHz)
Intent intent = new Intent("com.android.server.startupservice.config");
intent.putExtra("setting", "wifi_freq_band");
intent.putExtra("value", 0);
context.sendBroadcast(intent);

// 5GHz only
Intent intent5G = new Intent("com.android.server.startupservice.config");
intent5G.putExtra("setting", "wifi_freq_band");
intent5G.putExtra("value", 1);
context.sendBroadcast(intent5G);

// 2.4GHz only
Intent intent24G = new Intent("com.android.server.startupservice.config");
intent24G.putExtra("setting", "wifi_freq_band");
intent24G.putExtra("value", 2);
context.sendBroadcast(intent24G);
```

### API Reference

#### Broadcast Action

**Action**: `com.android.server.startupservice.config`

#### Parameters

| Parameter | Type   | Required | Description                                                                          |
|-----------|--------|----------|--------------------------------------------------------------------------------------|
| `setting` | String | Yes      | Must be set to `"wifi_freq_band"`.                                                   |
| `value`   | int    | Yes      | Frequency band setting value<br>0: AUTO (2.4GHz + 5GHz)<br>1: 5GHz only<br>2: 2.4GHz only |

---

### Detailed Configuration Guide

#### Frequency Band Options

**AUTO (0) - Dual Band**
- Both 2.4GHz and 5GHz available
- Device automatically selects optimal band
- Recommended default for most environments

**5GHz only (1)**
- Scan and connect only to 5GHz band
- Faster speeds and less interference
- Recommended for environments with 5GHz APs
- Advantages: High bandwidth, less interference
- Disadvantages: Shorter range

**2.4GHz only (2)**
- Scan and connect only to 2.4GHz band
- Wider coverage
- Use in environments with only 2.4GHz APs
- Advantages: Wide coverage, better obstacle penetration
- Disadvantages: Higher interference potential, relatively lower speeds

---

### Common Use Cases

#### Scenario 1: Warehouse/Logistics Center (2.4GHz only)

Large spaces with many obstacles:

```java
Intent intent = new Intent("com.android.server.startupservice.config");
intent.putExtra("setting", "wifi_freq_band");
intent.putExtra("value", 2); // 2.4GHz only
context.sendBroadcast(intent);
```

#### Scenario 2: Office/High-Speed Data Transfer (5GHz only)

Low interference environment requiring high-speed communication:

```java
Intent intent = new Intent("com.android.server.startupservice.config");
intent.putExtra("setting", "wifi_freq_band");
intent.putExtra("value", 1); // 5GHz only
context.sendBroadcast(intent);
```

#### Scenario 3: General Environment (AUTO)

Various environments:

```java
Intent intent = new Intent("com.android.server.startupservice.config");
intent.putExtra("setting", "wifi_freq_band");
intent.putExtra("value", 0); // AUTO
context.sendBroadcast(intent);
```

---

### Integration with wifi-channel-sdk

The wifi-frequency-sdk controls entire frequency bands (2.4GHz/5GHz), while the wifi-channel-sdk provides fine-grained control over specific channels within each band.

For more granular control, you can use both SDKs together:

#### Integration Examples

**Example: Use only non-overlapping channels (1, 6, 11) in 2.4GHz band**

```java
// Step 1: Restrict frequency band to 2.4GHz
Intent freqIntent = new Intent("com.android.server.startupservice.config");
freqIntent.putExtra("setting", "wifi_freq_band");
freqIntent.putExtra("value", 2); // 2.4GHz only
context.sendBroadcast(freqIntent);

// Step 2: Use only channels 1, 6, 11 within 2.4GHz band
Intent channelIntent = new Intent("com.android.server.startupservice.config");
channelIntent.putExtra("setting", "wifi_channel");
String[] channels = {"1", "6", "11"};
channelIntent.putExtra("value", channels);
context.sendBroadcast(channelIntent);
```

**Example: Use only non-DFS channels in 5GHz band**

```java
// Step 1: Restrict frequency band to 5GHz
Intent freqIntent = new Intent("com.android.server.startupservice.config");
freqIntent.putExtra("setting", "wifi_freq_band");
freqIntent.putExtra("value", 1); // 5GHz only
context.sendBroadcast(freqIntent);

// Step 2: Use only non-DFS channels within 5GHz band
Intent channelIntent = new Intent("com.android.server.startupservice.config");
channelIntent.putExtra("setting", "wifi_channel");
String[] channels = {"36", "40", "44", "48", "149", "153", "157", "161", "165"};
channelIntent.putExtra("value", channels);
context.sendBroadcast(channelIntent);
```

**Note**: For more details on wifi-channel-sdk, see the [Wi-Fi Channel Setting SDK Documentation](wifi-channel-sdk-readme.md).

---

### Complete Examples

#### Client App Implementation

```java
public class WifiFrequencyController {
    private Context context;

    public WifiFrequencyController(Context context) {
        this.context = context;
    }

    /**
     * Set Wi-Fi frequency band
     *
     * @param band Frequency band (0: AUTO, 1: 5GHz, 2: 2.4GHz)
     */
    public void setWifiFrequencyBand(int band) {
        // Validate value
        if (band < 0 || band > 2) {
            Log.e("WifiFrequencyController", "Invalid band value: " + band);
            return;
        }

        // Send Wi-Fi frequency band setting broadcast
        Intent intent = new Intent("com.android.server.startupservice.config");
        intent.putExtra("setting", "wifi_freq_band");
        intent.putExtra("value", band);
        context.sendBroadcast(intent);

        String bandName = getBandName(band);
        Log.i("WifiFrequencyController", "Wi-Fi frequency band set to: " + bandName);
    }

    /**
     * Set AUTO mode (2.4GHz + 5GHz)
     */
    public void setAuto() {
        setWifiFrequencyBand(0);
    }

    /**
     * Use 5GHz only
     */
    public void set5GHzOnly() {
        setWifiFrequencyBand(1);
    }

    /**
     * Use 2.4GHz only
     */
    public void set24GHzOnly() {
        setWifiFrequencyBand(2);
    }

    /**
     * Get band name
     */
    private String getBandName(int band) {
        switch (band) {
            case 0:
                return "AUTO (2.4GHz + 5GHz)";
            case 1:
                return "5GHz only";
            case 2:
                return "2.4GHz only";
            default:
                return "Unknown";
        }
    }
}
```

#### Usage in Activity

```java
public class MainActivity extends AppCompatActivity {
    private WifiFrequencyController wifiFrequencyController;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        wifiFrequencyController = new WifiFrequencyController(this);

        // AUTO mode
        findViewById(R.id.btnSetAuto).setOnClickListener(v -> {
            wifiFrequencyController.setAuto();
            Toast.makeText(this, "AUTO mode set (2.4GHz + 5GHz)", Toast.LENGTH_SHORT).show();
        });

        // 5GHz only
        findViewById(R.id.btnSet5GHzOnly).setOnClickListener(v -> {
            wifiFrequencyController.set5GHzOnly();
            Toast.makeText(this, "5GHz only mode set", Toast.LENGTH_SHORT).show();
        });

        // 2.4GHz only
        findViewById(R.id.btnSet24GHzOnly).setOnClickListener(v -> {
            wifiFrequencyController.set24GHzOnly();
            Toast.makeText(this, "2.4GHz only mode set", Toast.LENGTH_SHORT).show();
        });
    }
}
```

#### Kotlin Usage

```kotlin
class WifiFrequencyController(private val context: Context) {

    /**
     * Set Wi-Fi frequency band
     */
    fun setWifiFrequencyBand(band: Int) {
        // Validate value
        if (band !in 0..2) {
            Log.e("WifiFrequencyController", "Invalid band value: $band")
            return
        }

        // Send Wi-Fi frequency band setting broadcast
        Intent("com.android.server.startupservice.config").apply {
            putExtra("setting", "wifi_freq_band")
            putExtra("value", band)
            context.sendBroadcast(this)
        }

        Log.i("WifiFrequencyController", "Wi-Fi frequency band set to: ${getBandName(band)}")
    }

    /**
     * Set AUTO mode (2.4GHz + 5GHz)
     */
    fun setAuto() = setWifiFrequencyBand(0)

    /**
     * Use 5GHz only
     */
    fun set5GHzOnly() = setWifiFrequencyBand(1)

    /**
     * Use 2.4GHz only
     */
    fun set24GHzOnly() = setWifiFrequencyBand(2)

    /**
     * Get band name
     */
    private fun getBandName(band: Int): String = when (band) {
        0 -> "AUTO (2.4GHz + 5GHz)"
        1 -> "5GHz only"
        2 -> "2.4GHz only"
        else -> "Unknown"
    }
}

// Kotlin Activity usage example
class MainActivity : AppCompatActivity() {
    private lateinit var wifiFrequencyController: WifiFrequencyController

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        wifiFrequencyController = WifiFrequencyController(this)

        // AUTO mode
        findViewById<Button>(R.id.btnSetAuto).setOnClickListener {
            wifiFrequencyController.setAuto()
            Toast.makeText(this, "AUTO mode set", Toast.LENGTH_SHORT).show()
        }

        // 5GHz only
        findViewById<Button>(R.id.btnSet5GHzOnly).setOnClickListener {
            wifiFrequencyController.set5GHzOnly()
            Toast.makeText(this, "5GHz only mode set", Toast.LENGTH_SHORT).show()
        }

        // 2.4GHz only
        findViewById<Button>(R.id.btnSet24GHzOnly).setOnClickListener {
            wifiFrequencyController.set24GHzOnly()
            Toast.makeText(this, "2.4GHz only mode set", Toast.LENGTH_SHORT).show()
        }
    }
}
```

---

### Testing with ADB

#### AUTO mode (2.4GHz + 5GHz)

```bash
adb shell am broadcast -a com.android.server.startupservice.config --es setting "wifi_freq_band" --ei value 0
```

#### 5GHz only

```bash
adb shell am broadcast -a com.android.server.startupservice.config --es setting "wifi_freq_band" --ei value 1
```

#### 2.4GHz only

```bash
adb shell am broadcast -a com.android.server.startupservice.config --es setting "wifi_freq_band" --ei value 2
```

---

### Important Notes

1. **Reconnection Required**: After changing frequency band settings, you may need to toggle Wi-Fi or restart the device for the settings to fully take effect.

2. **Network Environment Considerations**:
   - When set to 5GHz only mode, connection is not possible in environments with only 2.4GHz APs
   - When set to 2.4GHz only mode, connection is not possible in environments with only 5GHz APs

3. **Device-Specific Implementations**: Some devices may have different internal implementations, but the SDK usage method is the same.

4. **Use with wifi-channel-sdk**: For more granular channel control, you can use this SDK together with wifi-channel-sdk.

5. **Default Value**: If not configured, AUTO mode (0) is the default.

---
