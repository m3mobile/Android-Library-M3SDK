# Wi-Fi 로밍 설정 SDK

> **Note** <br>
> StartUp 버전 6.0.6 BETA 버전부터 지원합니다. <br>
> SL10, Sl10K 기기는 지원하지 않습니다.

## 개요

이 SDK는 외부 Android 애플리케이션이 StartUp 앱과의 브로드캐스트 통신을 통해 기기의 Wi-Fi 로밍 동작을 제어할 수 있도록 합니다.

Wi-Fi 로밍은 기기가 현재 연결된 액세스 포인트(AP)에서 더 나은 신호를 제공하는 다른 AP로 자동 전환하는 기능입니다.
이 SDK를 통해 다음 두 가지 핵심 설정을 제어할 수 있습니다:

- **Roaming Trigger (최소 Wi-Fi 신호 세기)**: 로밍을 시작하는 RSSI 임계값
- **Roaming Delta**: 새로운 AP로 전환하기 위해 필요한 최소 신호 강도 차이

이 두 설정은 함께 작동하여 기기의 로밍 정책을 결정합니다.

### 빠른 시작

#### 기본 사용법

```java
// Roaming Trigger를 index 1 (-75dBm)로 설정
Intent intentTrigger = new Intent("com.android.server.startupservice.config");
intentTrigger.putExtra("setting", "wifi_roam_trigger");
intentTrigger.putExtra("value", "1");
context.sendBroadcast(intentTrigger);

// Roaming Delta를 index 4 (10dB)로 설정
Intent intentDelta = new Intent("com.android.server.startupservice.config");
intentDelta.putExtra("setting", "wifi_roam_delta");
intentDelta.putExtra("value", "4");
context.sendBroadcast(intentDelta);
```

### API 참조

#### 브로드캐스트 액션

**Action**: `com.android.server.startupservice.config`

#### 파라미터

| 파라미터      | 타입     | 필수 | 설명                                                          |
|-----------|--------|----|-------------------------------------------------------------|
| `setting` | String | 예  | 변경할 로밍 설정의 종류: `"wifi_roam_trigger"` 또는 `"wifi_roam_delta"` |
| `value`   | int    | 예  | 설정 값 (정수 인덱스)                                              |

---

### 세부 설정 가이드

#### 1. Roaming Trigger (최소 Wi-Fi 신호 세기)

기기가 특정 RSSI (수신 신호 강도) 값 이하의 AP에 연결을 시도하지 않도록 설정합니다. 이 값은 로밍을 시작하는 임계값으로 사용됩니다.

-   **`setting` 값**: `"wifi_roam_trigger"`
-   **`value` 타입**: `int` (인덱스)
-   **`value` 옵션**:

| 인덱스 | RSSI 임계값 | 설명                            | 사용 시나리오                       |
|-----|----------|-------------------------------|-------------------------------|
| `0` | -80 dBm  | 신호가 매우 약해질 때까지 연결 유지          | 안정적인 연결 유지가 중요한 경우            |
| `1` | -75 dBm  | 신호가 약해지면 적극적으로 다른 AP를 찾습니다.   | AP가 많은 환경, 빠른 로밍이 필요한 경우      |
| `2` | -70 dBm  | 중간 수준의 로밍 동작 (기본 권장값)         | 일반적인 사용 환경                    |
| `3` | -65 dBm  | 신호가 더 약해질 때 로밍 시작             | 신호 품질 우선 환경                   |
| `4` | -60 dBm  | 매우 강한 신호만 유지                  | 최상의 신호 품질이 필요한 경우             |

**RSSI 값 이해하기**:
- RSSI는 신호 강도를 나타내며, dBm 단위로 측정됩니다
- 0에 가까울수록 강한 신호, -100에 가까울수록 약한 신호
- -60 dBm: 매우 강한 신호
- -70 dBm: 좋은 신호 강도
- -80 dBm: 적절한 신호 강도

#### 2. Roaming Delta

현재 연결된 AP와 새로 찾은 AP 간의 신호 강도 차이가 이 값보다 클 때만 로밍을 트리거합니다.

-   **`setting` 값**: `"wifi_roam_delta"`
-   **`value` 타입**: `int` (인덱스)
-   **`value` 옵션**:

| 인덱스 | 신호 강도 차이 | 설명                      | 사용 시나리오                      |
|-----|----------|-------------------------|------------------------------|
| `0` | 30 dB    | 매우 큰 차이가 있을 때만 로밍      | 극도로 안정적인 연결이 필요한 경우          |
| `1` | 25 dB    | 큰 차이가 있을 때만 로밍         | 로밍 빈도 최소화                    |
| `2` | 20 dB    | 상당한 차이가 있을 때 로밍        | 안정성과 품질의 균형                  |
| `3` | 15 dB    | 중간 수준의 차이에서 로밍         | 일반적인 환경                      |
| `4` | 10 dB    | 적당한 차이에서 로밍 (기본 권장값)   | 균형잡힌 로밍 동작                   |
| `5` | 5 dB     | 더 나은 신호가 약간만 있어도 로밍    | 항상 최상의 연결 품질 유지가 필요한 경우      |
| `6` | 0 dB     | 조금이라도 나은 신호가 있으면 즉시 로밍 | 초고빈도 로밍 (일반적으로 권장하지 않음)      |

**로밍 Delta 이해하기**:
- 예: Delta가 10dB(인덱스 4)이고 현재 AP 신호가 -70dBm일 때
  - 새 AP 신호가 -60dBm 이상이어야 로밍 발생 (10dB 이상 차이)
  - 새 AP 신호가 -65dBm이면 로밍 발생하지 않음 (5dB 차이)

---

### 로밍 설정 조합 가이드

Roaming Trigger와 Roaming Delta는 함께 작동하므로, 사용 시나리오에 맞는 조합을 선택하는 것이 중요합니다.

#### 추천 설정 조합

| 시나리오                 | Trigger 인덱스 | Delta 인덱스 | Trigger 값 | Delta 값 | 설명                                   |
|----------------------|------------|----------|----------|--------|--------------------------------------|
| **빠른 로밍 (Aggressive)**     | 1          | 5        | -75 dBm  | 5 dB   | 신호가 조금만 약해져도 빠르게 더 나은 AP로 전환         |
| **일반적인 사용 (Moderate)**     | 2          | 4        | -70 dBm  | 10 dB  | 균형잡힌 로밍 동작 (기본 권장값)                           |
| **안정적인 연결 (Conservative)**       | 0          | 3        | -80 dBm  | 15 dB  | 불필요한 로밍을 최소화하고 현재 연결 유지              |
| **빠른 탐색, 신중한 선택**   | 1          | 4        | -75 dBm  | 10 dB  | 신호가 약해지면 빠르게 탐색하지만, 충분히 나은 AP만 선택    |
| **안정 우선, 품질 선택** | 2          | 5        | -70 dBm  | 5 dB | 적당한 임계값에서 로밍 시작, 조금이라도 나은 AP로 빠르게 전환 |

#### 환경별 추천 설정

**AP가 많은 환경 (오피스, 공공장소)**
```java
// Roaming Trigger: index 1 (-75dBm, 빠른 로밍 시작)
Intent intentTrigger = new Intent("com.android.server.startupservice.config");
intentTrigger.putExtra("setting", "wifi_roam_trigger");
intentTrigger.putExtra("value", "1");
context.sendBroadcast(intentTrigger);

// Roaming Delta: index 4 (10dB, 적절한 AP 선택)
Intent intentDelta = new Intent("com.android.server.startupservice.config");
intentDelta.putExtra("setting", "wifi_roam_delta");
intentDelta.putExtra("value", "4");
context.sendBroadcast(intentDelta);
```

**AP가 적은 환경 (가정, 소규모 사무실)**
```java
// Roaming Trigger: index 0 (-80dBm, 연결 유지)
Intent intentTrigger = new Intent("com.android.server.startupservice.config");
intentTrigger.putExtra("setting", "wifi_roam_trigger");
intentTrigger.putExtra("value", "0");
context.sendBroadcast(intentTrigger);

// Roaming Delta: index 3 (15dB, 안정적인 전환)
Intent intentDelta = new Intent("com.android.server.startupservice.config");
intentDelta.putExtra("setting", "wifi_roam_delta");
intentDelta.putExtra("value", "3");
context.sendBroadcast(intentDelta);
```

---

### 전체 예제

#### 클라이언트 앱 구현

```java
public class WifiRoamingController {
    private Context context;

    public WifiRoamingController(Context context) {
        this.context = context;
    }

    /**
     * Roaming Trigger 설정
     *
     * @param triggerIndex 인덱스 (0: -80dBm, 1: -75dBm, 2: -70dBm, 3: -65dBm, 4: -60dBm)
     */
    public void setRoamTrigger(int triggerIndex) {
        if (!isValidTriggerIndex(triggerIndex)) {
            Log.e("WifiRoamingController", "Invalid roam trigger index: " + triggerIndex);
            return;
        }

        Intent intent = new Intent("com.android.server.startupservice.config");
        intent.putExtra("setting", "wifi_roam_trigger");
        intent.putExtra("value", String.valueOf(triggerIndex));
        context.sendBroadcast(intent);

        Log.i("WifiRoamingController", "Roam trigger set to index: " + triggerIndex +
              " (" + getTriggerRSSI(triggerIndex) + " dBm)");
    }

    /**
     * Roaming Delta 설정
     *
     * @param deltaIndex 인덱스 (0: 30dB, 1: 25dB, 2: 20dB, 3: 15dB, 4: 10dB, 5: 5dB, 6: 0dB)
     */
    public void setRoamDelta(int deltaIndex) {
        if (!isValidDeltaIndex(deltaIndex)) {
            Log.e("WifiRoamingController", "Invalid roam delta index: " + deltaIndex);
            return;
        }

        Intent intent = new Intent("com.android.server.startupservice.config");
        intent.putExtra("setting", "wifi_roam_delta");
        intent.putExtra("value", String.valueOf(deltaIndex));
        context.sendBroadcast(intent);

        Log.i("WifiRoamingController", "Roam delta set to index: " + deltaIndex +
              " (" + getDeltaValue(deltaIndex) + " dB)");
    }

    /**
     * Roaming Trigger와 Delta를 동시에 설정
     *
     * @param triggerIndex Roaming Trigger 인덱스
     * @param deltaIndex Roaming Delta 인덱스
     */
    public void setRoamingPolicy(int triggerIndex, int deltaIndex) {
        setRoamTrigger(triggerIndex);
        setRoamDelta(deltaIndex);
    }

    /**
     * Aggressive 로밍 설정 (빠른 로밍)
     * Trigger: index 1 (-75dBm), Delta: index 5 (5dB)
     */
    public void setAggressiveRoaming() {
        setRoamingPolicy(1, 5);
    }

    /**
     * Moderate 로밍 설정 (표준 로밍) - 기본 권장값
     * Trigger: index 2 (-70dBm), Delta: index 4 (10dB)
     */
    public void setModerateRoaming() {
        setRoamingPolicy(2, 4);
    }

    /**
     * Conservative 로밍 설정 (안정적인 연결 유지)
     * Trigger: index 0 (-80dBm), Delta: index 3 (15dB)
     */
    public void setConservativeRoaming() {
        setRoamingPolicy(0, 3);
    }

    /**
     * AP가 많은 환경 (오피스, 공공장소) 최적화 설정
     * Trigger: index 1 (-75dBm), Delta: index 4 (10dB)
     */
    public void setForHighDensityArea() {
        setRoamingPolicy(1, 4);
    }

    /**
     * AP가 적은 환경 (가정, 소규모 사무실) 최적화 설정
     * Trigger: index 0 (-80dBm), Delta: index 3 (15dB)
     */
    public void setForLowDensityArea() {
        setRoamingPolicy(0, 3);
    }

    /**
     * 최상의 연결 품질 유지 설정
     * Trigger: index 1 (-75dBm), Delta: index 5 (5dB)
     * 신호가 조금만 약해져도 빠르게 더 나은 AP로 전환
     */
    public void setForBestQuality() {
        setRoamingPolicy(1, 5);
    }

    /**
     * 연결 안정성 우선 설정
     * Trigger: index 0 (-80dBm), Delta: index 3 (15dB)
     * 불필요한 로밍을 최소화하고 현재 연결 유지
     */
    public void setForStability() {
        setRoamingPolicy(0, 3);
    }

    /**
     * Trigger 인덱스 유효성 검증
     *
     * @param index Trigger 인덱스
     * @return 유효하면 true, 아니면 false
     */
    private boolean isValidTriggerIndex(int index) {
        return index >= 0 && index <= 4;
    }

    /**
     * Delta 인덱스 유효성 검증
     *
     * @param index Delta 인덱스
     * @return 유효하면 true, 아니면 false
     */
    private boolean isValidDeltaIndex(int index) {
        return index >= 0 && index <= 6;
    }

    /**
     * Roaming Trigger RSSI 값 가져오기 (참고용)
     *
     * @param index Trigger 인덱스
     * @return RSSI 값 (dBm)
     */
    public int getTriggerRSSI(int index) {
        switch (index) {
            case 0: return -80;
            case 1: return -75;
            case 2: return -70;
            case 3: return -65;
            case 4: return -60;
            default: return -70;  // 기본값
        }
    }

    /**
     * Roaming Delta 값 가져오기 (참고용)
     *
     * @param index Delta 인덱스
     * @return Delta 값 (dB)
     */
    public int getDeltaValue(int index) {
        switch (index) {
            case 0: return 30;
            case 1: return 25;
            case 2: return 20;
            case 3: return 15;
            case 4: return 10;
            case 5: return 5;
            case 6: return 0;
            default: return 10;  // 기본값
        }
    }
}
```

#### Activity에서 사용

```java
public class MainActivity extends AppCompatActivity {
    private WifiRoamingController roamingController;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        roamingController = new WifiRoamingController(this);

        // 예제 1: Aggressive 로밍 (최상의 연결 품질)
        findViewById(R.id.btnSetAggressiveRoaming).setOnClickListener(v -> {
            roamingController.setAggressiveRoaming();
            Toast.makeText(this, "Aggressive 로밍 설정\n(빠른 AP 전환)", Toast.LENGTH_SHORT).show();
        });

        // 예제 2: Moderate 로밍 (표준)
        findViewById(R.id.btnSetModerateRoaming).setOnClickListener(v -> {
            roamingController.setModerateRoaming();
            Toast.makeText(this, "Moderate 로밍 설정\n(표준 설정)", Toast.LENGTH_SHORT).show();
        });

        // 예제 3: Conservative 로밍 (안정성 우선)
        findViewById(R.id.btnSetConservativeRoaming).setOnClickListener(v -> {
            roamingController.setConservativeRoaming();
            Toast.makeText(this, "Conservative 로밍 설정\n(연결 안정성 우선)", Toast.LENGTH_SHORT).show();
        });

        // 예제 4: AP가 많은 환경 최적화
        findViewById(R.id.btnSetHighDensity).setOnClickListener(v -> {
            roamingController.setForHighDensityArea();
            Toast.makeText(this, "AP 밀집 환경 설정\n(오피스, 공공장소)", Toast.LENGTH_SHORT).show();
        });

        // 예제 5: AP가 적은 환경 최적화
        findViewById(R.id.btnSetLowDensity).setOnClickListener(v -> {
            roamingController.setForLowDensityArea();
            Toast.makeText(this, "AP 희박 환경 설정\n(가정, 소규모 사무실)", Toast.LENGTH_SHORT).show();
        });

        // 예제 6: Roaming Trigger만 개별 설정
        findViewById(R.id.btnSetTriggerOnly).setOnClickListener(v -> {
            roamingController.setRoamTrigger(1);  // -75dBm
            Toast.makeText(this, "Roaming Trigger: -75dBm", Toast.LENGTH_SHORT).show();
        });

        // 예제 7: Roaming Delta만 개별 설정
        findViewById(R.id.btnSetDeltaOnly).setOnClickListener(v -> {
            roamingController.setRoamDelta(4);  // 10dB
            Toast.makeText(this, "Roaming Delta: 10dB", Toast.LENGTH_SHORT).show();
        });

        // 예제 8: 커스텀 조합 설정
        findViewById(R.id.btnSetCustomPolicy).setOnClickListener(v -> {
            showRoamingPolicyDialog();
        });

        // 예제 9: 인덱스 정보 표시
        findViewById(R.id.btnShowIndexInfo).setOnClickListener(v -> {
            showIndexInfoDialog();
        });
    }

    /**
     * 커스텀 로밍 정책 선택 다이얼로그
     */
    private void showRoamingPolicyDialog() {
        String[] triggerOptions = {
            "0: -80 dBm (안정)",
            "1: -75 dBm (빠름)",
            "2: -70 dBm (권장)",
            "3: -65 dBm",
            "4: -60 dBm"
        };
        String[] deltaOptions = {
            "0: 30 dB",
            "1: 25 dB",
            "2: 20 dB",
            "3: 15 dB",
            "4: 10 dB (권장)",
            "5: 5 dB (빠름)",
            "6: 0 dB"
        };
        final int[] selectedTrigger = {2};  // 기본값: index 2
        final int[] selectedDelta = {4};    // 기본값: index 4

        AlertDialog.Builder builder = new AlertDialog.Builder(this);
        builder.setTitle("로밍 정책 설정");

        View dialogView = getLayoutInflater().inflate(R.layout.dialog_roaming_policy, null);
        Spinner spinnerTrigger = dialogView.findViewById(R.id.spinnerTrigger);
        Spinner spinnerDelta = dialogView.findViewById(R.id.spinnerDelta);

        ArrayAdapter<String> triggerAdapter = new ArrayAdapter<>(this,
                android.R.layout.simple_spinner_item, triggerOptions);
        triggerAdapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);

        ArrayAdapter<String> deltaAdapter = new ArrayAdapter<>(this,
                android.R.layout.simple_spinner_item, deltaOptions);
        deltaAdapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);

        spinnerTrigger.setAdapter(triggerAdapter);
        spinnerDelta.setAdapter(deltaAdapter);
        spinnerTrigger.setSelection(2);  // index 2 (-70dBm) 기본 선택
        spinnerDelta.setSelection(4);    // index 4 (10dB) 기본 선택

        spinnerTrigger.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
            @Override
            public void onItemSelected(AdapterView<?> parent, View view, int position, long id) {
                selectedTrigger[0] = position;
            }

            @Override
            public void onNothingSelected(AdapterView<?> parent) {}
        });

        spinnerDelta.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
            @Override
            public void onItemSelected(AdapterView<?> parent, View view, int position, long id) {
                selectedDelta[0] = position;
            }

            @Override
            public void onNothingSelected(AdapterView<?> parent) {}
        });

        builder.setView(dialogView);
        builder.setPositiveButton("설정", (dialog, which) -> {
            roamingController.setRoamingPolicy(selectedTrigger[0], selectedDelta[0]);
            Toast.makeText(this,
                String.format("로밍 설정\nTrigger: %d (%d dBm)\nDelta: %d (%d dB)",
                    selectedTrigger[0], roamingController.getTriggerRSSI(selectedTrigger[0]),
                    selectedDelta[0], roamingController.getDeltaValue(selectedDelta[0])),
                Toast.LENGTH_LONG).show();
        });
        builder.setNegativeButton("취소", null);
        builder.show();
    }

    /**
     * 인덱스 정보 표시 다이얼로그
     */
    private void showIndexInfoDialog() {
        String message = "Roaming Trigger 인덱스:\n" +
                "• 0: " + roamingController.getTriggerRSSI(0) + " dBm\n" +
                "• 1: " + roamingController.getTriggerRSSI(1) + " dBm\n" +
                "• 2: " + roamingController.getTriggerRSSI(2) + " dBm (권장)\n" +
                "• 3: " + roamingController.getTriggerRSSI(3) + " dBm\n" +
                "• 4: " + roamingController.getTriggerRSSI(4) + " dBm\n\n" +
                "Roaming Delta 인덱스:\n" +
                "• 0: " + roamingController.getDeltaValue(0) + " dB\n" +
                "• 1: " + roamingController.getDeltaValue(1) + " dB\n" +
                "• 2: " + roamingController.getDeltaValue(2) + " dB\n" +
                "• 3: " + roamingController.getDeltaValue(3) + " dB\n" +
                "• 4: " + roamingController.getDeltaValue(4) + " dB (권장)\n" +
                "• 5: " + roamingController.getDeltaValue(5) + " dB\n" +
                "• 6: " + roamingController.getDeltaValue(6) + " dB";

        new AlertDialog.Builder(this)
                .setTitle("로밍 인덱스 정보")
                .setMessage(message)
                .setPositiveButton("확인", null)
                .show();
    }
}
```

#### Kotlin에서 사용

```kotlin
class WifiRoamingController(private val context: Context) {

    /**
     * Roaming Trigger 설정
     */
    fun setRoamTrigger(triggerIndex: Int) {
        if (!isValidTriggerIndex(triggerIndex)) {
            Log.e("WifiRoamingController", "Invalid roam trigger index: $triggerIndex")
            return
        }

        Intent("com.android.server.startupservice.config").apply {
            putExtra("setting", "wifi_roam_trigger")
            putExtra("value", triggerIndex.toString())
            context.sendBroadcast(this)
        }

        Log.i("WifiRoamingController", "Roam trigger set to index: $triggerIndex (${triggerRSSI(triggerIndex)} dBm)")
    }

    /**
     * Roaming Delta 설정
     */
    fun setRoamDelta(deltaIndex: Int) {
        if (!isValidDeltaIndex(deltaIndex)) {
            Log.e("WifiRoamingController", "Invalid roam delta index: $deltaIndex")
            return
        }

        Intent("com.android.server.startupservice.config").apply {
            putExtra("setting", "wifi_roam_delta")
            putExtra("value", deltaIndex.toString())
            context.sendBroadcast(this)
        }

        Log.i("WifiRoamingController", "Roam delta set to index: $deltaIndex (${deltaValue(deltaIndex)} dB)")
    }

    /**
     * Roaming Trigger와 Delta를 동시에 설정
     */
    fun setRoamingPolicy(triggerIndex: Int, deltaIndex: Int) {
        setRoamTrigger(triggerIndex)
        setRoamDelta(deltaIndex)
    }

    /**
     * Aggressive 로밍 설정
     */
    fun setAggressiveRoaming() = setRoamingPolicy(1, 5)

    /**
     * Moderate 로밍 설정 (기본 권장값)
     */
    fun setModerateRoaming() = setRoamingPolicy(2, 4)

    /**
     * Conservative 로밍 설정
     */
    fun setConservativeRoaming() = setRoamingPolicy(0, 3)

    /**
     * AP가 많은 환경 최적화
     */
    fun setForHighDensityArea() = setRoamingPolicy(1, 4)

    /**
     * AP가 적은 환경 최적화
     */
    fun setForLowDensityArea() = setRoamingPolicy(0, 3)

    /**
     * 최상의 연결 품질 유지
     */
    fun setForBestQuality() = setRoamingPolicy(1, 5)

    /**
     * 연결 안정성 우선
     */
    fun setForStability() = setRoamingPolicy(0, 3)

    /**
     * Trigger 인덱스 유효성 검증
     */
    private fun isValidTriggerIndex(index: Int): Boolean = index in 0..4

    /**
     * Delta 인덱스 유효성 검증
     */
    private fun isValidDeltaIndex(index: Int): Boolean = index in 0..6

    /**
     * Roaming Trigger RSSI 값 가져오기
     */
    fun triggerRSSI(index: Int): Int = when (index) {
        0 -> -80
        1 -> -75
        2 -> -70
        3 -> -65
        4 -> -60
        else -> -70
    }

    /**
     * Roaming Delta 값 가져오기
     */
    fun deltaValue(index: Int): Int = when (index) {
        0 -> 30
        1 -> 25
        2 -> 20
        3 -> 15
        4 -> 10
        5 -> 5
        6 -> 0
        else -> 10
    }
}

// Kotlin Activity 사용 예제
class MainActivity : AppCompatActivity() {
    private lateinit var roamingController: WifiRoamingController

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        roamingController = WifiRoamingController(this)

        // Aggressive 로밍
        findViewById<Button>(R.id.btnSetAggressiveRoaming).setOnClickListener {
            roamingController.setAggressiveRoaming()
            Toast.makeText(this, "Aggressive 로밍 설정", Toast.LENGTH_SHORT).show()
        }

        // Moderate 로밍
        findViewById<Button>(R.id.btnSetModerateRoaming).setOnClickListener {
            roamingController.setModerateRoaming()
            Toast.makeText(this, "Moderate 로밍 설정", Toast.LENGTH_SHORT).show()
        }

        // Conservative 로밍
        findViewById<Button>(R.id.btnSetConservativeRoaming).setOnClickListener {
            roamingController.setConservativeRoaming()
            Toast.makeText(this, "Conservative 로밍 설정", Toast.LENGTH_SHORT).show()
        }

        // AP 밀집 환경
        findViewById<Button>(R.id.btnSetHighDensity).setOnClickListener {
            roamingController.setForHighDensityArea()
            Toast.makeText(this, "AP 밀집 환경 설정", Toast.LENGTH_SHORT).show()
        }

        // AP 희박 환경
        findViewById<Button>(R.id.btnSetLowDensity).setOnClickListener {
            roamingController.setForLowDensityArea()
            Toast.makeText(this, "AP 희박 환경 설정", Toast.LENGTH_SHORT).show()
        }

        // 커스텀 설정
        findViewById<Button>(R.id.btnSetCustomPolicy).setOnClickListener {
            showRoamingPolicyDialog()
        }
    }

    private fun showRoamingPolicyDialog() {
        val triggerOptions = arrayOf(
            "0: -80 dBm (안정)",
            "1: -75 dBm (빠름)",
            "2: -70 dBm (권장)",
            "3: -65 dBm",
            "4: -60 dBm"
        )
        val deltaOptions = arrayOf(
            "0: 30 dB",
            "1: 25 dB",
            "2: 20 dB",
            "3: 15 dB",
            "4: 10 dB (권장)",
            "5: 5 dB (빠름)",
            "6: 0 dB"
        )
        var selectedTrigger = 2  // 기본값
        var selectedDelta = 4    // 기본값

        val dialogView = layoutInflater.inflate(R.layout.dialog_roaming_policy, null)
        val spinnerTrigger = dialogView.findViewById<Spinner>(R.id.spinnerTrigger)
        val spinnerDelta = dialogView.findViewById<Spinner>(R.id.spinnerDelta)

        val triggerAdapter = ArrayAdapter(this, android.R.layout.simple_spinner_item, triggerOptions).apply {
            setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item)
        }

        val deltaAdapter = ArrayAdapter(this, android.R.layout.simple_spinner_item, deltaOptions).apply {
            setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item)
        }

        spinnerTrigger.adapter = triggerAdapter
        spinnerDelta.adapter = deltaAdapter
        spinnerTrigger.setSelection(2)  // index 2
        spinnerDelta.setSelection(4)    // index 4

        spinnerTrigger.onItemSelectedListener = object : AdapterView.OnItemSelectedListener {
            override fun onItemSelected(parent: AdapterView<*>?, view: View?, position: Int, id: Long) {
                selectedTrigger = position
            }
            override fun onNothingSelected(parent: AdapterView<*>?) {}
        }

        spinnerDelta.onItemSelectedListener = object : AdapterView.OnItemSelectedListener {
            override fun onItemSelected(parent: AdapterView<*>?, view: View?, position: Int, id: Long) {
                selectedDelta = position
            }
            override fun onNothingSelected(parent: AdapterView<*>?) {}
        }

        AlertDialog.Builder(this)
            .setTitle("로밍 정책 설정")
            .setView(dialogView)
            .setPositiveButton("설정") { _, _ ->
                roamingController.setRoamingPolicy(selectedTrigger, selectedDelta)
                Toast.makeText(this,
                    "로밍 설정\nTrigger: $selectedTrigger (${roamingController.triggerRSSI(selectedTrigger)} dBm)\nDelta: $selectedDelta (${roamingController.deltaValue(selectedDelta)} dB)",
                    Toast.LENGTH_LONG).show()
            }
            .setNegativeButton("취소", null)
            .show()
    }
}
```

---

### ADB로 테스트하기

#### 각 설정 개별 변경

**Roaming Trigger 설정**

```bash
# Roaming Trigger를 index 0 (-80dBm)으로 설정
adb shell am broadcast -a com.android.server.startupservice.config --es setting "wifi_roam_trigger" --es value 0
```

```bash
# Roaming Trigger를 index 1 (-75dBm)으로 설정
adb shell am broadcast -a com.android.server.startupservice.config --es setting "wifi_roam_trigger" --es value 1
```

```bash
# Roaming Trigger를 index 2 (-70dBm, 권장)로 설정
adb shell am broadcast -a com.android.server.startupservice.config --es setting "wifi_roam_trigger" --es value 2
```

```bash
# Roaming Trigger를 index 3 (-65dBm)으로 설정
adb shell am broadcast -a com.android.server.startupservice.config --es setting "wifi_roam_trigger" --es value 3
```

```bash
# Roaming Trigger를 index 4 (-60dBm)로 설정
adb shell am broadcast -a com.android.server.startupservice.config --es setting "wifi_roam_trigger" --es value 4
```

**Roaming Delta 설정**

```bash
# Roaming Delta를 index 0 (30dB)으로 설정
adb shell am broadcast -a com.android.server.startupservice.config --es setting "wifi_roam_delta" --es value 0
```

```bash
# Roaming Delta를 index 1 (25dB)으로 설정
adb shell am broadcast -a com.android.server.startupservice.config --es setting "wifi_roam_delta" --es value 1
```

```bash
# Roaming Delta를 index 2 (20dB)로 설정
adb shell am broadcast -a com.android.server.startupservice.config --es setting "wifi_roam_delta" --es value 2
```

```bash
# Roaming Delta를 index 3 (15dB)으로 설정
adb shell am broadcast -a com.android.server.startupservice.config --es setting "wifi_roam_delta" --es value 3
```

```bash
# Roaming Delta를 index 4 (10dB, 권장)로 설정
adb shell am broadcast -a com.android.server.startupservice.config --es setting "wifi_roam_delta" --es value 4
```

```bash
# Roaming Delta를 index 5 (5dB)로 설정
adb shell am broadcast -a com.android.server.startupservice.config --es setting "wifi_roam_delta" --es value 5
```

```bash
# Roaming Delta를 index 6 (0dB)으로 설정
adb shell am broadcast -a com.android.server.startupservice.config --es setting "wifi_roam_delta" --es value 6
```

#### 추천 조합 적용하기

**Aggressive 로밍 (빠른 AP 전환)**

Trigger: index 1 (-75dBm), Delta: index 5 (5dB)

```bash
adb shell am broadcast -a com.android.server.startupservice.config --es setting "wifi_roam_trigger" --es value 1
adb shell am broadcast -a com.android.server.startupservice.config --es setting "wifi_roam_delta" --es value 5
```

**Moderate 로밍 (기본 권장)**

Trigger: index 2 (-70dBm), Delta: index 4 (10dB)

```bash
adb shell am broadcast -a com.android.server.startupservice.config --es setting "wifi_roam_trigger" --es value 2
adb shell am broadcast -a com.android.server.startupservice.config --es setting "wifi_roam_delta" --es value 4
```

**Conservative 로밍 (안정적인 연결)**

Trigger: index 0 (-80dBm), Delta: index 3 (15dB)

```bash
adb shell am broadcast -a com.android.server.startupservice.config --es setting "wifi_roam_trigger" --es value 0
adb shell am broadcast -a com.android.server.startupservice.config --es setting "wifi_roam_delta" --es value 3
```

**AP 밀집 환경 (오피스, 공공장소)**

Trigger: index 1 (-75dBm), Delta: index 4 (10dB)

```bash
adb shell am broadcast -a com.android.server.startupservice.config --es setting "wifi_roam_trigger" --es value 1
adb shell am broadcast -a com.android.server.startupservice.config --es setting "wifi_roam_delta" --es value 4
```

**AP 희박 환경 (가정, 소규모 사무실)**

Trigger: index 0 (-80dBm), Delta: index 3 (15dB)

```bash
adb shell am broadcast -a com.android.server.startupservice.config --es setting "wifi_roam_trigger" --es value 0
adb shell am broadcast -a com.android.server.startupservice.config --es setting "wifi_roam_delta" --es value 3
```

---

### 주의사항

1. **독립적인 설정**: Roaming Trigger와 Roaming Delta는 각각 독립적으로 설정할 수 있지만, 두 설정이 함께 작동하므로 조합을 고려하여 설정하는 것이 좋습니다.

2. **기본값**: 설정하지 않으면 시스템 기본값이 적용됩니다. Moderate 로밍 (Trigger=2, Delta=4)을 권장합니다.

3. **설정 순서**: Roaming Trigger와 Roaming Delta 중 어느 것을 먼저 설정해도 무관합니다. 각 설정은 독립적으로 적용됩니다.

4. **효과 확인**: 로밍 설정 변경 후에는 실제 환경에서 이동하며 AP 전환 동작을 테스트하여 원하는 동작을 하는지 확인하는 것이 좋습니다.

5. **네트워크 환경 고려**: 로밍 설정은 AP 배치, 신호 강도, 네트워크 혼잡도 등 다양한 요인에 영향을 받으므로, 실제 사용 환경에 맞게 조정해야 합니다.

6. **인덱스 범위**:
   - Roaming Trigger: 0-4 (5개 옵션)
   - Roaming Delta: 0-6 (7개 옵션)
   - 범위를 벗어난 값을 설정하면 무시됩니다.
