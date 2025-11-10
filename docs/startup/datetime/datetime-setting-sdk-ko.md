# DateTime 제어 SDK

> **참고** 이 기능은 StartUp 버전 5.3.4부터 지원됩니다.

## 개요

이 SDK는 외부 안드로이드 애플리케이션이 StartUp 앱과의 브로드캐스트 통신을 통해 기기의 날짜와 시간을 수동으로 설정할 수 있도록 합니다.

### 빠른 시작

#### 기본 사용법

```java
// Set date and time manually
Intent intent = new Intent("com.android.server.startupservice.system");
intent.putExtra("setting", "datetime");
intent.putExtra("date", "2025-01-15");
intent.putExtra("time", "14:30:00");
context.sendBroadcast(intent);
```

#### 결과 콜백 사용

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

### API 참조

#### 브로드캐스트 액션

**액션**: `com.android.server.startupservice.system`

#### 파라미터

| 파라미터                      | 타입     | 필수 여부 | 설명                                                  |
|---------------------------|--------|-------|-----------------------------------------------------|
| `setting`                 | String | 예     | 설정 타입. DateTime 제어의 경우 `"datetime"` 값 사용            |
| `date`                    | String | 예     | 날짜 (형식: `YYYY-MM-DD`)                               |
| `time`                    | String | 예     | 시간 (형식: `HH:mm:ss`)                                 |
| `datetime_result_action`  | String | 아니요   | 결과 콜백 브로드캐스트를 위한 사용자 지정 액션                          |

#### 결과 콜백

만약 `datetime_result_action` 파라미터를 제공하면, StartUp 앱은 결과 브로드캐스트를 전송합니다:

**액션**: 사용자 지정 액션 문자열 (예: `com.example.myapp.DATETIME_RESULT`)

**결과 파라미터**:

| 파라미터                     | 타입      | 설명                                       |
|--------------------------|---------|------------------------------------------|
| `datetime_success`       | boolean | 작업이 성공하면 `true`, 실패하면 `false`            |
| `datetime_error_message` | String  | 오류 설명 (`datetime_success`가 false일 때만 존재) |

### Date/Time 형식

#### Date 형식 (YYYY-MM-DD)

날짜는 **ISO 8601** 형식을 따릅니다:

**형식**: `YYYY-MM-DD`
- `YYYY`: 4자리 연도 (예: 2025)
- `MM`: 2자리 월 (01-12)
- `DD`: 2자리 일 (01-31)

**올바른 예제**:
```java
"2025-01-15"  // 2025년 1월 15일
"2024-12-31"  // 2024년 12월 31일
"2025-03-01"  // 2025년 3월 1일
```

#### Time 형식 (HH:mm:ss)

시간은 **24시간 형식**을 따릅니다:

**형식**: `HH:mm:ss`
- `HH`: 2자리 시 (00-23)
- `mm`: 2자리 분 (00-59)
- `ss`: 2자리 초 (00-59)

**올바른 예제**:
```java
"14:30:00"  // 오후 2시 30분 0초
"09:15:30"  // 오전 9시 15분 30초
"00:00:00"  // 자정
"23:59:59"  // 23시 59분 59초
```

#### 유효성 검증

StartUp 앱은 다음 사항을 자동으로 확인합니다:
- 날짜 형식이 올바른지 (YYYY-MM-DD)
- 시간 형식이 올바른지 (HH:mm:ss)
- 날짜가 유효한지 (예: 2월 30일은 무효)
- 시간이 유효한지 (예: 25시는 무효)

### 주요 사항

1. **자동 날짜/시간 설정**: 기기에서 자동 날짜/시간 설정이 활성화되어 있으면 수동으로 설정한 값이 곧 덮어씌워질 수 있습니다.

2. **결과 콜백**: `datetime_result_action` 파라미터를 제공하면 성공/실패 결과를 받을 수 있습니다. 제공하지 않으면 fire-and-forget 방식으로 동작합니다.

3. **타임존**: 이 API는 날짜/시간만 설정하며 타임존은 변경하지 않습니다. 타임존을 변경하려면 별도의 Timezone API를 사용하세요.

### 전체 예제

#### 클라이언트 앱 구현

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

#### Activity에서 사용

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

### ADB를 사용한 테스트

ADB(Android Debug Bridge) 명령어를 사용하여 터미널에서 DateTime 제어 기능을 테스트할 수 있습니다.

#### 날짜/시간 설정

```bash
# Set to 2025-01-15 14:30:00
adb shell am broadcast -a com.android.server.startupservice.system --es setting "datetime" --es date "2025-01-15" --es time "14:30:00"
```

#### 결과 콜백 테스트

```bash
# Monitor result callback in logcat
adb logcat | grep "DATETIME_RESULT"

# In another terminal, send broadcast with result action
adb shell am broadcast -a com.android.server.startupservice.system --es setting "datetime" --es date "2025-01-15" --es time "14:30:00" --es datetime_result_action "com.test.DATETIME_RESULT"
```

#### 다양한 예제

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

#### 로그 모니터링

DateTime 설정이 적용되는 과정을 모니터링하려면:

```bash
# Monitor datetime setting process
adb logcat | grep -E "handleDateTimeSetting|date :|time :"

# Monitor StartUpWork logs
adb logcat | grep "StartUpWork"
```

#### 현재 날짜/시간 확인

```bash
# Check current system date and time
adb shell date

# Check in specific format
adb shell date "+%Y-%m-%d %H:%M:%S"
```

#### 자동 날짜/시간 설정 확인

```bash
# Check if automatic date & time is enabled
adb shell settings get global auto_time

# Disable automatic date & time (if needed for testing)
adb shell settings put global auto_time 0

# Enable automatic date & time
adb shell settings put global auto_time 1
```

### 관련 API

- **Timezone 제어 SDK**: `timezone-setting-sdk-readme.md` - 기기의 타임존을 제어합니다.
- **NTP 설정**: StartUp JSON 설정을 통해 NTP 서버 자동 동기화를 구성할 수 있습니다.

### 문제 해결

#### DateTime 설정이 적용되지 않음

1. StartUp 앱이 실행 중인지 확인:
   ```bash
   adb shell ps | grep startup
   ```

2. 자동 날짜/시간이 비활성화되어 있는지 확인:
   ```bash
   # 0: disable 1: enable
   adb shell settings get global auto_time 
   ```

3. 로그를 확인하여 브로드캐스트가 수신되었는지 확인:
   ```bash
   adb logcat | grep "STARTUP_ACTION_SYSTEM received"
   ```

4. Date/Time 형식이 올바른지 확인 (YYYY-MM-DD, HH:mm:ss)

