# 비행기 모드 제어 SDK

> **참고** 이 기능은 StartUp V5.3.4부터 지원됩니다.

## 개요

이 SDK는 외부 Android 애플리케이션이 StartUp 앱과의 브로드캐스트 통신을 통해 기기의 비행기 모드를 켜거나 끌 수 있도록 합니다.

### 빠른 시작

#### 기본 사용법

```java
// 비행기 모드 활성화
Intent intent = new Intent("com.android.server.startupservice.system");
intent.putExtra("setting", "airplane");
intent.putExtra("airplane", true); // true: 켜기, false: 끄기
context.sendBroadcast(intent);
```

### API 참조

#### 브로드캐스트 액션

**Action**: `com.android.server.startupservice.system`

#### 파라미터

| 파라미터       | 타입      | 필수 | 설명                                        |
|------------|---------|----|-------------------------------------------|
| `setting`  | String  | 예  | 설정 타입. 비행기 모드 제어는 `"airplane"`을 사용합니다.    |
| `airplane` | boolean | 예  | 비행기 모드 상태. `true`는 활성화, `false`는 비활성화입니다. |

### 중요 사항

#### 1. 즉시 적용

이 설정은 브로드캐스트를 보내는 즉시 시스템에 적용됩니다.

### 전체 예제

#### 클라이언트 앱 구현

```java
public class AirplaneModeController {
    private Context context;

    public AirplaneModeController(Context context) {
        this.context = context;
    }

    /**
     * 비행기 모드 설정
     * @param enable true이면 활성화, false이면 비활성화
     */
    public void setAirplaneMode(boolean enable) {
        // 비행기 모드 설정 브로드캐스트 전송
        Intent intent = new Intent("com.android.server.startupservice.system");
        intent.putExtra("setting", "airplane");
        intent.putExtra("airplane", enable);
        context.sendBroadcast(intent);

        Log.i("AirplaneModeController", "비행기 모드 설정 전송: " + enable);
    }
}
```

#### Activity에서 사용

```java
public class MainActivity extends AppCompatActivity {
    private AirplaneModeController airplaneModeController;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        airplaneModeController = new AirplaneModeController(this);

        // 예제: 비행기 모드 켜기
        findViewById(R.id.btnAirplaneOn).setOnClickListener(v -> {
            airplaneModeController.setAirplaneMode(true);
            Toast.makeText(this, "비행기 모드를 켰습니다", Toast.LENGTH_SHORT).show();
        });

        // 예제: 비행기 모드 끄기
        findViewById(R.id.btnAirplaneOff).setOnClickListener(v -> {
            airplaneModeController.setAirplaneMode(false);
            Toast.makeText(this, "비행기 모드를 껐습니다", Toast.LENGTH_SHORT).show();
        });
    }
}
```

### ADB로 테스트하기

ADB(Android Debug Bridge) 명령을 사용하여 터미널에서 비행기 모드 설정 기능을 테스트할 수 있습니다.

#### 비행기 모드 켜기

```bash
adb shell am broadcast -a com.android.server.startupservice.system --es setting "airplane" --ez airplane true
```

#### 비행기 모드 끄기

```bash
adb shell am broadcast -a com.android.server.startupservice.system --es setting "airplane" --ez airplane false
```

#### 설정 확인

비행기 모드 상태는 기기의 상태 표시줄이나 설정 메뉴에서 시각적으로 확인할 수 있습니다. 또는 다음 명령어로 시스템 설정을 확인할 수 있습니다.

```bash
# '1'은 켜짐, '0'은 꺼짐을 의미합니다.
adb shell settings get global airplane_mode_on
```
