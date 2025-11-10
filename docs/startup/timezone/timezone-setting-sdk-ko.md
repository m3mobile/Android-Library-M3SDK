# Timezone 제어 SDK

> **참고** <br>
> 이 기능은 StartUp 버전 6.5.9 부터 지원됩니다.

## 개요

이 SDK는 외부 안드로이드 애플리케이션이 StartUp 앱과의 브로드캐스트 통신을 통해 기기의 타임존 설정을 제어할 수 있도록 합니다.

**지원 기기**: StartUp 앱이 설치된 모든 M3 Mobile 기기

### 빠른 시작

#### 기본 사용법

```java
// Set timezone with a specific timezone ID
Intent intent = new Intent("com.android.server.startupservice.system");
intent.putExtra("setting","timezone");
intent.putExtra("timezone","Asia/Seoul");

context.sendBroadcast(intent);
```

#### 결과 콜백 사용

```java
// Send timezone setting and receive result
Intent intent = new Intent("com.android.server.startupservice.system");
intent.putExtra("setting","timezone");
intent.putExtra("timezone","America/New_York");
// The value for "timezone_result_action" can be any custom string you want.
intent.putExtra("timezone_result_action","com.example.myapp.TIMEZONE_RESULT");

context.sendBroadcast(intent);
```

### API 참조

#### 브로드캐스트 액션

**액션**: `com.android.server.startupservice.system`

#### 파라미터

| 파라미터                     | 타입     | 필수 여부 | 설명                                  |
|--------------------------|--------|-------|-------------------------------------|
| `setting`                | String | 예     | 설정 타입. 타임존 제어의 경우 `"timezone"` 값 사용 |
| `timezone`               | String | 예     | IANA 타임존 ID (예: "Asia/Seoul")       |
| `timezone_result_action` | String | 아니요   | 결과 콜백 브로드캐스트를 위한 사용자 지정 액션          |

#### 결과 콜백

만약 `timezone_result_action` 파라미터를 제공하면, StartUp 앱은 결과 브로드캐스트를 전송합니다:

**액션**: 사용자 지정 액션 문자열 (예: `com.example.myapp.TIMEZONE_RESULT`)

**결과 파라미터**:

| 파라미터                     | 타입      | 설명                                       |
|--------------------------|---------|------------------------------------------|
| `timezone_success`       | boolean | 작업이 성공하면 `true`, 실패하면 `false`            |
| `timezone_error_message` | String  | 오류 설명 (`timezone_success`가 false일 때만 존재) |

### 타임존 ID

#### 일반적인 타임존 ID

SDK는 표준 IANA 타임존 데이터베이스 ID를 사용합니다. 다음은 일반적으로 사용되는 몇 가지 예입니다:

**아시아**:

- `Asia/Seoul` - 한국 표준시 (UTC+9)
- `Asia/Tokyo` - 일본 표준시 (UTC+9)
- `Asia/Shanghai` - 중국 표준시 (UTC+8)
- `Asia/Hong_Kong` - 홍콩 시간 (UTC+8)
- `Asia/Singapore` - 싱가포르 시간 (UTC+8)
- `Asia/Bangkok` - 인도차이나 시간 (UTC+7)
- `Asia/Dubai` - 걸프 표준시 (UTC+4)

**아메리카**:

- `America/New_York` - 동부 표준시 (UTC-5/-4)
- `America/Chicago` - 중부 표준시 (UTC-6/-5)
- `America/Denver` - 산지 표준시 (UTC-7/-6)
- `America/Los_Angeles` - 태평양 표준시 (UTC-8/-7)
- `America/Toronto` - 동부 표준시 (캐나다)
- `America/Sao_Paulo` - 브라질리아 시간 (UTC-3/-2)

**유럽**:

- `Europe/London` - 그리니치 평균시 (UTC+0/+1)
- `Europe/Paris` - 중앙 유럽 표준시 (UTC+1/+2)
- `Europe/Berlin` - 중앙 유럽 표준시 (UTC+1/+2)
- `Europe/Moscow` - 모스크바 표준시 (UTC+3)

**태평양**:

- `Pacific/Auckland` - 뉴질랜드 표준시 (UTC+12/+13)
- `Pacific/Fiji` - 피지 시간 (UTC+12/+13)
- `Australia/Sydney` - 호주 동부 표준시 (UTC+10/+11)

**기타**:

- `UTC` - 협정 세계시 (UTC+0)
- `GMT` - 그리니치 평균시 (UTC+0)

### 주요 사항

1. **즉시 적용**: 타임존 설정은 브로드캐스트를 보내는 즉시 시스템에 적용됩니다.

2. **결과 콜백**: `timezone_result_action` 파라미터를 제공하면 성공/실패 결과를 받을 수 있습니다. 제공하지 않으면 fire-and-forget 방식으로 동작합니다.

### 오류 처리

#### 오류 시나리오

1. **잘못된 타임존 ID**
   ```
   Error: "Invalid timezone ID: InvalidTimeZone"
   ```
   **해결책**: 유효한 IANA 타임존 ID를 사용하십시오 (타임존 ID 섹션 참조).

2. **시스템 오류**
   ```
   Error: "Failed to apply timezone setting: [system error details]"
   ```
   **해결책**: 시스템 권한 및 기기 상태를 확인하십시오.

### 전체 예제

#### 클라이언트 앱 구현

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

#### Activity에서 사용

```java
public class MainActivity extends AppCompatActivity {
    private TimeZoneController timeZoneController;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        timeZoneController = new TimeZoneController(this) {
  ㅏ          @Override
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

### ADB를 사용한 테스트

ADB(Android Debug Bridge) 명령어를 사용하여 터미널에서 타임존 제어 기능을 테스트할 수 있습니다.

#### 타임존 설정 (Asia/Seoul)

```bash
adb shell am broadcast -a com.android.server.startupservice.system --es setting "timezone" --es timezone "Asia/Seoul"
```

#### 결과 콜백 테스트

```bash
# 먼저, logcat에서 결과 모니터링
adb logcat | grep "TIMEZONE_RESULT"

# 다른 터미널에서 결과 액션과 함께 브로드캐스트 전송
adb shell am broadcast -a com.android.server.startupserviuce.system --es setting "timezone" --es timezone "America/New_York" --es timezone_result_action "com.test.TIMEZONE_RESULT"
```

#### 잘못된 타임존 테스트 (오류 사례)

```bash
adb shell am broadcast -a com.android.server.startupservice.system --es setting "timezone" --es timezone "InvalidTimeZone" --es timezone_result_action "com.test.TIMEZONE_RESULT"
```
