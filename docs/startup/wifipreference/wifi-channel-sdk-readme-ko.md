# Wi-Fi 채널 설정 SDK

> [!WARNING]
> StartUp 버전 6.0.6 BETA 버전부터 지원합니다.
>
> SM15, SL10, SL10K 기기는 지원하지 않습니다.

## 개요

이 SDK는 외부 Android 애플리케이션이 StartUp 앱과의 브로드캐스트 통신을 통해 
기기의 Wi-Fi 스캔 및 연결을 특정 채널로 제한할 수 있도록 합니다.

Wi-Fi 채널을 제한하면 기기가 특정 채널의 AP만 스캔하고 연결하므로, 
불필요한 채널을 차단하여 연결 속도를 개선하거나 특정 네트워크 정책을 적용할 수 있습니다.

지원되는 채널:
- **2.4 GHz 대역**: 채널 1 ~ 13
- **5 GHz 대역**: 채널 36, 40, 44, 48, 52, 56, 60, 64, 100, 104, 108, 112, 116, 120, 124, 128, 132, 136, 140, 144, 149, 153, 157, 161, 165

> **⚠️ 중요**: US30 등 일부 기기에서는 한 주파수 대역의 채널만 설정할 경우, 설정하지 않은 다른 주파수 대역의 모든 채널이 활성화됩니다. 
> 자세한 내용은 [특정 기기에서의 주의사항](#특정-기기에서의-주의사항) 섹션을 참조하세요.

### 빠른 시작

#### 기본 사용법

```java
// Wi-Fi 채널을 1, 6, 11 (2.4GHz) 및 36, 40 (5GHz)으로 제한
Intent intent = new Intent("com.android.server.startupservice.config");
intent.putExtra("setting", "wifi_channel");
String[] channels = {"1", "6", "11", "36", "40"};
intent.putExtra("value", channels);
context.sendBroadcast(intent);

// 2.4GHz 채널만 사용 (1, 6, 11)
Intent intent24 = new Intent("com.android.server.startupservice.config");
intent24.putExtra("setting", "wifi_channel");
String[] channels24 = {"1", "6", "11"};
intent24.putExtra("value", channels24);
context.sendBroadcast(intent24);

// 5GHz 채널만 사용 (36, 40, 149, 153)
Intent intent5 = new Intent("com.android.server.startupservice.config");
intent5.putExtra("setting", "wifi_channel");
String[] channels5 = {"36", "40", "149", "153"};
intent5.putExtra("value", channels5);
context.sendBroadcast(intent5);
```

### API 참조

#### 브로드캐스트 액션

**Action**: `com.android.server.startupservice.config`

#### 파라미터

| 파라미터      | 타입       | 필수 | 설명                                             |
|-----------|----------|----|------------------------------------------------|
| `setting` | String   | 예  | 반드시 `"wifi_channel"`로 설정해야 합니다.                |
| `value`   | String[] | 예  | 활성화할 Wi-Fi 채널 번호의 문자열 배열 (예: {"1", "6", "11"}) |

---

## ⚠️ 특정 기기에서의 주의사항

### US30 등 일부 기기의 동작 특성

US30을 비롯한 일부 기기에서는 Wi-Fi 채널 설정 시 다음과 같은 특성이 있습니다:

**문제점**:
- 한 주파수 대역(2.4GHz 또는 5GHz)의 채널만 설정하면, 설정하지 않은 다른 대역의 **모든 채널이 활성화**됩니다.

**예시**:
```java
// 2.4GHz 비중첩 채널 (1, 6, 11)만 설정
String[] channels = {"1", "6", "11"};
intent.putExtra("value", channels);
context.sendBroadcast(intent);

// ❌ 문제: US30 기기에서는 5GHz의 모든 채널(36-165)이 활성화됨
```

### 해결 방법: wifi-frequency-sdk 사용

이 문제를 해결하려면 **wifi-frequency-sdk**를 먼저 사용하여 원하는 주파수 대역만 활성화해야 합니다.

#### 해결 방법 1: 2.4GHz 채널만 사용하고 싶은 경우

```java
// 1단계: wifi-frequency-sdk로 2.4GHz 대역만 활성화
Intent freqIntent = new Intent("com.android.server.startupservice.config");
freqIntent.putExtra("setting", "wifi_freq_band");
freqIntent.putExtra("value", 2); // 2.4GHz만
context.sendBroadcast(freqIntent);

// 2단계: wifi-channel-sdk로 2.4GHz 대역의 특정 채널 제한
Intent channelIntent = new Intent("com.android.server.startupservice.config");
channelIntent.putExtra("setting", "wifi_channel");
String[] channels = {"1", "6", "11"};
channelIntent.putExtra("value", channels);
context.sendBroadcast(channelIntent);

// ✅ 결과: 2.4GHz의 1, 6, 11 채널만 활성화됨
```

#### 해결 방법 2: 5GHz 채널만 사용하고 싶은 경우

```java
// 1단계: wifi-frequency-sdk로 5GHz 대역만 활성화
Intent freqIntent = new Intent("com.android.server.startupservice.config");
freqIntent.putExtra("setting", "wifi_freq_band");
freqIntent.putExtra("value", 1); // 5GHz만
context.sendBroadcast(freqIntent);

// 2단계: wifi-channel-sdk로 5GHz 대역의 특정 채널 제한
Intent channelIntent = new Intent("com.android.server.startupservice.config");
channelIntent.putExtra("setting", "wifi_channel");
String[] channels = {"36", "40", "44", "48", "149", "153", "157", "161", "165"};
channelIntent.putExtra("value", channels);
context.sendBroadcast(channelIntent);

// ✅ 결과: 5GHz의 비DFS 채널만 활성화됨
```

#### 해결 방법 3: 두 대역 모두 세밀하게 제어

```java
// 1단계: wifi-frequency-sdk로 AUTO 모드 (두 대역 모두 사용)
Intent freqIntent = new Intent("com.android.server.startupservice.config");
freqIntent.putExtra("setting", "wifi_freq_band");
freqIntent.putExtra("value", 0); // AUTO
context.sendBroadcast(freqIntent);

// 2단계: wifi-channel-sdk로 두 대역의 특정 채널 제한
Intent channelIntent = new Intent("com.android.server.startupservice.config");
channelIntent.putExtra("setting", "wifi_channel");
String[] channels = {
    // 2.4GHz 비중첩 채널
    "1", "6", "11",
    // 5GHz 비DFS 채널
    "36", "40", "44", "48", "149", "153", "157", "161", "165"
};
channelIntent.putExtra("value", channels);
context.sendBroadcast(channelIntent);

// ✅ 결과: 두 대역 모두 지정한 채널만 활성화됨
```

**참고**: wifi-frequency-sdk에 대한 자세한 내용은 [Wi-Fi 주파수 대역 설정 SDK 문서](wifi-frequency-sdk-readme-ko.md)를 참조하세요.

---

### 세부 설정 가이드

#### Wi-Fi 채널 제한

Wi-Fi 스캔 및 연결을 특정 채널로 제한합니다. 2.4 GHz와 5 GHz 채널을 동시에 지정할 수 있습니다.

-   **`setting` 값**: `"wifi_channel"`
-   **`value` 타입**: `String[]` (문자열 배열)
-   **`value` 설명**: 활성화할 채널 번호의 목록

#### 2.4 GHz 채널 (채널 1 ~ 14)

| 채널 | 중심 주파수   | 사용 지역      | 비고                  |
|----|----------|------------|---------------------|
| 1  | 2412 MHz | 전 세계       | 비중첩 채널 (권장)         |
| 2  | 2417 MHz | 전 세계       |                     |
| 3  | 2422 MHz | 전 세계       |                     |
| 4  | 2427 MHz | 전 세계       |                     |
| 5  | 2432 MHz | 전 세계       |                     |
| 6  | 2437 MHz | 전 세계       | 비중첩 채널 (권장)         |
| 7  | 2442 MHz | 전 세계       |                     |
| 8  | 2447 MHz | 전 세계       |                     |
| 9  | 2452 MHz | 전 세계       |                     |
| 10 | 2457 MHz | 전 세계       |                     |
| 11 | 2462 MHz | 전 세계       | 비중첩 채널 (권장)         |
| 12 | 2467 MHz | 유럽, 아시아 일부 |                     |
| 13 | 2472 MHz | 유럽, 아시아 일부 |                     |
| 14 | 2484 MHz | 일본만        | 특수 채널 (802.11b만 지원) |

**2.4 GHz 채널 선택 가이드**:
- **비중첩 채널 (1, 6, 11)**: 간섭을 최소화하기 위해 권장되는 채널 조합
- **채널 12, 13**: 일부 국가에서만 사용 가능 (국가 코드 설정 필요)
- **채널 14**: 일본에서만 사용 가능하며, 802.11b 전용

#### 5 GHz 채널

5 GHz 대역은 더 많은 채널을 제공하며 간섭이 적습니다.

**UNII-1 (실내용, 낮은 출력)**

| 채널 | 중심 주파수   | 대역폭    |
|----|----------|--------|
| 36 | 5180 MHz | 20 MHz |
| 40 | 5200 MHz | 20 MHz |
| 44 | 5220 MHz | 20 MHz |
| 48 | 5240 MHz | 20 MHz |

**UNII-2 (DFS 필요)**

| 채널  | 중심 주파수   | 대역폭    | 비고     |
|-----|----------|--------|--------|
| 52  | 5260 MHz | 20 MHz | DFS 채널 |
| 56  | 5280 MHz | 20 MHz | DFS 채널 |
| 60  | 5300 MHz | 20 MHz | DFS 채널 |
| 64  | 5320 MHz | 20 MHz | DFS 채널 |
| 100 | 5500 MHz | 20 MHz | DFS 채널 |
| 104 | 5520 MHz | 20 MHz | DFS 채널 |
| 108 | 5540 MHz | 20 MHz | DFS 채널 |
| 112 | 5560 MHz | 20 MHz | DFS 채널 |
| 116 | 5580 MHz | 20 MHz | DFS 채널 |
| 120 | 5600 MHz | 20 MHz | DFS 채널 |
| 124 | 5620 MHz | 20 MHz | DFS 채널 |
| 128 | 5640 MHz | 20 MHz | DFS 채널 |
| 132 | 5660 MHz | 20 MHz | DFS 채널 |
| 136 | 5680 MHz | 20 MHz | DFS 채널 |
| 140 | 5700 MHz | 20 MHz | DFS 채널 |
| 144 | 5720 MHz | 20 MHz | DFS 채널 |

**UNII-3 (실외용, 높은 출력)**

| 채널  | 중심 주파수   | 대역폭    | 비고           |
|-----|----------|--------|--------------|
| 149 | 5745 MHz | 20 MHz | 비DFS 채널 (권장) |
| 153 | 5765 MHz | 20 MHz | 비DFS 채널 (권장) |
| 157 | 5785 MHz | 20 MHz | 비DFS 채널 (권장) |
| 161 | 5805 MHz | 20 MHz | 비DFS 채널 (권장) |
| 165 | 5825 MHz | 20 MHz | 비DFS 채널 (권장) |

**5 GHz 채널 선택 가이드**:
- **권장 비DFS 채널**: 36, 40, 44, 48, 149, 153, 157, 161, 165
  - DFS (Dynamic Frequency Selection)가 필요없어 연결이 빠르고 안정적
- **DFS 채널**: 52-144 범위의 채널
  - 레이더 감지 시 채널 변경이 필요하여 일시적인 연결 끊김 가능
  - 사용 전 DFS 스캔 시간 (1분 이상) 필요

---

### 일반적인 사용 시나리오

#### 시나리오 1: 비중첩 채널만 사용 (2.4 GHz)

간섭을 최소화하기 위해 2.4 GHz의 비중첩 채널 (1, 6, 11)만 사용:

```java
Intent intent = new Intent("com.android.server.startupservice.config");
intent.putExtra("setting", "wifi_channel");
String[] channels = {"1", "6", "11"};
intent.putExtra("value", channels);
context.sendBroadcast(intent);
```

> **⚠️ US30 등 일부 기기**: 위 설정만으로는 5GHz 모든 채널이 활성화됩니다. 2.4GHz만 사용하려면 먼저 wifi-frequency-sdk로 `value=2` 설정이 필요합니다.

#### 시나리오 2: 5 GHz 비DFS 채널만 사용

빠른 연결과 안정성을 위해 5 GHz 비DFS 채널만 사용:

```java
Intent intent = new Intent("com.android.server.startupservice.config");
intent.putExtra("setting", "wifi_channel");
String[] channels = {"36", "40", "44", "48", "149", "153", "157", "161", "165"};
intent.putExtra("value", channels);
context.sendBroadcast(intent);
```

> **⚠️ US30 등 일부 기기**: 위 설정만으로는 2.4GHz 모든 채널이 활성화됩니다. 5GHz만 사용하려면 먼저 wifi-frequency-sdk로 `value=1` 설정이 필요합니다.

#### 시나리오 3: 듀얼 밴드 (2.4 GHz + 5 GHz)

2.4 GHz와 5 GHz를 모두 사용하되, 권장 채널만 선택:

```java
Intent intent = new Intent("com.android.server.startupservice.config");
intent.putExtra("setting", "wifi_channel");
String[] channels = {
    // 2.4 GHz 비중첩 채널
    "1", "6", "11",
    // 5 GHz 비DFS 채널
    "36", "40", "44", "48", "149", "153", "157", "161", "165"
};
intent.putExtra("value", channels);
context.sendBroadcast(intent);
```

> **참고**: 두 대역 모두 포함하므로 US30 등에서도 정상 동작합니다.

#### 시나리오 4: 특정 채널만 강제 사용

네트워크 정책상 특정 채널만 사용해야 하는 경우:

```java
Intent intent = new Intent("com.android.server.startupservice.config");
intent.putExtra("setting", "wifi_channel");
String[] channels = {"6", "149"}; // 2.4GHz는 채널 6만, 5GHz는 채널 149만
intent.putExtra("value", channels);
context.sendBroadcast(intent);
```

> **참고**: 두 대역 모두 포함하므로 US30 등에서도 정상 동작합니다.

---

### 전체 예제

#### 클라이언트 앱 구현

```java
public class WifiChannelController {
    private Context context;

    public WifiChannelController(Context context) {
        this.context = context;
    }

    /**
     * Wi-Fi 채널 설정
     *
     * @param channels 활성화할 채널 번호 배열 (예: {"1", "6", "11", "36", "149"})
     */
    public void setWifiChannels(String[] channels) {
        // 채널 유효성 검증
        for (String channel : channels) {
            if (!isValidChannel(channel)) {
                Log.e("WifiChannelController", "Invalid channel: " + channel);
                return;
            }
        }

        // Wi-Fi 채널 설정 브로드캐스트 전송
        Intent intent = new Intent("com.android.server.startupservice.config");
        intent.putExtra("setting", "wifi_channel");
        intent.putExtra("value", channels);
        context.sendBroadcast(intent);

        Log.i("WifiChannelController", "Wi-Fi channels set: " + Arrays.toString(channels));
    }

    /**
     * 2.4 GHz 권장 채널 설정 (비중첩 채널: 1, 6, 11)
     *
     * ⚠️ US30 등 일부 기기: 이 메서드만 호출하면 5GHz 모든 채널이 활성화됩니다.
     * 2.4GHz만 사용하려면 setRecommended24GHzOnly() 메서드를 사용하세요.
     */
    public void setRecommended24GHz() {
        String[] channels = {"1", "6", "11"};
        setWifiChannels(channels);
    }

    /**
     * 2.4 GHz만 사용 (US30 등 일부 기기 대응)
     */
    public void setRecommended24GHzOnly() {
        // 1단계: 주파수 대역을 2.4GHz로 제한
        setFrequencyBand(2);

        // 2단계: 2.4GHz 비중첩 채널 설정
        String[] channels = {"1", "6", "11"};
        setWifiChannels(channels);
    }

    /**
     * 5 GHz 권장 채널 설정 (비DFS 채널)
     *
     * ⚠️ US30 등 일부 기기: 이 메서드만 호출하면 2.4GHz 모든 채널이 활성화됩니다.
     * 5GHz만 사용하려면 setRecommended5GHzOnly() 메서드를 사용하세요.
     */
    public void setRecommended5GHz() {
        String[] channels = {"36", "40", "44", "48", "149", "153", "157", "161", "165"};
        setWifiChannels(channels);
    }

    /**
     * 5 GHz만 사용 (US30 등 일부 기기 대응)
     */
    public void setRecommended5GHzOnly() {
        // 1단계: 주파수 대역을 5GHz로 제한
        setFrequencyBand(1);

        // 2단계: 5GHz 비DFS 채널 설정
        String[] channels = {"36", "40", "44", "48", "149", "153", "157", "161", "165"};
        setWifiChannels(channels);
    }

    /**
     * 듀얼 밴드 권장 채널 설정 (2.4GHz + 5GHz 비DFS)
     */
    public void setDualBandRecommended() {
        String[] channels = {
            // 2.4 GHz 비중첩 채널
            "1", "6", "11",
            // 5 GHz 비DFS 채널
            "36", "40", "44", "48", "149", "153", "157", "161", "165"
        };
        setWifiChannels(channels);
    }

    /**
     * 모든 2.4 GHz 채널 설정 (1-13)
     */
    public void setAll24GHz() {
        String[] channels = {"1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13"};
        setWifiChannels(channels);
    }

    /**
     * UNII-1 채널만 설정 (36, 40, 44, 48)
     */
    public void setUNII1Only() {
        String[] channels = {"36", "40", "44", "48"};
        setWifiChannels(channels);
    }

    /**
     * UNII-3 채널만 설정 (149, 153, 157, 161, 165)
     */
    public void setUNII3Only() {
        String[] channels = {"149", "153", "157", "161", "165"};
        setWifiChannels(channels);
    }

    /**
     * 특정 채널만 설정
     *
     * @param channels 채널 번호 목록 (가변 인자)
     */
    public void setCustomChannels(String... channels) {
        setWifiChannels(channels);
    }

    /**
     * 모든 채널 제한 해제 (빈 배열 전송)
     */
    public void clearChannelRestrictions() {
        String[] emptyChannels = {};
        setWifiChannels(emptyChannels);
    }

    /**
     * Wi-Fi 주파수 대역 설정 (wifi-frequency-sdk)
     *
     * @param band 0: AUTO, 1: 5GHz만, 2: 2.4GHz만
     */
    private void setFrequencyBand(int band) {
        Intent intent = new Intent("com.android.server.startupservice.config");
        intent.putExtra("setting", "wifi_freq_band");
        intent.putExtra("value", band);
        context.sendBroadcast(intent);

        Log.i("WifiChannelController", "Frequency band set to: " + band);
    }

    /**
     * 채널 유효성 검증
     *
     * @param channel 채널 번호
     * @return 유효하면 true, 아니면 false
     */
    private boolean isValidChannel(String channel) {
        if (channel == null || channel.isEmpty()) {
            return false;
        }

        try {
            int ch = Integer.parseInt(channel);

            // 2.4 GHz 채널 (1-14)
            if (ch >= 1 && ch <= 14) {
                return true;
            }

            // 5 GHz 채널
            int[] valid5GHz = {36, 40, 44, 48, 52, 56, 60, 64, 100, 104, 108, 112,
                              116, 120, 124, 128, 132, 136, 140, 144, 149, 153, 157, 161, 165};
            for (int validCh : valid5GHz) {
                if (ch == validCh) {
                    return true;
                }
            }

            return false;
        } catch (NumberFormatException e) {
            return false;
        }
    }

    /**
     * 채널이 2.4 GHz 대역인지 확인
     */
    public boolean is24GHz(String channel) {
        try {
            int ch = Integer.parseInt(channel);
            return ch >= 1 && ch <= 14;
        } catch (NumberFormatException e) {
            return false;
        }
    }

    /**
     * 채널이 5 GHz 대역인지 확인
     */
    public boolean is5GHz(String channel) {
        return isValidChannel(channel) && !is24GHz(channel);
    }

    /**
     * 채널이 DFS 채널인지 확인
     */
    public boolean isDFSChannel(String channel) {
        try {
            int ch = Integer.parseInt(channel);
            // DFS 채널: 52-144
            return ch >= 52 && ch <= 144 && is5GHz(channel);
        } catch (NumberFormatException e) {
            return false;
        }
    }
}
```

#### Activity에서 사용

```java
public class MainActivity extends AppCompatActivity {
    private WifiChannelController wifiChannelController;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        wifiChannelController = new WifiChannelController(this);

        // 예제 1: 2.4 GHz 비중첩 채널만 사용 (US30 대응)
        findViewById(R.id.btnSet24GHzRecommended).setOnClickListener(v -> {
            wifiChannelController.setRecommended24GHzOnly();
            Toast.makeText(this, "2.4GHz 권장 채널 설정 (1, 6, 11)", Toast.LENGTH_SHORT).show();
        });

        // 예제 2: 5 GHz 비DFS 채널만 사용 (US30 대응)
        findViewById(R.id.btnSet5GHzRecommended).setOnClickListener(v -> {
            wifiChannelController.setRecommended5GHzOnly();
            Toast.makeText(this, "5GHz 권장 채널 설정 (비DFS)", Toast.LENGTH_SHORT).show();
        });

        // 예제 3: 듀얼 밴드 권장 설정
        findViewById(R.id.btnSetDualBand).setOnClickListener(v -> {
            wifiChannelController.setDualBandRecommended();
            Toast.makeText(this, "듀얼 밴드 권장 채널 설정", Toast.LENGTH_SHORT).show();
        });

        // 예제 4: UNII-1 채널만 사용
        findViewById(R.id.btnSetUNII1).setOnClickListener(v -> {
            wifiChannelController.setUNII1Only();
            Toast.makeText(this, "UNII-1 채널 설정 (36, 40, 44, 48)", Toast.LENGTH_SHORT).show();
        });

        // 예제 5: UNII-3 채널만 사용
        findViewById(R.id.btnSetUNII3).setOnClickListener(v -> {
            wifiChannelController.setUNII3Only();
            Toast.makeText(this, "UNII-3 채널 설정 (149-165)", Toast.LENGTH_SHORT).show();
        });

        // 예제 6: 커스텀 채널 설정
        findViewById(R.id.btnSetCustom).setOnClickListener(v -> {
            // 네트워크 정책상 채널 6과 149만 사용
            wifiChannelController.setCustomChannels("6", "149");
            Toast.makeText(this, "커스텀 채널 설정 (6, 149)", Toast.LENGTH_SHORT).show();
        });

        // 예제 7: 채널 제한 해제 (모든 채널 활성화)
        findViewById(R.id.btnClearRestrictions).setOnClickListener(v -> {
            wifiChannelController.clearChannelRestrictions();
            Toast.makeText(this, "채널 제한 해제", Toast.LENGTH_SHORT).show();
        });

        // 예제 8: 사용자 입력으로 채널 설정
        findViewById(R.id.btnSetFromInput).setOnClickListener(v -> {
            showChannelInputDialog();
        });
    }

    /**
     * 사용자로부터 채널 입력 받기
     */
    private void showChannelInputDialog() {
        AlertDialog.Builder builder = new AlertDialog.Builder(this);
        builder.setTitle("채널 설정");
        builder.setMessage("쉼표로 구분하여 채널을 입력하세요 (예: 1,6,11,36,149)");

        final EditText input = new EditText(this);
        input.setHint("1,6,11,36,149");
        builder.setView(input);

        builder.setPositiveButton("설정", (dialog, which) -> {
            String channelsText = input.getText().toString().trim();
            if (!channelsText.isEmpty()) {
                String[] channels = channelsText.split(",");
                // 공백 제거
                for (int i = 0; i < channels.length; i++) {
                    channels[i] = channels[i].trim();
                }
                wifiChannelController.setWifiChannels(channels);
                Toast.makeText(this, "채널 설정 완료: " + channelsText, Toast.LENGTH_SHORT).show();
            }
        });

        builder.setNegativeButton("취소", (dialog, which) -> dialog.cancel());
        builder.show();
    }
}
```

#### Kotlin에서 사용

```kotlin
class WifiChannelController(private val context: Context) {

    /**
     * Wi-Fi 채널 설정
     */
    fun setWifiChannels(channels: Array<String>) {
        // 채널 유효성 검증
        if (!channels.all { isValidChannel(it) }) {
            Log.e("WifiChannelController", "Invalid channels found")
            return
        }

        // Wi-Fi 채널 설정 브로드캐스트 전송
        Intent("com.android.server.startupservice.config").apply {
            putExtra("setting", "wifi_channel")
            putExtra("value", channels)
            context.sendBroadcast(this)
        }

        Log.i("WifiChannelController", "Wi-Fi channels set: ${channels.contentToString()}")
    }

    /**
     * 2.4 GHz 권장 채널 설정 (비중첩 채널: 1, 6, 11)
     */
    fun setRecommended24GHz() {
        setWifiChannels(arrayOf("1", "6", "11"))
    }

    /**
     * 2.4 GHz만 사용 (US30 등 일부 기기 대응)
     */
    fun setRecommended24GHzOnly() {
        setFrequencyBand(2)
        setWifiChannels(arrayOf("1", "6", "11"))
    }

    /**
     * 5 GHz 권장 채널 설정 (비DFS 채널)
     */
    fun setRecommended5GHz() {
        setWifiChannels(arrayOf("36", "40", "44", "48", "149", "153", "157", "161", "165"))
    }

    /**
     * 5 GHz만 사용 (US30 등 일부 기기 대응)
     */
    fun setRecommended5GHzOnly() {
        setFrequencyBand(1)
        setWifiChannels(arrayOf("36", "40", "44", "48", "149", "153", "157", "161", "165"))
    }

    /**
     * 듀얼 밴드 권장 채널 설정
     */
    fun setDualBandRecommended() {
        setWifiChannels(arrayOf(
            "1", "6", "11",  // 2.4 GHz
            "36", "40", "44", "48", "149", "153", "157", "161", "165"  // 5 GHz
        ))
    }

    /**
     * 커스텀 채널 설정
     */
    fun setCustomChannels(vararg channels: String) {
        setWifiChannels(channels.toList().toTypedArray())
    }

    /**
     * 채널 제한 해제
     */
    fun clearChannelRestrictions() {
        setWifiChannels(emptyArray())
    }

    /**
     * Wi-Fi 주파수 대역 설정
     */
    private fun setFrequencyBand(band: Int) {
        Intent("com.android.server.startupservice.config").apply {
            putExtra("setting", "wifi_freq_band")
            putExtra("value", band)
            context.sendBroadcast(this)
        }
        Log.i("WifiChannelController", "Frequency band set to: $band")
    }

    /**
     * 채널 유효성 검증
     */
    private fun isValidChannel(channel: String): Boolean {
        return try {
            val ch = channel.toInt()
            when {
                ch in 1..14 -> true  // 2.4 GHz
                ch in listOf(36, 40, 44, 48, 52, 56, 60, 64, 100, 104, 108, 112,
                    116, 120, 124, 128, 132, 136, 140, 144, 149, 153, 157, 161, 165) -> true
                else -> false
            }
        } catch (e: NumberFormatException) {
            false
        }
    }

    /**
     * 2.4 GHz 채널 여부 확인
     */
    fun is24GHz(channel: String): Boolean {
        return try {
            channel.toInt() in 1..14
        } catch (e: NumberFormatException) {
            false
        }
    }

    /**
     * 5 GHz 채널 여부 확인
     */
    fun is5GHz(channel: String): Boolean {
        return isValidChannel(channel) && !is24GHz(channel)
    }

    /**
     * DFS 채널 여부 확인
     */
    fun isDFSChannel(channel: String): Boolean {
        return try {
            val ch = channel.toInt()
            ch in 52..144 && is5GHz(channel)
        } catch (e: NumberFormatException) {
            false
        }
    }
}

// Kotlin Activity 사용 예제
class MainActivity : AppCompatActivity() {
    private lateinit var wifiChannelController: WifiChannelController

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        wifiChannelController = WifiChannelController(this)

        // 2.4 GHz 권장 채널 (US30 대응)
        findViewById<Button>(R.id.btnSet24GHzRecommended).setOnClickListener {
            wifiChannelController.setRecommended24GHzOnly()
            Toast.makeText(this, "2.4GHz 권장 채널 설정", Toast.LENGTH_SHORT).show()
        }

        // 5 GHz 권장 채널 (US30 대응)
        findViewById<Button>(R.id.btnSet5GHzRecommended).setOnClickListener {
            wifiChannelController.setRecommended5GHzOnly()
            Toast.makeText(this, "5GHz 권장 채널 설정", Toast.LENGTH_SHORT).show()
        }

        // 듀얼 밴드
        findViewById<Button>(R.id.btnSetDualBand).setOnClickListener {
            wifiChannelController.setDualBandRecommended()
            Toast.makeText(this, "듀얼 밴드 권장 채널 설정", Toast.LENGTH_SHORT).show()
        }

        // 커스텀 채널
        findViewById<Button>(R.id.btnSetCustom).setOnClickListener {
            wifiChannelController.setCustomChannels("6", "149")
            Toast.makeText(this, "커스텀 채널 설정", Toast.LENGTH_SHORT).show()
        }
    }
}
```

---

### ADB로 테스트하기

#### 2.4 GHz 채널만 설정

```bash
# 비중첩 채널 (1, 6, 11)
adb shell am broadcast -a com.android.server.startupservice.config --es setting "wifi_channel" --esa value "1","6","11"
```

```bash
# 채널 1만
adb shell am broadcast -a com.android.server.startupservice.config --es setting "wifi_channel" --esa value "1"
```

```bash
# 모든 2.4GHz 채널 (1-13, 일부 국가에서만 가능)
adb shell am broadcast -a com.android.server.startupservice.config --es setting "wifi_channel" --esa value "1","2","3","4","5","6","7","8","9","10","11","12","13"
```

#### 5 GHz 채널만 설정

```bash
# 5GHz 비DFS 채널 (36, 40, 44, 48, 149, 153, 157, 161, 165)
adb shell am broadcast -a com.android.server.startupservice.config --es setting "wifi_channel" --esa value "36","40","44","48","149","153","157","161","165"
```

```bash
# UNII-1 채널만 (36, 40, 44, 48)
adb shell am broadcast -a com.android.server.startupservice.config --es setting "wifi_channel" --esa value "36","40","44","48"
```

```bash
# UNII-3 채널만 (149, 153, 157, 161, 165)
adb shell am broadcast -a com.android.server.startupservice.config --es setting "wifi_channel" --esa value "149","153","157","161","165"
```

#### 듀얼 밴드 설정

```bash
# 2.4GHz + 5GHz 권장 채널
adb shell am broadcast -a com.android.server.startupservice.config --es setting "wifi_channel" --esa value "1","6","11","36","40","44","48","149","153","157","161","165"
```
```bash
# 2.4GHz (1, 6, 11) + 5GHz (36, 149)
adb shell am broadcast -a com.android.server.startupservice.config --es setting "wifi_channel" --esa value "1","6","11","36","149"
```

#### US30 등 일부 기기에서 2.4GHz만 사용

```bash
# 1단계: 주파수 대역을 2.4GHz로 제한
adb shell am broadcast -a com.android.server.startupservice.config --es setting "wifi_freq_band" --ei value 2

# 2단계: 2.4GHz 채널 설정
adb shell am broadcast -a com.android.server.startupservice.config --es setting "wifi_channel" --esa value "1","6","11"
```

---

### 특정 기기에서의 주의사항

**US30 등 특정 기기**: 한 주파수 대역의 채널만 설정 시 다른 대역의 모든 채널이 활성화됩니다. 이를 방지하려면:

- **방법 1**: 두 대역의 채널을 모두 명시적으로 지정
- **방법 2**: wifi-frequency-sdk를 먼저 사용하여 원하는 대역만 활성화
