# Wi-Fi 주파수 대역 설정 SDK

> **Note** <br>
> StartUp 버전 6.0.6 BETA 버전부터 지원합니다. <br>
> SM15, SL10, SL10K 기기는 지원하지 않습니다.

## 개요

이 SDK는 외부 Android 애플리케이션이 StartUp 앱과의 브로드캐스트 통신을 통해 기기의 Wi-Fi 스캔 및 연결을 특정 주파수 대역(2.4GHz 또는 5GHz)으로 제한할 수 있도록 합니다.

주파수 대역을 제한하면 기기가 특정 대역의 AP만 스캔하고 연결하므로, 네트워크 환경에 맞는 최적화된 Wi-Fi 설정이 가능합니다.

지원되는 주파수 대역:
- **AUTO (0)**: 2.4GHz + 5GHz 모두 사용 (기본값)
- **5GHz만 (1)**: 5GHz 대역만 스캔 및 연결
- **2.4GHz만 (2)**: 2.4GHz 대역만 스캔 및 연결

### 빠른 시작

#### 기본 사용법

```java
// AUTO 모드 (2.4GHz + 5GHz 모두 사용)
Intent intent = new Intent("com.android.server.startupservice.config");
intent.putExtra("setting", "wifi_freq_band");
intent.putExtra("value", 0);
context.sendBroadcast(intent);

// 5GHz만 사용
Intent intent5G = new Intent("com.android.server.startupservice.config");
intent5G.putExtra("setting", "wifi_freq_band");
intent5G.putExtra("value", 1);
context.sendBroadcast(intent5G);

// 2.4GHz만 사용
Intent intent24G = new Intent("com.android.server.startupservice.config");
intent24G.putExtra("setting", "wifi_freq_band");
intent24G.putExtra("value", 2);
context.sendBroadcast(intent24G);
```

### API 참조

#### 브로드캐스트 액션

**Action**: `com.android.server.startupservice.config`

#### 파라미터

| 파라미터      | 타입     | 필수 | 설명                                                               |
|-----------|--------|----|------------------------------------------------------------------|
| `setting` | String | 예  | 반드시 `"wifi_freq_band"`로 설정해야 합니다.                                |
| `value`   | int    | 예  | 주파수 대역 설정 값<br>0: AUTO (2.4GHz + 5GHz)<br>1: 5GHz만<br>2: 2.4GHz만 |

---

### 세부 설정 가이드

#### 주파수 대역 옵션

**AUTO (0) - 듀얼 밴드**
- 2.4GHz와 5GHz 모두 사용 가능
- 기기가 자동으로 최적의 대역 선택
- 대부분의 환경에서 권장되는 기본값

**5GHz만 (1)**
- 5GHz 대역만 스캔 및 연결
- 더 빠른 속도와 적은 간섭
- 5GHz AP가 있는 환경에서 권장
- 장점: 높은 대역폭, 적은 간섭
- 단점: 전파 도달 거리가 짧음

**2.4GHz만 (2)**
- 2.4GHz 대역만 스캔 및 연결
- 더 넓은 커버리지
- 2.4GHz AP만 있는 환경에서 사용
- 장점: 넓은 커버리지, 장애물 통과 우수
- 단점: 간섭 가능성 높음, 상대적으로 낮은 속도

---

### 일반적인 사용 시나리오

#### 시나리오 1: 창고/물류센터 (2.4GHz만)

넓은 공간에서 장애물이 많은 환경:

```java
Intent intent = new Intent("com.android.server.startupservice.config");
intent.putExtra("setting", "wifi_freq_band");
intent.putExtra("value", 2); // 2.4GHz만
context.sendBroadcast(intent);
```

#### 시나리오 2: 사무실/고속 데이터 전송 (5GHz만)

간섭이 적고 고속 통신이 필요한 환경:

```java
Intent intent = new Intent("com.android.server.startupservice.config");
intent.putExtra("setting", "wifi_freq_band");
intent.putExtra("value", 1); // 5GHz만
context.sendBroadcast(intent);
```

#### 시나리오 3: 일반 환경 (AUTO)

다양한 환경에서 사용하는 경우:

```java
Intent intent = new Intent("com.android.server.startupservice.config");
intent.putExtra("setting", "wifi_freq_band");
intent.putExtra("value", 0); // AUTO
context.sendBroadcast(intent);
```

---

### wifi-channel-sdk와의 연계 사용

wifi-frequency-sdk는 주파수 대역(2.4GHz/5GHz) 전체를 제어하고, wifi-channel-sdk는 각 대역 내 특정 채널을 세밀하게 제어합니다.

더 세밀한 제어가 필요한 경우 두 SDK를 함께 사용할 수 있습니다:

#### 연계 사용 예제

**예제: 2.4GHz 대역의 비중첩 채널(1, 6, 11)만 사용**

```java
// 1단계: 주파수 대역을 2.4GHz로 제한
Intent freqIntent = new Intent("com.android.server.startupservice.config");
freqIntent.putExtra("setting", "wifi_freq_band");
freqIntent.putExtra("value", 2); // 2.4GHz만
context.sendBroadcast(freqIntent);

// 2단계: 2.4GHz 대역 내에서 채널 1, 6, 11만 사용
Intent channelIntent = new Intent("com.android.server.startupservice.config");
channelIntent.putExtra("setting", "wifi_channel");
String[] channels = {"1", "6", "11"};
channelIntent.putExtra("value", channels);
context.sendBroadcast(channelIntent);
```

**예제: 5GHz 대역의 비DFS 채널만 사용**

```java
// 1단계: 주파수 대역을 5GHz로 제한
Intent freqIntent = new Intent("com.android.server.startupservice.config");
freqIntent.putExtra("setting", "wifi_freq_band");
freqIntent.putExtra("value", 1); // 5GHz만
context.sendBroadcast(freqIntent);

// 2단계: 5GHz 대역 내에서 비DFS 채널만 사용
Intent channelIntent = new Intent("com.android.server.startupservice.config");
channelIntent.putExtra("setting", "wifi_channel");
String[] channels = {"36", "40", "44", "48", "149", "153", "157", "161", "165"};
channelIntent.putExtra("value", channels);
context.sendBroadcast(channelIntent);
```

**참고**: wifi-channel-sdk에 대한 자세한 내용은 [Wi-Fi 채널 설정 SDK 문서](wifi-channel-sdk-readme-ko.md)를 참조하세요.

---

### 전체 예제

#### 클라이언트 앱 구현

```java
public class WifiFrequencyController {
    private Context context;

    public WifiFrequencyController(Context context) {
        this.context = context;
    }

    /**
     * Wi-Fi 주파수 대역 설정
     *
     * @param band 주파수 대역 (0: AUTO, 1: 5GHz, 2: 2.4GHz)
     */
    public void setWifiFrequencyBand(int band) {
        // 값 유효성 검증
        if (band < 0 || band > 2) {
            Log.e("WifiFrequencyController", "Invalid band value: " + band);
            return;
        }

        // Wi-Fi 주파수 대역 설정 브로드캐스트 전송
        Intent intent = new Intent("com.android.server.startupservice.config");
        intent.putExtra("setting", "wifi_freq_band");
        intent.putExtra("value", band);
        context.sendBroadcast(intent);

        String bandName = getBandName(band);
        Log.i("WifiFrequencyController", "Wi-Fi frequency band set to: " + bandName);
    }

    /**
     * AUTO 모드 설정 (2.4GHz + 5GHz)
     */
    public void setAuto() {
        setWifiFrequencyBand(0);
    }

    /**
     * 5GHz만 사용
     */
    public void set5GHzOnly() {
        setWifiFrequencyBand(1);
    }

    /**
     * 2.4GHz만 사용
     */
    public void set24GHzOnly() {
        setWifiFrequencyBand(2);
    }

    /**
     * 대역 이름 반환
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

#### Activity에서 사용

```java
public class MainActivity extends AppCompatActivity {
    private WifiFrequencyController wifiFrequencyController;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        wifiFrequencyController = new WifiFrequencyController(this);

        // AUTO 모드
        findViewById(R.id.btnSetAuto).setOnClickListener(v -> {
            wifiFrequencyController.setAuto();
            Toast.makeText(this, "AUTO 모드 설정 (2.4GHz + 5GHz)", Toast.LENGTH_SHORT).show();
        });

        // 5GHz만
        findViewById(R.id.btnSet5GHzOnly).setOnClickListener(v -> {
            wifiFrequencyController.set5GHzOnly();
            Toast.makeText(this, "5GHz 전용 모드 설정", Toast.LENGTH_SHORT).show();
        });

        // 2.4GHz만
        findViewById(R.id.btnSet24GHzOnly).setOnClickListener(v -> {
            wifiFrequencyController.set24GHzOnly();
            Toast.makeText(this, "2.4GHz 전용 모드 설정", Toast.LENGTH_SHORT).show();
        });
    }
}
```

#### Kotlin에서 사용

```kotlin
class WifiFrequencyController(private val context: Context) {

    /**
     * Wi-Fi 주파수 대역 설정
     */
    fun setWifiFrequencyBand(band: Int) {
        // 값 유효성 검증
        if (band !in 0..2) {
            Log.e("WifiFrequencyController", "Invalid band value: $band")
            return
        }

        // Wi-Fi 주파수 대역 설정 브로드캐스트 전송
        Intent("com.android.server.startupservice.config").apply {
            putExtra("setting", "wifi_freq_band")
            putExtra("value", band)
            context.sendBroadcast(this)
        }

        Log.i("WifiFrequencyController", "Wi-Fi frequency band set to: ${getBandName(band)}")
    }

    /**
     * AUTO 모드 설정 (2.4GHz + 5GHz)
     */
    fun setAuto() = setWifiFrequencyBand(0)

    /**
     * 5GHz만 사용
     */
    fun set5GHzOnly() = setWifiFrequencyBand(1)

    /**
     * 2.4GHz만 사용
     */
    fun set24GHzOnly() = setWifiFrequencyBand(2)

    /**
     * 대역 이름 반환
     */
    private fun getBandName(band: Int): String = when (band) {
        0 -> "AUTO (2.4GHz + 5GHz)"
        1 -> "5GHz only"
        2 -> "2.4GHz only"
        else -> "Unknown"
    }
}

// Kotlin Activity 사용 예제
class MainActivity : AppCompatActivity() {
    private lateinit var wifiFrequencyController: WifiFrequencyController

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        wifiFrequencyController = WifiFrequencyController(this)

        // AUTO 모드
        findViewById<Button>(R.id.btnSetAuto).setOnClickListener {
            wifiFrequencyController.setAuto()
            Toast.makeText(this, "AUTO 모드 설정", Toast.LENGTH_SHORT).show()
        }

        // 5GHz만
        findViewById<Button>(R.id.btnSet5GHzOnly).setOnClickListener {
            wifiFrequencyController.set5GHzOnly()
            Toast.makeText(this, "5GHz 전용 모드 설정", Toast.LENGTH_SHORT).show()
        }

        // 2.4GHz만
        findViewById<Button>(R.id.btnSet24GHzOnly).setOnClickListener {
            wifiFrequencyController.set24GHzOnly()
            Toast.makeText(this, "2.4GHz 전용 모드 설정", Toast.LENGTH_SHORT).show()
        }
    }
}
```

---

### ADB로 테스트하기

#### AUTO 모드 (2.4GHz + 5GHz)

```bash
adb shell am broadcast -a com.android.server.startupservice.config --es setting "wifi_freq_band" --ei value 0
```

#### 5GHz만 사용

```bash
adb shell am broadcast -a com.android.server.startupservice.config --es setting "wifi_freq_band" --ei value 1
```

#### 2.4GHz만 사용

```bash
adb shell am broadcast -a com.android.server.startupservice.config --es setting "wifi_freq_band" --ei value 2
```

---

### 주의사항

1. **재연결 필요**: 주파수 대역 설정 변경 후에는 Wi-Fi를 껐다 켜거나 기기를 재시작해야 설정이 완전히 적용될 수 있습니다.

2. **네트워크 환경 고려**:
   - 5GHz 전용 모드 설정 시 2.4GHz AP만 있는 환경에서는 연결 불가
   - 2.4GHz 전용 모드 설정 시 5GHz AP만 있는 환경에서는 연결 불가

3. **기기별 구현 차이**: 일부 기기에서는 내부 구현 방식이 다를 수 있으나, SDK 사용 방법은 동일합니다.

4. **wifi-channel-sdk와 함께 사용**: 더 세밀한 채널 제어가 필요한 경우 wifi-channel-sdk와 연계하여 사용할 수 있습니다.

5. **기본값**: 설정하지 않은 경우 AUTO 모드(0)가 기본값입니다.

---
