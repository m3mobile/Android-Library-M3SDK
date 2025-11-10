# NTP 서버 설정 제어 SDK

> **참고** <br>
> 이 기능은 StartUp 버전 6.4.9 부터 지원됩니다.

## 개요

이 SDK는 외부 Android 애플리케이션이 StartUp 앱과의 브로드캐스트 통신을 통해 기기의 NTP(Network Time Protocol) 서버 설정을 제어할 수 있도록 합니다.

**중요**: 설정 변경은 기기 재부팅 후에 적용됩니다.

**지원 기기**: StartUp 앱이 설치된 모든 M3 Mobile 기기

### 빠른 시작

#### 기본 사용법

```java
// NTP 서버를 Google 공개 NTP 서버로 설정
Intent intent = new Intent("com.android.server.startupservice.system");
intent.putExtra("setting","ntp");
intent.putExtra("ntp_server","time.google.com");

context.sendBroadcast(intent);
```

### API 참조

#### 브로드캐스트 액션

**Action**: `com.android.server.startupservice.system`

#### 파라미터

| 파라미터         | 타입     | 필수 | 설명                                                         |
|--------------|--------|----|------------------------------------------------------------|
| `setting`    | String | 예  | 설정 타입. NTP 서버 제어는 `"ntp"`를 사용합니다.                          |
| `ntp_server` | String | 예  | NTP 서버 URL 또는 IP 주소 (예: "time.google.com", "pool.ntp.org") |

#### NTP 서버 예시

| 서버 주소                 | 설명                     | 지역  |
|-----------------------|------------------------|-----|
| `time.google.com`     | Google 공개 NTP          | 글로벌 |


### 중요 사항

#### 1. 재부팅 필요

NTP 서버 설정은 **다음 기기 재부팅 후**에 적용됩니다. 시스템에서 다음 토스트 메시지를 표시합니다:

#### 2. 결과 콜백 없음

이 API는 결과 콜백을 지원하지 않습니다.
설정은 즉시 시스템에 저장되지만 적용하려면 재부팅이 필요합니다.

#### 3. 유효성 검사

- API는 NTP 서버 주소가 유효한지 검증하지 않습니다
- 올바른 NTP 서버 URL 또는 IP 주소를 제공해야 합니다
- 잘못된 서버는 오류를 발생시키지 않지만 시간 동기화 실패를 초래할 수 있습니다

### 전체 예제

#### 클라이언트 앱 구현

```java
public class NtpController {
    private Context context;

    public NtpController(Context context) {
        this.context = context;
    }

    /**
     * NTP 서버 설정
     * @param ntpServer NTP 서버 URL 또는 IP 주소 (예: "time.google.com")
     */
    public void setNtpServer(String ntpServer) {
        if (ntpServer == null || ntpServer.trim().isEmpty()) {
            Log.e("NtpController", "NTP 서버는 비어있을 수 없습니다");
            return;
        }

        // NTP 설정 브로드캐스트 전송
        Intent intent = new Intent("com.android.server.startupservice.system");
        intent.putExtra("setting", "ntp");
        intent.putExtra("ntp_server", ntpServer);
        context.sendBroadcast(intent);

        Log.i("NtpController", "NTP 서버 설정 전송: " + ntpServer);
    }
}
```

#### Activity에서 사용

```java
public class MainActivity extends AppCompatActivity {
    private NtpController ntpController;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        ntpController = new NtpController(this);

        // 예제: NTP 서버를 Google 공개 NTP로 설정
        findViewById(R.id.btnGoogleNtp).setOnClickListener(v -> {
            ntpController.setNtpServer("time.google.com");
            Toast.makeText(this,
                    "NTP 서버를 time.google.com으로 설정했습니다\n적용하려면 재부팅이 필요합니다",
                    Toast.LENGTH_LONG).show();
        });

        // 예제: NTP 서버를 NTP Pool 프로젝트로 설정
        findViewById(R.id.btnPoolNtp).setOnClickListener(v -> {
            ntpController.setNtpServer("pool.ntp.org");
            Toast.makeText(this,
                    "NTP 서버를 pool.ntp.org로 설정했습니다\n적용하려면 재부팅이 필요합니다",
                    Toast.LENGTH_LONG).show();
        });

        // 예제: 사용자 정의 NTP 서버 설정
        findViewById(R.id.btnCustomNtp).setOnClickListener(v -> {
            EditText etCustomNtp = findViewById(R.id.etCustomNtp);
            String customServer = etCustomNtp.getText().toString().trim();

            if (!customServer.isEmpty()) {
                ntpController.setNtpServer(customServer);
                Toast.makeText(this,
                        "NTP 서버를 " + customServer + "로 설정했습니다\n적용하려면 재부팅이 필요합니다",
                        Toast.LENGTH_LONG).show();
            } else {
                Toast.makeText(this,
                        "유효한 NTP 서버 주소를 입력하세요",
                        Toast.LENGTH_SHORT).show();
            }
        });
    }
}
```

### ADB로 테스트하기

ADB(Android Debug Bridge) 명령을 사용하여 터미널에서 NTP 서버 설정 기능을 테스트할 수 있습니다.

#### NTP 서버 설정 (Google)

```bash
adb shell am broadcast -a com.android.server.startupservice.system --es setting "ntp" --es ntp_server "time.google.com"
```

#### 설정 확인

```bash
# 현재 NTP 서버 설정 확인
adb shell settings get global ntp_server
```
