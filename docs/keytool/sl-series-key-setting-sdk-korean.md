# 키 설정 SDK

>**참고:** 이 기능은 KeyTool V1.2.6 이상이면서 SL20, SL20P, SL20K 에서만 가능합니다.

## 개요

이 SDK는 외부 안드로이드 애플리케이션이 KeyToolSL20 애플리케이션과의 브로드캐스트 통신을 통해 물리 키의 기능을 리매핑할 수 있도록 합니다.
외부 앱은 임의의 물리 키에 할당된 함수를 변경하고 해당 키의 Wake-up 기능을 활성화 또는 비활성화할 수 있습니다.

### 빠른 시작

#### 기본 사용법

```java
// 물리 키를 새로운 함수로 리매핑
Intent intent = new Intent("com.m3.keytoolsl20.ACTION_SET_KEY");
intent.putExtra("key_title", "Left Scan");  // 리매핑할 키
intent.putExtra("key_function", "Scan");    // 새로운 함수
intent.putExtra("key_wakeup", false);       // Wake-up 활성화 여부

context.sendBroadcast(intent);
```

#### Wakeup만 제어

```java
// 왼쪽 스캔 키의 Wakeup만 활성화 (function 변경 안 함)
Intent intent = new Intent("com.m3.keytoolsl20.ACTION_SET_KEY");
intent.putExtra("key_title", "Right Scan");
intent.putExtra("key_wakeup", true);

context.sendBroadcast(intent);
```

#### Function만 제어

```java
// 왼쪽 스캔 키의 함수만 변경 (wakeup 설정 안 함)
Intent intent = new Intent("com.m3.keytoolsl20.ACTION_SET_KEY");
intent.putExtra("key_title", "Left Scan");
intent.putExtra("key_function", "Scan");

context.sendBroadcast(intent);
```

#### Function과 Wakeup 함께 제어

```java
// 키를 리매핑하고 결과를 받음
Intent intent = new Intent("com.m3.keytoolsl20.ACTION_SET_KEY");
intent.putExtra("key_title", "Left Scan");
intent.putExtra("key_function", "com.example.myapp");
intent.putExtra("key_wakeup", true);
intent.putExtra("key_setting_result_action", "com.example.myapp.KEY_SETTING_RESULT");

context.sendBroadcast(intent);
```

## API 참조

### 브로드캐스트 액션

**액션**: `com.m3.keytoolsl20.ACTION_SET_KEY`

### 파라미터

| 파라미터                        | 타입      | 필수 여부 | 설명                                       |
|-----------------------------|---------|-------|------------------------------------------|
| `key_title`                 | String  | 예     | 리매핑할 키 이름 (예: "Left Scan")               |
| `key_function`              | String  | 아니요   | 새로 할당할 함수 (예: "Scan", "com.example.app") |
| `key_wakeup`                | boolean | 아니요   | 이 키의 Wake-up 활성화/비활성화                    |
| `key_setting_result_action` | String  | 아니요   | 결과 콜백 브로드캐스트용 사용자 정의 액션                  |

**주의**: `key_function`과 `key_wakeup` 중 **최소 하나는 제공되어야 합니다**. (둘 다 생략 불가)

## 지원 키 및 할당 가능한 함수

사용 가능한 키와 할당 가능한 함수는 기기 모델에 따라 다릅니다.

### SL20

#### 지원 키
- `"Left Scan"` - 왼쪽 스캔 버튼
- `"Right Scan"` - 오른쪽 스캔 버튼 (사용 가능한 경우)
- `"Volume Up"` - 볼륨 업 키
- `"Volume Down"` - 볼륨 다운 키
- `"Back"` - 뒤로 버튼
- `"Home"` - 홈 버튼
- `"Recent"` - 최근 앱 버튼
- `"Camera"` - 카메라 버튼

#### 할당 가능한 함수
- **시스템 함수**: `"Default"`, `"Disable"`, `"Scan"`, `"Volume up"`, `"Volume down"`, `"Back"`, `"Home"`, `"Menu"`, `"Camera"`
- **특수 기능**: `"★"`
- **커스텀 앱**: 패키지 이름 (예: `"com.example.myapp"`)

### SL20P

#### 지원 키
- `"Left Scan"`, `"Right Scan"`, `"Volume Up"`, `"Volume Down"`, `"Back"`, `"Home"`, `"Recent"`, `"Camera"`

#### 할당 가능한 함수
- **시스템 함수**: `"Default"`, `"Disable"`, `"Scan"`, `"Volume up"`, `"Volume down"`, `"Back"`, `"Home"`, `"Menu"`, `"Camera"`
- **특수 기능**: `"★"`
- **커스텀 앱**: 패키지 이름 (예: `"com.example.myapp"`)
- **키보드 입력**:
  - **기능 키**: `"F1"` ~ `"F12"`
  - **탐색 키**: `"↑"`, `"↓"`, `"←"`, `"→"`, `"Enter"`, `"Tab"`, `"Space"`, `"Del"`, `"ESC"`, `"Search"`
  - **문자 및 숫자**: `"A"`-`"Z"`, `"a"`-`"z"`, `"0"`-`"9"`
  - **특수 문자**: `"`!`, `"@"`, `"#"` 등 (`"£"`, `"€"`, `"¥"`, `"₩"` 포함)

### SL20K

#### 지원 키
- **스캔 및 물리 버튼**: `"Left Scan"`, `"Right Scan"`, `"Volume Up"`, `"Volume Down"`, `"Back"`, `"Home"`, `"Recent"`, `"Camera"`, `"Front Scan"`
- **탐색 및 기능 키**: `"←"`, `"↑"`, `"↓"`, `"→"`, `"Enter"`, `"Esc"`, `"Tab"`, `"Shift"`, `"Delete"`, `"Alt"`, `"Ctrl"`, `"Fn"`
- **기능 키**: `"F1"` ~ `"F8"`
- **문자 및 숫자**: `"A"`-`"Z"`, `"0"`-`"9"`
- **특수 문자**: `"."`, `"★"`

#### 할당 가능한 함수
- SL20P와 동일한 모든 함수를 지원합니다.

### WD10

- 현재 개발 중입니다.

## 결과 콜백

`key_setting_result_action` 파라미터를 제공하면, KeyToolSL20이 결과 브로드캐스트를 전송합니다:

**액션**: 제공한 사용자 정의 액션 문자열 (예: `com.example.myapp.KEY_SETTING_RESULT`)

**결과 파라미터**:

| 파라미터                        | 타입     | 설명                   |
|-----------------------------|--------|----------------------|
| `key_setting_result_code`   | int    | 결과 코드 (0=성공, 양수=오류)  |
| `key_setting_error_message` | String | 오류 설명 (오류 발생 시에만 존재) |

### 결과 코드

| 코드  | 상수                                       | 설명            |
|-----|------------------------------------------|---------------|
| `0` | `KEY_SETTING_RESULT_OK`                  | 키 설정 성공       |
| `1` | `KEY_SETTING_RESULT_ERROR_INVALID_KEY`   | 키 이름을 찾을 수 없음 |
| `2` | `KEY_SETTING_RESULT_ERROR_FILE_WRITE`    | 파일 저장 실패      |
| `3` | `KEY_SETTING_RESULT_ERROR_MISSING_PARAM` | 필수 파라미터 누락    |

## 전체 예제

### Java 구현 예시

```java
public class KeySettingClient {
    private Context context;
    private BroadcastReceiver resultReceiver;

    public KeySettingClient(Context context) {
        this.context = context;
    }

    /**
     * 결과 콜백과 함께 키 매핑 설정
     */
    public void setKeyMapping(String keyTitle, String keyFunction, boolean enableWakeup) {
        if (keyTitle == null || keyTitle.isEmpty() || keyFunction == null || keyFunction.isEmpty()) {
            throw new IllegalArgumentException("키 이름과 함수는 비워 둘 수 없습니다");
        }

        // 결과 수신자 등록
        registerResultReceiver();

        // 키 설정 브로드캐스트 전송
        Intent intent = new Intent("com.m3.keytoolsl20.ACTION_SET_KEY");
        intent.putExtra("key_title", keyTitle);
        intent.putExtra("key_function", keyFunction);
        intent.putExtra("key_wakeup", enableWakeup);
        intent.putExtra("key_setting_result_action", "com.example.myapp.KEY_SETTING_RESULT");
        context.sendBroadcast(intent);

        android.util.Log.i("KeySettingClient", "키 매핑 요청 전송: title=" + keyTitle + ", function=" + keyFunction);
    }

    /**
     * 결과 콜백용 브로드캐스트 수신자 등록
     */
    private void registerResultReceiver() {
        if (resultReceiver != null) {
            return; // 이미 등록됨
        }

        resultReceiver = new BroadcastReceiver() {
            @Override
            public void onReceive(Context context, Intent intent) {
                int resultCode = intent.getIntExtra("key_setting_result_code", -1);
                String errorMessage = intent.getStringExtra("key_setting_error_message");

                if (resultCode == 0) {  // KEY_SETTING_RESULT_OK
                    android.util.Log.i("KeySettingClient", "키 매핑이 성공적으로 변경됨");
                    onKeyMappingSuccess();
                } else {
                    android.util.Log.e("KeySettingClient", "키 매핑 변경 실패: " + errorMessage);
                    onKeyMappingFailed(errorMessage);
                }
            }
        };

        android.content.IntentFilter filter = new android.content.IntentFilter("com.example.myapp.KEY_SETTING_RESULT");
        context.registerReceiver(resultReceiver, filter);
    }

    /**
     * 결과 수신자 등록 해제 (onDestroy에서 호출)
     */
    public void cleanup() {
        if (resultReceiver != null) {
            context.unregisterReceiver(resultReceiver);
            resultReceiver = null;
        }
    }

    /**
     * 성공 처리를 위해 오버라이드
     */
    protected void onKeyMappingSuccess() {
        // 성공 처리 (예: 토스트 표시, UI 업데이트)
    }

    /**
     * 실패 처리를 위해 오버라이드
     */
    protected void onKeyMappingFailed(String errorMessage) {
        // 실패 처리 (예: 오류 대화상자 표시)
    }
}
```

### Kotlin 구현 예시

```kotlin
class KeySettingClient(private val context: Context) {
    private var resultReceiver: BroadcastReceiver? = null

    /**
     * 결과 콜백과 함께 키 매핑 설정
     */
    fun setKeyMapping(keyTitle: String, keyFunction: String, enableWakeup: Boolean) {
        require(keyTitle.isNotEmpty()) { "키 이름은 비워 둘 수 없습니다" }
        require(keyFunction.isNotEmpty()) { "키 함수는 비워 둘 수 없습니다" }

        // 결과 수신자 등록
        registerResultReceiver()

        // 키 설정 브로드캐스트 전송
        val intent = Intent("com.m3.keytoolsl20.ACTION_SET_KEY").apply {
            putExtra("key_title", keyTitle)
            putExtra("key_function", keyFunction)
            putExtra("key_wakeup", enableWakeup)
            putExtra("key_setting_result_action", "com.example.myapp.KEY_SETTING_RESULT")
        }
        context.sendBroadcast(intent)

        android.util.Log.i("KeySettingClient", "키 매핑 요청 전송: title=$keyTitle, function=$keyFunction")
    }

    /**
     * 결과 콜백용 브로드캐스트 수신자 등록
     */
    private fun registerResultReceiver() {
        if (resultReceiver != null) {
            return // 이미 등록됨
        }

        resultReceiver = object : BroadcastReceiver() {
            override fun onReceive(context: Context?, intent: Intent?) {
                val resultCode = intent?.getIntExtra("key_setting_result_code", -1) ?: -1
                val errorMessage = intent?.getStringExtra("key_setting_error_message")

                if (resultCode == 0) {  // KEY_SETTING_RESULT_OK
                    android.util.Log.i("KeySettingClient", "키 매핑이 성공적으로 변경됨")
                    onKeyMappingSuccess()
                } else {
                    android.util.Log.e("KeySettingClient", "키 매핑 변경 실패: $errorMessage")
                    onKeyMappingFailed(errorMessage)
                }
            }
        }

        val filter = android.content.IntentFilter("com.example.myapp.KEY_SETTING_RESULT")
        context.registerReceiver(resultReceiver, filter)
    }

    /**
     * 결과 수신자 등록 해제 (onDestroy에서 호출)
     */
    fun cleanup() {
        resultReceiver?.let {
            context.unregisterReceiver(it)
            resultReceiver = null
        }
    }

    /**
     * 성공 처리를 위해 오버라이드
     */
    protected open fun onKeyMappingSuccess() {
        // 성공 처리 (예: 토스트 표시, UI 업데이트)
    }

    /**
     * 실패 처리를 위해 오버라이드
     */
    protected open fun onKeyMappingFailed(errorMessage: String?) {
        // 실패 처리 (예: 오류 대화상자 표시)
    }
}
```

### Activity에서 사용 예시

```java
public class MainActivity extends AppCompatActivity {
    private KeySettingClient keySettingClient;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        keySettingClient = new KeySettingClient(this) {
            @Override
            protected void onKeyMappingSuccess() {
                android.widget.Toast.makeText(MainActivity.this,
                        "키 매핑이 성공적으로 변경되었습니다", android.widget.Toast.LENGTH_SHORT).show();
            }

            @Override
            protected void onKeyMappingFailed(String errorMessage) {
                android.widget.Toast.makeText(MainActivity.this,
                        "실패: " + errorMessage, android.widget.Toast.LENGTH_LONG).show();
            }
        };

        // 예제: 왼쪽 스캔 키를 카메라 함수로 리매핑
        findViewById(R.id.btnRemapToCamera).setOnClickListener(v -> {
            keySettingClient.setKeyMapping("Left Scan", "Camera", false);
        });

        // 예제: 왼쪽 스캔 키를 커스텀 앱으로 리매핑
        findViewById(R.id.btnRemapToApp).setOnClickListener(v -> {
            keySettingClient.setKeyMapping("Left Scan", "com.example.myapp", true);
        });

        // 예제: 왼쪽 스캔 키를 F1로 리매핑
        findViewById(R.id.btnRemapToF1).setOnClickListener(v -> {
            keySettingClient.setKeyMapping("Left Scan", "F1", false);
        });
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        keySettingClient.cleanup();
    }
}
```

## ADB를 이용한 테스트

터미널에서 ADB(Android Debug Bridge) 명령어를 사용하여 키 설정 기능을 테스트할 수 있습니다.

### Wakeup만 제어

```bash
# 왼쪽 스캔 키의 Wakeup 활성화
adb shell am broadcast -a com.m3.keytoolsl20.ACTION_SET_KEY --es key_title "'Left Scan'" --ez key_wakeup true

# 오른쪽 스캔 키의 Wakeup 비활성화
adb shell am broadcast -a com.m3.keytoolsl20.ACTION_SET_KEY --es key_title "'Right Scan'" --ez key_wakeup false
```

### Function만 제어

```bash
# 왼쪽 스캔 키의 함수를 Scan으로 변경
adb shell am broadcast -a com.m3.keytoolsl20.ACTION_SET_KEY --es key_title "'Left Scan'" --es key_function "'Scan'"

# 왼쪽 스캔 키의 함수를 Volume up으로 변경
adb shell am broadcast -a com.m3.keytoolsl20.ACTION_SET_KEY --es key_title "'Left Scan'" --es key_function "'Volume up'"

# 여러 키를 다른 함수로 변경
adb shell am broadcast -a com.m3.keytoolsl20.ACTION_SET_KEY --es key_title "'Volume Up'" --es key_function "'Back'"
adb shell am broadcast -a com.m3.keytoolsl20.ACTION_SET_KEY --es key_title "'Volume Down'" --es key_function "'Disable'"
```

### Function과 Wakeup 함께 제어

```bash
# 키를 시스템 함수로 리매핑하면서 Wakeup 설정
adb shell am broadcast -a com.m3.keytoolsl20.ACTION_SET_KEY --es key_title "'Left Scan'" --es key_function "'Volume up'" --ez key_wakeup true
adb shell am broadcast -a com.m3.keytoolsl20.ACTION_SET_KEY --es key_title "'Volume Up'" --es key_function "'Scan'" --ez key_wakeup false
adb shell am broadcast -a com.m3.keytoolsl20.ACTION_SET_KEY --es key_title "'Volume Down'" --es key_function "'Disable'" --ez key_wakeup true
adb shell am broadcast -a com.m3.keytoolsl20.ACTION_SET_KEY --es key_title "'Right Scan'" --es key_function "'Default'" --ez key_wakeup false
```

### 커스텀 앱으로 함수 변경

```bash
# 키를 커스텀 앱으로 리매핑
adb shell am broadcast -a com.m3.keytoolsl20.ACTION_SET_KEY --es key_title "'Left Scan'" --es key_function "'com.example.myapplication'"

# 커스텀 앱으로 리매핑하면서 Wakeup 활성화
adb shell am broadcast -a com.m3.keytoolsl20.ACTION_SET_KEY --es key_title "'Left Scan'" --es key_function "'com.example.myapplication'" --ez key_wakeup true
```

### 키보드 입력으로 함수 변경

```bash
# 키를 키보드 함수로 변경
adb shell am broadcast -a com.m3.keytoolsl20.ACTION_SET_KEY --es key_title "'Left Scan'" --es key_function "'F1'"

# 키를 키보드 함수로 변경하면서 Wakeup 설정
adb shell am broadcast -a com.m3.keytoolsl20.ACTION_SET_KEY --es key_title "'Left Scan'" --es key_function "'F1'" --ez key_wakeup false
```

### 결과 콜백으로 테스트

```bash
# 결과를 모니터링할 logcat
adb logcat | Select-string "KeySettingClient"
# 혹은 adb logcat | grep "KeySettingClient"

# 다른 터미널에서 사용자 정의 결과 액션과 함께 키 설정 전송
adb shell am broadcast -a com.m3.keytoolsl20.ACTION_SET_KEY --es key_title "'Left Scan'" --es key_function "'Scan'" --ez key_wakeup true --es key_setting_result_action "com.example.myapp.KEY_SETTING_RESULT"

# Wakeup만 제어하면서 결과 콜백 받기
adb shell am broadcast -a com.m3.keytoolsl20.ACTION_SET_KEY --es key_title "'Right Scan'" --ez key_wakeup true --es key_setting_result_action "com.example.myapp.KEY_SETTING_RESULT"
```

### 유효하지 않은 파라미터 테스트 (오류 경우)

```bash
# 유효하지 않은 키 이름
adb shell am broadcast -a com.m3.keytoolsl20.ACTION_SET_KEY --es key_title "'InvalidKey'" --es key_function "'Scan'"

# 둘 다 생략 (오류 - 최소 하나는 제공되어야 함)
adb shell am broadcast -a com.m3.keytoolsl20.ACTION_SET_KEY --es key_title "'Left Scan'"

# key_title 누락 (오류 - 필수 파라미터)
adb shell am broadcast -a com.m3.keytoolsl20.ACTION_SET_KEY --es key_function "'Scan'"
```

## 오류 처리

### key_title 누락

**오류 메시지**: `"Required parameter is missing: key_title"`

**결과 코드**: `KEY_SETTING_RESULT_ERROR_MISSING_PARAM` (3)

**해결책**: 인텐트에 `key_title` 파라미터를 반드시 포함하세요.

### key_function과 key_wakeup 모두 누락

**오류 메시지**: `"Both key_function and key_wakeup are missing. At least one is required."`

**결과 코드**: `KEY_SETTING_RESULT_ERROR_MISSING_PARAM` (3)

**해결책**: `key_function` 또는 `key_wakeup` 중 최소 하나를 포함하세요.

### 유효하지 않은 키 이름

**오류 메시지**: `"Key not found: InvalidKeyName"`

**결과 코드**: `KEY_SETTING_RESULT_ERROR_INVALID_KEY` (1)

**해결책**: 지원 키 목록에서 유효한 키 이름을 사용하세요.

### 파일 저장 실패

**오류 메시지**: `"Failed to save key settings: [오류 세부 정보]"`

**결과 코드**: `KEY_SETTING_RESULT_ERROR_FILE_WRITE` (2)

**해결책**:
- 기기의 저장 공간 확인
- 파일 시스템 권한 확인
- KeyToolSL20 앱이 구성 파일에 쓰기 권한이 있는지 확인

## 상수 참조

### KeySettingReceiver의 공개 상수

```kotlin
// 브로드캐스트 액션
const val ACTION_SET_KEY = "com.m3.keytoolsl20.ACTION_SET_KEY"

// 결과 코드
const val KEY_SETTING_RESULT_OK = 0
const val KEY_SETTING_RESULT_ERROR_INVALID_KEY = 1
const val KEY_SETTING_RESULT_ERROR_FILE_WRITE = 2
const val KEY_SETTING_RESULT_ERROR_MISSING_PARAM = 3

// 결과 메시지 키
const val KEY_SETTING_EXTRA_ERROR_MESSAGE = "key_setting_error_message"
```
