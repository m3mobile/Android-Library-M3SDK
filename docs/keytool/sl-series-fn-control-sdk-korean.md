# FN 키 제어 SDK

>**참고:** 이 기능은 KeyTool V1.2.6 이상이면서 SL20K 에서만 가능합니다.

## 개요

이 SDK는 외부 안드로이드 애플리케이션이 KeyToolSL20 애플리케이션과의 브로드캐스트 통신을 통해 FN 키 상태를 제어할 수 있도록 합니다.
FN 키는 비활성화, 활성화 또는 잠금 상태로 설정할 수 있습니다.

### 빠른 시작

#### 기본 사용법

```java
// FN 키를 활성화 상태로 설정
Intent intent = new Intent("com.m3.keytoolsl20.ACTION_CONTROL_FN_STATE");
intent.putExtra("fn_state", 1);  // 0=비활성화, 1=활성화, 2=잠금

context.sendBroadcast(intent);
```

#### 결과 콜백 사용

```java
// FN 키 상태 변경을 요청하고 결과를 받음
Intent intent = new Intent("com.m3.keytoolsl20.ACTION_CONTROL_FN_STATE");
intent.putExtra("fn_state", 1);
intent.putExtra("fn_control_result_action", "com.example.myapp.FN_CONTROL_RESULT");

context.sendBroadcast(intent);
```

## API 참조

### 브로드캐스트 액션

**액션**: `com.m3.keytoolsl20.ACTION_CONTROL_FN_STATE`

### 파라미터

| 파라미터                       | 타입      | 필수 여부 | 설명                           |
|----------------------------|---------|-------|------------------------------|
| `fn_state`                 | Integer | 예     | FN 키 상태: 0=비활성화, 1=활성화, 2=잠금 |
| `fn_control_result_action` | String  | 아니요   | 결과 콜백 브로드캐스트용 사용자 정의 액션      |

## FN 키 상태

| 상태값 | 이름        | 설명          |
|-----|-----------|-------------|
| `0` | `DISABLE` | FN 키가 비활성화됨 |
| `1` | `ENABLE`  | FN 키가 활성화됨  |
| `2` | `LOCK`    | FN 키가 잠김    |

## 결과 콜백

`fn_control_result_action` 파라미터를 제공하면, KeyToolSL20이 결과 브로드캐스트를 전송합니다:

**액션**: 제공한 사용자 정의 액션 문자열 (예: `com.example.myapp.FN_CONTROL_RESULT`)

**결과 파라미터**:

| 파라미터                       | 타입     | 설명                   |
|----------------------------|--------|----------------------|
| `fn_control_result_code`   | int    | 결과 코드 (0=성공, 양수=오류)  |
| `fn_control_error_message` | String | 오류 설명 (오류 발생 시에만 존재) |

### 결과 코드

| 코드  | 상수                                            | 설명                           |
|-----|-----------------------------------------------|------------------------------|
| `0` | `FN_CONTROL_RESULT_OK`                        | FN 키 상태가 성공적으로 변경됨           |
| `1` | `FN_CONTROL_RESULT_ERROR_SERVICE_CALL`        | PlatformService 호출 중 오류 발생   |
| `2` | `FN_CONTROL_RESULT_ERROR_INVALID_STATE`       | 유효하지 않은 FN 상태값 (0, 1, 2가 아님) |
| `3` | `FN_CONTROL_RESULT_ERROR_SERVICE_BIND_FAILED` | PlatformService 바인딩 실패       |
| `4` | `FN_CONTROL_RESULT_ERROR_TIMEOUT`             | PlatformService 연결 타임아웃      |

## 전체 예제

### Java 구현 예시

```java
public class FnControlClient {
    private Context context;
    private BroadcastReceiver resultReceiver;

    public FnControlClient(Context context) {
        this.context = context;
    }

    /**
     * 결과 콜백과 함께 FN 키 상태 설정
     */
    public void setFnState(int state) {
        if (state < 0 || state > 2) {
            throw new IllegalArgumentException("FN 상태는 0, 1, 또는 2여야 합니다");
        }

        // 결과 수신자 등록
        registerResultReceiver();

        // FN 키 상태 변경 브로드캐스트 전송
        Intent intent = new Intent("com.m3.keytoolsl20.ACTION_CONTROL_FN_STATE");
        intent.putExtra("fn_state", state);
        intent.putExtra("fn_control_result_action", "com.example.myapp.FN_CONTROL_RESULT");
        context.sendBroadcast(intent);

        String stateName = getStateName(state);
        android.util.Log.i("FnControlClient", "FN 키 상태 변경 요청: state=" + stateName);
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
                int resultCode = intent.getIntExtra("fn_control_result_code", -1);
                String errorMessage = intent.getStringExtra("fn_control_error_message");

                if (resultCode == 0) {  // FN_CONTROL_RESULT_OK
                    android.util.Log.i("FnControlClient", "FN 키 상태가 성공적으로 변경됨");
                    onFnStateSetSuccess();
                } else {
                    android.util.Log.e("FnControlClient", "FN 키 상태 변경 실패: " + errorMessage);
                    onFnStateSetFailed(errorMessage);
                }
            }
        };

        android.content.IntentFilter filter = new android.content.IntentFilter("com.example.myapp.FN_CONTROL_RESULT");
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
    protected void onFnStateSetSuccess() {
        // 성공 처리 (예: 토스트 표시, UI 업데이트)
    }

    /**
     * 실패 처리를 위해 오버라이드
     */
    protected void onFnStateSetFailed(String errorMessage) {
        // 실패 처리 (예: 오류 대화상자 표시)
    }

    private String getStateName(int state) {
        switch (state) {
            case 0: return "DISABLE";
            case 1: return "ENABLE";
            case 2: return "LOCK";
            default: return "UNKNOWN";
        }
    }
}
```

### Kotlin 구현 예시

```kotlin
class FnControlClient(private val context: Context) {
    private var resultReceiver: BroadcastReceiver? = null

    /**
     * 결과 콜백과 함께 FN 키 상태 설정
     */
    fun setFnState(state: Int) {
        require(state in 0..2) { "FN 상태는 0, 1, 또는 2여야 합니다" }

        // 결과 수신자 등록
        registerResultReceiver()

        // FN 키 상태 변경 브로드캐스트 전송
        val intent = Intent("com.m3.keytoolsl20.ACTION_CONTROL_FN_STATE").apply {
            putExtra("fn_state", state)
            putExtra("fn_control_result_action", "com.example.myapp.FN_CONTROL_RESULT")
        }
        context.sendBroadcast(intent)

        val stateName = getStateName(state)
        android.util.Log.i("FnControlClient", "FN 키 상태 변경 요청: state=$stateName")
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
                val resultCode = intent?.getIntExtra("fn_control_result_code", -1) ?: -1
                val errorMessage = intent?.getStringExtra("fn_control_error_message")

                if (resultCode == 0) {  // FN_CONTROL_RESULT_OK
                    android.util.Log.i("FnControlClient", "FN 키 상태가 성공적으로 변경됨")
                    onFnStateSetSuccess()
                } else {
                    android.util.Log.e("FnControlClient", "FN 키 상태 변경 실패: $errorMessage")
                    onFnStateSetFailed(errorMessage)
                }
            }
        }

        val filter = android.content.IntentFilter("com.example.myapp.FN_CONTROL_RESULT")
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
    protected open fun onFnStateSetSuccess() {
        // 성공 처리 (예: 토스트 표시, UI 업데이트)
    }

    /**
     * 실패 처리를 위해 오버라이드
     */
    protected open fun onFnStateSetFailed(errorMessage: String?) {
        // 실패 처리 (예: 오류 대화상자 표시)
    }

    private fun getStateName(state: Int): String = when (state) {
        0 -> "DISABLE"
        1 -> "ENABLE"
        2 -> "LOCK"
        else -> "UNKNOWN"
    }
}
```

### Activity에서 사용 예시

```java
public class MainActivity extends AppCompatActivity {
    private FnControlClient fnControlClient;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        fnControlClient = new FnControlClient(this) {
            @Override
            protected void onFnStateSetSuccess() {
                android.widget.Toast.makeText(MainActivity.this,
                        "FN 키 상태가 변경되었습니다", android.widget.Toast.LENGTH_SHORT).show();
            }

            @Override
            protected void onFnStateSetFailed(String errorMessage) {
                android.widget.Toast.makeText(MainActivity.this,
                        "실패: " + errorMessage, android.widget.Toast.LENGTH_LONG).show();
            }
        };

        // 예제: FN 키를 활성화로 설정
        findViewById(R.id.btnEnable).setOnClickListener(v -> {
            fnControlClient.setFnState(1);
        });

        // 예제: FN 키를 비활성화로 설정
        findViewById(R.id.btnDisable).setOnClickListener(v -> {
            fnControlClient.setFnState(0);
        });

        // 예제: FN 키를 잠금으로 설정
        findViewById(R.id.btnLock).setOnClickListener(v -> {
            fnControlClient.setFnState(2);
        });
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        fnControlClient.cleanup();
    }
}
```

## ADB를 이용한 테스트

터미널에서 ADB(Android Debug Bridge) 명령어를 사용하여 FN 키 제어 기능을 테스트할 수 있습니다.

### FN 키를 활성화로 설정

```bash
adb shell am broadcast -a com.m3.keytoolsl20.ACTION_CONTROL_FN_STATE --ei fn_state 1
```

### FN 키를 비활성화로 설정

```bash
adb shell am broadcast -a com.m3.keytoolsl20.ACTION_CONTROL_FN_STATE --ei fn_state 0
```

### FN 키를 잠금으로 설정

```bash
adb shell am broadcast -a com.m3.keytoolsl20.ACTION_CONTROL_FN_STATE --ei fn_state 2
```

### 결과 콜백으로 테스트

```bash
# 결과를 모니터링할 logcat
adb logcat | grep "FnControlClient"

# 다른 터미널에서 사용자 정의 결과 액션과 함께 FN 키 상태 변경 전송
adb shell am broadcast -a com.m3.keytoolsl20.ACTION_CONTROL_FN_STATE \
    --ei fn_state 1 \
    --es fn_control_result_action "com.example.myapp.FN_CONTROL_RESULT"
```

### 유효하지 않은 상태값 테스트 (오류 경우)

```bash
adb shell am broadcast -a com.m3.keytoolsl20.ACTION_CONTROL_FN_STATE --ei fn_state 5
```

## 오류 처리

### 유효하지 않은 FN 상태값

**오류 메시지**: `"Invalid FN state: 5. Must be 0, 1, or 2."`

**결과 코드**: `FN_CONTROL_RESULT_ERROR_INVALID_STATE` (2)

**해결책**: 유효한 FN 상태값(0, 1, 또는 2)을 입력했는지 확인하세요.

### 서비스 바인딩 실패

**오류 메시지**: `"Failed to bind to PlatformService"`

**결과 코드**: `FN_CONTROL_RESULT_ERROR_SERVICE_BIND_FAILED` (3)

**해결책**:
- KeyToolSL20 앱이 설치되어 있고 실행 중인지 확인
- 기기에 시스템 권한(sharedUserId)이 있는지 확인
- 매니페스트에 권한 관련 문제가 없는지 확인

### 서비스 호출 오류

**오류 메시지**: `"RemoteException: [오류 세부 정보]"`

**결과 코드**: `FN_CONTROL_RESULT_ERROR_SERVICE_CALL` (1)

**해결책**: logcat에서 자세한 오류 정보를 확인하고 시스템 상태를 확인하세요.

### 연결 타임아웃

**오류 메시지**: `"PlatformService connection timeout"`

**결과 코드**: `FN_CONTROL_RESULT_ERROR_TIMEOUT` (4)

**해결책**:
- PlatformService가 실행 중인지 확인
- 기기 성능 및 시스템 부하 확인
- 잠시 후 작업을 다시 시도

## 상수 참조

### FnControlReceiver의 공개 상수

```kotlin
// 브로드캐스트 액션
const val ACTION_CONTROL_FN_STATE = "com.m3.keytoolsl20.ACTION_CONTROL_FN_STATE"

// 결과 코드
const val FN_CONTROL_RESULT_OK = 0
const val FN_CONTROL_RESULT_CANCELED = -1
const val FN_CONTROL_RESULT_ERROR_SERVICE_CALL = 1
const val FN_CONTROL_RESULT_ERROR_INVALID_STATE = 2
const val FN_CONTROL_RESULT_ERROR_SERVICE_BIND_FAILED = 3
const val FN_CONTROL_RESULT_ERROR_TIMEOUT = 4

// 결과 메시지 키
const val FN_CONTROL_EXTRA_ERROR_MESSAGE = "fn_control_error_message"
```
