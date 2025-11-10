# Timezone Control SDK

> **Note** This feature is supported from StartUp version 6.5.9 and above.

## Overview

This SDK allows external Android applications to control the device's timezone setting through broadcast communication with the StartUp app.

**Supported Devices**: All M3 Mobile devices with StartUp app installed

### Quick Start

#### Basic Usage

```java
// Set timezone with a specific timezone ID
Intent intent = new Intent("com.android.server.startupservice.system");
intent.putExtra("setting","timezone");
intent.putExtra("timezone","Asia/Seoul");

context.sendBroadcast(intent);
```

#### Using Result Callback

```java
// Send timezone setting and receive result
Intent intent = new Intent("com.android.server.startupservice.system");
intent.putExtra("setting","timezone");
intent.putExtra("timezone","America/New_York");
// The value for "timezone_result_action" can be any custom string you want.
intent.putExtra("timezone_result_action","com.example.myapp.TIMEZONE_RESULT");

context.sendBroadcast(intent);
```

### API Reference

#### Broadcast Action

**Action**: `com.android.server.startupservice.system`

#### Parameters

| Parameter                | Type   | Required | Description                                          |
|--------------------------|--------|----------|------------------------------------------------------|
| `setting`                | String | Yes      | Setting type. Use `"timezone"` for timezone control. |
| `timezone`               | String | Yes      | IANA timezone ID (e.g., "Asia/Seoul").               |
| `timezone_result_action` | String | No       | Custom action for the result callback broadcast.     |

#### Result Callback

If you provide the `timezone_result_action` parameter, the StartUp app will send a result broadcast:

**Action**: Custom action string (e.g., `com.example.myapp.TIMEZONE_RESULT`)

**Result Parameters**:

| Parameter                | Type    | Description                                                      |
|--------------------------|---------|------------------------------------------------------------------|
| `timezone_success`       | boolean | `true` if the operation was successful, `false` otherwise.       |
| `timezone_error_message` | String  | Error description (only present if `timezone_success` is false). |

### Timezone IDs

#### Common Timezone IDs

The SDK uses standard IANA timezone database IDs. Here are some commonly used examples:

**Asia**:

- `Asia/Seoul` - Korea Standard Time (UTC+9)
- `Asia/Tokyo` - Japan Standard Time (UTC+9)
- `Asia/Shanghai` - China Standard Time (UTC+8)
- `Asia/Hong_Kong` - Hong Kong Time (UTC+8)
- `Asia/Singapore` - Singapore Time (UTC+8)
- `Asia/Bangkok` - Indochina Time (UTC+7)
- `Asia/Dubai` - Gulf Standard Time (UTC+4)

**Americas**:

- `America/New_York` - Eastern Time (UTC-5/-4)
- `America/Chicago` - Central Time (UTC-6/-5)
- `America/Denver` - Mountain Time (UTC-7/-6)
- `America/Los_Angeles` - Pacific Time (UTC-8/-7)
- `America/Toronto` - Eastern Time (Canada)
- `America/Sao_Paulo` - Brasília Time (UTC-3/-2)

**Europe**:

- `Europe/London` - Greenwich Mean Time (UTC+0/+1)
- `Europe/Paris` - Central European Time (UTC+1/+2)
- `Europe/Berlin` - Central European Time (UTC+1/+2)
- `Europe/Moscow` - Moscow Standard Time (UTC+3)

**Pacific**:

- `Pacific/Auckland` - New Zealand Standard Time (UTC+12/+13)
- `Pacific/Fiji` - Fiji Time (UTC+12/+13)
- `Australia/Sydney` - Australian Eastern Standard Time (UTC+10/+11)

**Other**:

- `UTC` - Coordinated Universal Time (UTC+0)
- `GMT` - Greenwich Mean Time (UTC+0)

### Important Notes

1. **Immediate Effect**: The timezone setting is applied to the system immediately after the broadcast is sent.

2. **Result Callback**: Providing the `timezone_result_action` parameter allows you to receive a success/failure result. If not provided, it operates in a fire-and-forget manner.

### Error Handling

#### Error Scenarios

1.  **Invalid Timezone ID**
    ```
    Error: "Invalid timezone ID: InvalidTimeZone"
    ```
    **Solution**: Use a valid IANA timezone ID (see the Timezone ID section).

2.  **System Error**
    ```
    Error: "Failed to apply timezone setting: [system error details]"
    ```
    **Solution**: Check system permissions and device status.

### Full Example

#### Client App Implementation

```java
public class TimeZoneController {
    private Context context;
    private BroadcastReceiver resultReceiver;

    public TimeZoneController(Context context) {
        this.context = context;
    }

    /**
     * Set timezone with result callback
     */
    public void setTimeZone(String timezoneId) {
        // Register result receiver
        registerResultReceiver();

        // Send timezone setting broadcast
        Intent intent = new Intent("com.android.server.startupservice.system");
        intent.putExtra("setting", "timezone");
        intent.putExtra("timezone", timezoneId);
        intent.putExtra("timezone_result_action", "com.example.myapp.TIMEZONE_RESULT");
        context.sendBroadcast(intent);

        Log.i("TimeZoneController", "Timezone setting sent: timezone=" + timezoneId);
    }

    /**
     * Register broadcast receiver for result callback
     */
    private void registerResultReceiver() {
        if (resultReceiver != null) {
            return; // Already registered
        }

        resultReceiver = new BroadcastReceiver() {
            @Override
            public void onReceive(Context context, Intent intent) {
                boolean success = intent.getBooleanExtra("timezone_success", false);
                String errorMessage = intent.getStringExtra("timezone_error_message");

                if (success) {
                    Log.i("TimeZoneController", "Timezone setting applied successfully");
                    onTimeZoneSetSuccess();
                } else {
                    Log.e("TimeZoneController", "Timezone setting failed: " + errorMessage);
                    onTimeZoneSetFailed(errorMessage);
                }
            }
        };

        IntentFilter filter = new IntentFilter("com.example.myapp.TIMEZONE_RESULT");
        context.registerReceiver(resultReceiver, filter);
    }

    /**
     * Unregister result receiver (call in onDestroy)
     */
    public void cleanup() {
        if (resultReceiver != null) {
            context.unregisterReceiver(resultReceiver);
            resultReceiver = null;
        }
    }

    /**
     * Override this method to handle success
     */
    protected void onTimeZoneSetSuccess() {
        // Handle success (e.g., show toast, update UI)
    }

    /**
     * Override this method to handle failure
     */
    protected void onTimeZoneSetFailed(String errorMessage) {
        // Handle failure (e.g., show error dialog)
    }
}
```

#### Usage in Activity

```java
public class MainActivity extends AppCompatActivity {
    private TimeZoneController timeZoneController;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        timeZoneController = new TimeZoneController(this) {
            @Override
            protected void onTimeZoneSetSuccess() {
                Toast.makeText(MainActivity.this,
                        "Timezone set successfully", Toast.LENGTH_SHORT).show();
            }

            @Override
            protected void onTimeZoneSetFailed(String errorMessage) {
                Toast.makeText(MainActivity.this,
                        "Failed: " + errorMessage, Toast.LENGTH_LONG).show();
            }
        };

        // Example: Set timezone to Seoul
        findViewById(R.id.btnSetSeoul).setOnClickListener(v -> {
            timeZoneController.setTimeZone("Asia/Seoul");
        });

        // Example: Set timezone to New York
        findViewById(R.id.btnSetNewYork).setOnClickListener(v -> {
            timeZoneController.setTimeZone("America/New_York");
        });
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        timeZoneController.cleanup();
    }
}
```

### Testing with ADB

You can test the timezone control feature from the terminal using ADB (Android Debug Bridge) commands.

#### Set Timezone (Asia/Seoul)

```bash
adb shell am broadcast -a com.android.server.startupservice.system --es setting "timezone" --es timezone "Asia/Seoul"
```

#### Test Result Callback

```bash
# First, monitor the result in logcat
adb logcat | grep "TIMEZONE_RESULT"

# In another terminal, send the broadcast with the result action
adb shell am broadcast -a com.android.server.startupservice.system --es setting "timezone" --es timezone "America/New_York" --es timezone_result_action "com.test.TIMEZONE_RESULT"
```

#### Test Invalid Timezone (Error Case)

```bash
adb shell am broadcast -a com.android.server.startupservice.system --es setting "timezone" --es timezone "InvalidTimeZone" --es timezone_result_action "com.test.TIMEZONE_RESULT"
```
