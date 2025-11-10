# NTP Server Settings Control SDK

> **Note** <br>
> This feature is supported from StartUp version 6.4.9 and above.

## Overview

This SDK allows external Android applications to control the device's NTP (Network Time Protocol) server settings through broadcast communication with the StartUp app.

**Important**: Changes take effect after device reboot.

**Supported Devices**: All M3 Mobile devices with StartUp app installed

### Quick Start

#### Basic Usage

```java
// Set NTP server to Google's public NTP server
Intent intent = new Intent("com.android.server.startupservice.system");
intent.putExtra("setting","ntp");
intent.putExtra("ntp_server","time.google.com");

context.sendBroadcast(intent);
```

### API Reference

#### Broadcast Action

**Action**: `com.android.server.startupservice.system`

#### Parameters

| Parameter    | Type   | Required | Description                                                            |
|--------------|--------|----------|------------------------------------------------------------------------|
| `setting`    | String | Yes      | Setting type. Use `"ntp"` for NTP server control.                      |
| `ntp_server` | String | Yes      | NTP server URL or IP address (e.g., "time.google.com", "pool.ntp.org") |

#### NTP Servers example

| Server Address        | Description                | Region |
|-----------------------|----------------------------|--------|
| `time.google.com`     | Google Public NTP          | Global |

### Important Notes

#### 1. Reboot Required

The NTP server setting will take effect **after the next device reboot**. The system will display a
toast message:

```
"NTP server has been specified. It will take effect from the next boot."
```

#### 2. No Result Callback

Unlike timezone or USB settings, this API does not support result callbacks. The setting is
immediately saved to the system but requires a reboot to apply.

#### 3. Validation

- The API does not validate if the NTP server address is valid
- Make sure to provide a correct NTP server URL or IP address
- Invalid servers will not cause errors but may result in time sync failures

### Full Example

#### Client App Implementation

```java
public class NtpController {
    private Context context;

    public NtpController(Context context) {
        this.context = context;
    }

    /**
     * Set NTP server
     * @param ntpServer NTP server URL or IP address (e.g., "time.google.com")
     */
    public void setNtpServer(String ntpServer) {
        if (ntpServer == null || ntpServer.trim().isEmpty()) {
            Log.e("NtpController", "NTP server cannot be empty");
            return;
        }

        // Send NTP setting broadcast
        Intent intent = new Intent("com.android.server.startupservice.system");
        intent.putExtra("setting", "ntp");
        intent.putExtra("ntp_server", ntpServer);
        context.sendBroadcast(intent);

        Log.i("NtpController", "NTP server setting sent: " + ntpServer);
    }
}
```

#### Usage in Activity

```java
public class MainActivity extends AppCompatActivity {
    private NtpController ntpController;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        ntpController = new NtpController(this);

        // Example: Set NTP server to Google's public NTP
        findViewById(R.id.btnGoogleNtp).setOnClickListener(v -> {
            ntpController.setNtpServer("time.google.com");
            Toast.makeText(this,
                    "NTP server set to time.google.com\nReboot required to apply",
                    Toast.LENGTH_LONG).show();
        });

        // Example: Set NTP server to NTP Pool Project
        findViewById(R.id.btnPoolNtp).setOnClickListener(v -> {
            ntpController.setNtpServer("pool.ntp.org");
            Toast.makeText(this,
                    "NTP server set to pool.ntp.org\nReboot required to apply",
                    Toast.LENGTH_LONG).show();
        });

        // Example: Set custom NTP server
        findViewById(R.id.btnCustomNtp).setOnClickListener(v -> {
            EditText etCustomNtp = findViewById(R.id.etCustomNtp);
            String customServer = etCustomNtp.getText().toString().trim();

            if (!customServer.isEmpty()) {
                ntpController.setNtpServer(customServer);
                Toast.makeText(this,
                        "NTP server set to " + customServer + "\nReboot required to apply",
                        Toast.LENGTH_LONG).show();
            } else {
                Toast.makeText(this,
                        "Please enter a valid NTP server address",
                        Toast.LENGTH_SHORT).show();
            }
        });
    }
}
```


### Testing with ADB

You can test the NTP server setting feature from the terminal using ADB (Android Debug Bridge)
commands.

#### Set NTP Server (Google)

```bash
adb shell am broadcast -a com.android.server.startupservice.system --es setting "ntp" --es ntp_server "time.google.com"
```

#### Verify Setting (After Reboot)

```bash
# Check current NTP server setting
adb shell settings get global ntp_server
```
