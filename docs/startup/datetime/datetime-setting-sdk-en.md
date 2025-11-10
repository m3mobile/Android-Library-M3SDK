# DateTime Control SDK

> **Note** <br>
> This feature is supported from StartUp version 5.3.4 and above.

## Overview

This SDK allows external Android applications to manually set the device's date and time through broadcast communication with the StartUp app.

### Quick Start

#### Basic Usage

```java
// Set date and time manually
Intent intent = new Intent("com.android.server.startupservice.system");
intent.putExtra("setting", "datetime");
intent.putExtra("date", "2025-01-15");
intent.putExtra("time", "14:30:00");
context.sendBroadcast(intent);
```

#### Using Result Callback

```java
// Send datetime setting and receive result
Intent intent = new Intent("com.android.server.startupservice.system");
intent.putExtra("setting", "datetime");
intent.putExtra("date", "2025-01-15");
intent.putExtra("time", "14:30:00");
// The value for "datetime_result_action" (e.g., "com.example.myapp.DATETIME_RESULT") can be any custom string you want.
intent.putExtra("datetime_result_action", "com.example.myapp.DATETIME_RESULT");
context.sendBroadcast(intent);
```

### API Reference

#### Broadcast Action

**Action**: `com.android.server.startupservice.system`

#### Parameters

| Parameter                | Type   | Required | Description                                          |
|--------------------------|--------|----------|------------------------------------------------------|
| `setting`                | String | Yes      | Setting type. Use `"datetime"` for DateTime control. |
| `date`                   | String | Yes      | Date (format: `YYYY-MM-DD`)                          |
| `time`                   | String | Yes      | Time (format: `HH:mm:ss`)                            |
| `datetime_result_action` | String | No       | Custom action for the result callback broadcast.     |

#### Result Callback

If you provide the `datetime_result_action` parameter, the StartUp app will send a result broadcast:

**Action**: Custom action string (e.g., `com.example.myapp.DATETIME_RESULT`)

**Result Parameters**:

| Parameter                | Type    | Description                                                      |
|--------------------------|---------|------------------------------------------------------------------|
| `datetime_success`       | boolean | `true` if the operation was successful, `false` otherwise.       |
| `datetime_error_message` | String  | Error description (only present if `datetime_success` is false). |

### Date/Time Format

#### Date Format (YYYY-MM-DD)

The date follows the **ISO 8601** format:

**Format**: `YYYY-MM-DD`
- `YYYY`: 4-digit year (e.g., 2025)
- `MM`: 2-digit month (01-12)
- `DD`: 2-digit day (01-31)

**Correct Examples**:
```java
"2025-01-15"  // January 15, 2025
"2024-12-31"  // December 31, 2024
"2025-03-01"  // March 1, 2025
```

#### Time Format (HH:mm:ss)

The time follows the **24-hour format**:

**Format**: `HH:mm:ss`
- `HH`: 2-digit hour (00-23)
- `mm`: 2-digit minute (00-59)
- `ss`: 2-digit second (00-59)

**Correct Examples**:
```java
"14:30:00"  // 2:30:00 PM
"09:15:30"  // 9:15:30 AM
"00:00:00"  // Midnight
"23:59:59"  // 11:59:59 PM
```

#### Validation

The StartUp app automatically checks for the following:
- Correct date format (YYYY-MM-DD)
- Correct time format (HH:mm:ss)
- Valid date (e.g., February 30 is invalid)
- Valid time (e.g., 25:00 is invalid)

### Important Notes

1. **Automatic Date/Time Setting**: If automatic date/time setting is enabled on the device, the manually set value may be overwritten shortly after.

2. **Result Callback**: Providing the `datetime_result_action` parameter allows you to receive a success/failure result. If not provided, it operates in a fire-and-forget manner.

3. **Timezone**: This API only sets the date/time and does not change the timezone. To change the timezone, use a separate Timezone API.

### Full Example

#### Client App Implementation

```java
public class DateTimeController {
    private Context context;
    private BroadcastReceiver resultReceiver;

    public DateTimeController(Context context) {
        this.context = context;
    }

    /**
     * Set date and time with result callback
     *
     * @param date Date in YYYY-MM-DD format (e.g., "2025-01-15")
     * @param time Time in HH:mm:ss format (e.g., "14:30:00")
     */
    public void setDateTime(String date, String time) {
        // Validate format before sending
        if (!isValidDateFormat(date)) {
            Log.e("DateTimeController", "Invalid date format: " + date + " (expected: YYYY-MM-DD)");
            return;
        }

        if (!isValidTimeFormat(time)) {
            Log.e("DateTimeController", "Invalid time format: " + time + " (expected: HH:mm:ss)");
            return;
        }

        // Register result receiver
        registerResultReceiver();

        // Send datetime setting broadcast
        Intent intent = new Intent("com.android.server.startupservice.system");
        intent.putExtra("setting", "datetime");
        intent.putExtra("date", date);
        intent.putExtra("time", time);
        intent.putExtra("datetime_result_action", "com.example.myapp.DATETIME_RESULT");
        context.sendBroadcast(intent);

        Log.i("DateTimeController", "DateTime setting sent: date=" + date + ", time=" + time);
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
                boolean success = intent.getBooleanExtra("datetime_success", false);
                String errorMessage = intent.getStringExtra("datetime_error_message");

                if (success) {
                    Log.i("DateTimeController", "DateTime setting applied successfully");
                    onDateTimeSetSuccess();
                } else {
                    Log.e("DateTimeController", "DateTime setting failed: " + errorMessage);
                    onDateTimeSetFailed(errorMessage);
                }
            }
        };

        IntentFilter filter = new IntentFilter("com.example.myapp.DATETIME_RESULT");
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
    protected void onDateTimeSetSuccess() {
        // Handle success (e.g., show toast, update UI)
    }

    /**
     * Override this method to handle failure
     */
    protected void onDateTimeSetFailed(String errorMessage) {
        // Handle failure (e.g., show error dialog)
    }

    /**
     * Validate date format (YYYY-MM-DD)
     */
    private boolean isValidDateFormat(String date) {
        if (date == null) return false;
        return date.matches("\\d{4}-\\d{2}-\\d{2}");
    }

    /**
     * Validate time format (HH:mm:ss)
     */
    private boolean isValidTimeFormat(String time) {
        if (time == null) return false;
        return time.matches("\\d{2}:\\d{2}:\\d{2}");
    }

    /**
     * Set current system time (convenience method)
     */
    public void setToCurrentTime() {
        SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd", Locale.US);
        SimpleDateFormat timeFormat = new SimpleDateFormat("HH:mm:ss", Locale.US);

        Date now = new Date();
        String date = dateFormat.format(now);
        String time = timeFormat.format(now);

        setDateTime(date, time);
    }

    /**
     * Set specific date and time using Calendar
     */
    public void setDateTime(int year, int month, int day, int hour, int minute, int second) {
        String date = String.format(Locale.US, "%04d-%02d-%02d", year, month, day);
        String time = String.format(Locale.US, "%02d:%02d:%02d", hour, minute, second);
        setDateTime(date, time);
    }
}
```

#### Usage in Activity

```java
public class MainActivity extends AppCompatActivity {
    private DateTimeController dateTimeController;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        dateTimeController = new DateTimeController(this) {
            @Override
            protected void onDateTimeSetSuccess() {
                Toast.makeText(MainActivity.this,
                        "DateTime set successfully", Toast.LENGTH_SHORT).show();
            }

            @Override
            protected void onDateTimeSetFailed(String errorMessage) {
                Toast.makeText(MainActivity.this,
                        "Failed: " + errorMessage, Toast.LENGTH_LONG).show();
            }
        };

        // Example 1: Set specific date and time
        findViewById(R.id.btnSetDateTime1).setOnClickListener(v -> {
            dateTimeController.setDateTime("2025-01-15", "14:30:00");
        });

        // Example 2: Set current system time
        findViewById(R.id.btnSetCurrentTime).setOnClickListener(v -> {
            dateTimeController.setToCurrentTime();
        });

        // Example 3: Set using Calendar values
        findViewById(R.id.btnSetDateTime2).setOnClickListener(v -> {
            dateTimeController.setDateTime(2025, 12, 31, 23, 59, 59);
        });

        // Example 4: Set from DatePicker and TimePicker
        findViewById(R.id.btnSetFromPickers).setOnClickListener(v -> {
            showDateTimePicker();
        });
    }

    private void showDateTimePicker() {
        // Show date picker first
        Calendar calendar = Calendar.getInstance();

        new DatePickerDialog(this, (view, year, month, dayOfMonth) -> {
            // Show time picker after date is selected
            new TimePickerDialog(this, (timeView, hourOfDay, minute) -> {
                // Set datetime with selected values
                dateTimeController.setDateTime(year, month + 1, dayOfMonth,
                        hourOfDay, minute, 0);
            }, calendar.get(Calendar.HOUR_OF_DAY),
               calendar.get(Calendar.MINUTE), true).show();
        }, calendar.get(Calendar.YEAR),
           calendar.get(Calendar.MONTH),
           calendar.get(Calendar.DAY_OF_MONTH)).show();
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        dateTimeController.cleanup();
    }
}
```

### Testing with ADB

You can test the DateTime control feature from the terminal using ADB (Android Debug Bridge) commands.

#### Set Date/Time

```bash
# Set to 2025-01-15 14:30:00
adb shell am broadcast -a com.android.server.startupservice.system --es setting "datetime" --es date "2025-01-15" --es time "14:30:00"
```

#### Test Result Callback

```bash
# Monitor result callback in logcat
adb logcat | grep "DATETIME_RESULT"

# In another terminal, send broadcast with result action
adb shell am broadcast -a com.android.server.startupservice.system --es setting "datetime" --es date "2025-01-15" --es time "14:30:00" --es datetime_result_action "com.test.DATETIME_RESULT"
```

#### Various Examples

```bash
# Set to midnight (2025-01-01 00:00:00)
adb shell am broadcast -a com.android.server.startupservice.system --es setting "datetime" --es date "2025-01-01" --es time "00:00:00"

# Set to end of year (2025-12-31 23:59:59)
adb shell am broadcast -a com.android.server.startupservice.system --es setting "datetime" --es date "2025-12-31" --es time "23:59:59"

# Set to noon (2025-06-15 12:00:00)
adb shell am broadcast -a com.android.server.startupservice.system --es setting "datetime" --es date "2025-06-15" --es time "12:00:00"

# Test invalid date format (error case)
adb shell am broadcast -a com.android.server.startupservice.system --es setting "datetime" --es date "2025-1-15" --es time "14:30:00" --es datetime_result_action "com.test.DATETIME_RESULT"

# Test invalid time format (error case)
adb shell am broadcast -a com.android.server.startupservice.system --es setting "datetime" --es date "2025-01-15" --es time "14:30" --es datetime_result_action "com.test.DATETIME_RESULT"
```

#### Log Monitoring

To monitor the DateTime setting process:

```bash
# Monitor datetime setting process
adb logcat | grep -E "handleDateTimeSetting|date :|time :"

# Monitor StartUpWork logs
adb logcat | grep "StartUpWork"
```

#### Check Current Date/Time

```bash
# Check current system date and time
adb shell date

# Check in specific format
adb shell date "+%Y-%m-%d %H:%M:%S"
```

#### Check Automatic Date/Time Setting

```bash
# Check if automatic date & time is enabled
adb shell settings get global auto_time

# Disable automatic date & time (if needed for testing)
adb shell settings put global auto_time 0

# Enable automatic date & time
adb shell settings put global auto_time 1
```

### Related APIs

-   **Timezone Control SDK**: `timezone-setting-sdk-readme.md` - Controls the device's timezone.
-   **NTP Configuration**: NTP server auto-synchronization can be configured through the StartUp JSON settings.

### Troubleshooting

#### DateTime Setting Not Applied

1.  Check if the StartUp app is running:
    ```bash
    adb shell ps | grep startup
    ```

2.  Check if automatic date/time is disabled:
    ```bash
    # 0: disable 1: enable
    adb shell settings get global auto_time
    ```

3.  Check the logs to see if the broadcast was received:
    ```bash
    adb logcat | grep "STARTUP_ACTION_SYSTEM received"
    ```

4.  Verify the Date/Time format is correct (YYYY-MM-DD, HH:mm:ss).
