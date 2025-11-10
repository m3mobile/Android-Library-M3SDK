# Wi-Fi 지역 설정 SDK

> [!WARNING]
> StartUp 버전 6.0.6 BETA 버전부터 지원합니다.  
> 
> SL10, SL10K 기기는 지원하지 않습니다.

## 개요

이 SDK는 외부 Android 애플리케이션이 StartUp 앱과의 브로드캐스트 통신을 통해 기기의 Wi-Fi 국가 코드를 설정할 수 있도록 합니다.

Wi-Fi 국가 코드는 기기가 작동하는 지역의 무선 통신 규정을 준수하도록 설정하는 중요한 값입니다.
국가마다 허용되는 Wi-Fi 채널과 전송 출력이 다르므로, 올바른 국가 코드 설정이 필요합니다.

### 빠른 시작

#### 기본 사용법

```java
// Wi-Fi 지역을 '대한민국'으로 설정
Intent intent = new Intent("com.android.server.startupservice.config");
intent.putExtra("setting","wifi_country_code");
intent.putExtra("value","KR");
context.sendBroadcast(intent);

// Wi-Fi 지역을 '미국'으로 설정
Intent intentUS = new Intent("com.android.server.startupservice.config");
intentUS.putExtra("setting","wifi_country_code");
intentUS.putExtra("value","US");
context.sendBroadcast(intentUS);

```

### API 참조

#### 브로드캐스트 액션

**Action**: `com.android.server.startupservice.config`

#### 파라미터

| 파라미터      | 타입     | 필수 | 설명                                          |
|-----------|--------|----|---------------------------------------------|
| `setting` | String | 예  | 반드시 `"wifi_country_code"`로 설정해야 합니다.        |
| `value`   | String | 예  | ISO 3166-1 두 글자 국가 코드 (예: "KR", "US", "JP") |

---

### 세부 설정 가이드

#### Wi-Fi 국가 코드 (Country Code)

기기가 작동하는 지역의 규정을 준수하도록 Wi-Fi 국가 코드를 설정합니다.

- **`setting` 값**: `"wifi_country_code"`
- **`value` 타입**: `String`
- **`value` 설명**: ISO 3166-1 두 글자 국가 코드

#### 주요 국가 코드 예시

| 국가 코드 | 국가명   | 설명                      |
|-------|-------|-------------------------|
| `KR`  | 대한민국  | 한국의 Wi-Fi 규정 준수         |
| `US`  | 미국    | 미국의 Wi-Fi 규정 준수         |
| `JP`  | 일본    | 일본의 Wi-Fi 규정 준수         |
| `CN`  | 중국    | 중국의 Wi-Fi 규정 준수         |
| `EU`  | 유럽 연합 | 유럽 연합의 Wi-Fi 규정 준수 (범용) |
| `GB`  | 영국    | 영국의 Wi-Fi 규정 준수         |
| `AU`  | 호주    | 호주의 Wi-Fi 규정 준수         |
| `CA`  | 캐나다   | 캐나다의 Wi-Fi 규정 준수        |

**참고**: 전체 ISO 3166-1 국가 코드 목록은 [ISO 공식 웹사이트](https://www.iso.org/iso-3166-country-codes.html)에서 확인할
수 있습니다.

---

### 전체 예제

#### 클라이언트 앱 구현

```java
public class WifiCountryCodeController {
    private Context context;

    public WifiCountryCodeController(Context context) {
        this.context = context;
    }

    /**
     * Wi-Fi 국가 코드 설정
     *
     * @param countryCode ISO 3166-1 두 글자 국가 코드 (예: "KR", "US", "JP")
     */
    public void setCountryCode(String countryCode) {
        // 국가 코드 유효성 검증
        if (!isValidCountryCode(countryCode)) {
            Log.e("WifiCountryCodeController", "Invalid country code: " + countryCode);
            return;
        }

        // 자동으로 대문자로 변환
        String upperCountryCode = countryCode.toUpperCase();

        // Wi-Fi 국가 코드 설정 브로드캐스트 전송
        Intent intent = new Intent("com.android.server.startupservice.config");
        intent.putExtra("setting", "wifi_country_code");
        intent.putExtra("value", upperCountryCode);
        context.sendBroadcast(intent);

        Log.i("WifiCountryCodeController", "Wi-Fi country code set: " + upperCountryCode);
    }

    /**
     * 대한민국으로 설정
     */
    public void setKorea() {
        setCountryCode("KR");
    }

    /**
     * 미국으로 설정
     */
    public void setUSA() {
        setCountryCode("US");
    }

    /**
     * 일본으로 설정
     */
    public void setJapan() {
        setCountryCode("JP");
    }

    /**
     * 중국으로 설정
     */
    public void setChina() {
        setCountryCode("CN");
    }

    /**
     * 유럽 연합으로 설정
     */
    public void setEU() {
        setCountryCode("EU");
    }

    /**
     * 영국으로 설정
     */
    public void setUK() {
        setCountryCode("GB");
    }

    /**
     * 호주로 설정
     */
    public void setAustralia() {
        setCountryCode("AU");
    }

    /**
     * 캐나다로 설정
     */
    public void setCanada() {
        setCountryCode("CA");
    }

    /**
     * 국가 코드 유효성 검증
     *
     * @param countryCode 국가 코드
     * @return 유효하면 true, 아니면 false
     */
    private boolean isValidCountryCode(String countryCode) {
        if (countryCode == null || countryCode.isEmpty()) {
            return false;
        }

        // ISO 3166-1: 정확히 2글자의 알파벳
        String upperCode = countryCode.toUpperCase();
        return upperCode.length() == 2 && upperCode.matches("[A-Z]{2}");
    }

    /**
     * 현재 시스템의 국가 코드 가져오기 (참고용)
     *
     * @return 현재 시스템 국가 코드 (ISO 3166-1)
     */
    public String getSystemCountryCode() {
        return Locale.getDefault().getCountry();
    }

    /**
     * 시스템의 국가 코드로 Wi-Fi 국가 코드 설정
     */
    public void setToSystemCountry() {
        String systemCountry = getSystemCountryCode();
        if (!systemCountry.isEmpty()) {
            setCountryCode(systemCountry);
        } else {
            Log.e("WifiCountryCodeController", "Cannot get system country code");
        }
    }
}
```

#### Activity에서 사용

```java
public class MainActivity extends AppCompatActivity {
    private WifiCountryCodeController countryCodeController;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        countryCodeController = new WifiCountryCodeController(this);

        // 예제 1: 대한민국으로 설정
        findViewById(R.id.btnSetKorea).setOnClickListener(v -> {
            countryCodeController.setKorea();
            Toast.makeText(this, "국가 코드: 대한민국 (KR)", Toast.LENGTH_SHORT).show();
        });

        // 예제 2: 미국으로 설정
        findViewById(R.id.btnSetUSA).setOnClickListener(v -> {
            countryCodeController.setUSA();
            Toast.makeText(this, "국가 코드: 미국 (US)", Toast.LENGTH_SHORT).show();
        });

        // 예제 3: 일본으로 설정
        findViewById(R.id.btnSetJapan).setOnClickListener(v -> {
            countryCodeController.setJapan();
            Toast.makeText(this, "국가 코드: 일본 (JP)", Toast.LENGTH_SHORT).show();
        });

        // 예제 4: 중국으로 설정
        findViewById(R.id.btnSetChina).setOnClickListener(v -> {
            countryCodeController.setChina();
            Toast.makeText(this, "국가 코드: 중국 (CN)", Toast.LENGTH_SHORT).show();
        });

        // 예제 5: 유럽 연합으로 설정
        findViewById(R.id.btnSetEU).setOnClickListener(v -> {
            countryCodeController.setEU();
            Toast.makeText(this, "국가 코드: 유럽 연합 (EU)", Toast.LENGTH_SHORT).show();
        });

        // 예제 6: 시스템 국가 코드로 설정
        findViewById(R.id.btnSetSystemCountry).setOnClickListener(v -> {
            String systemCountry = countryCodeController.getSystemCountryCode();
            countryCodeController.setToSystemCountry();
            Toast.makeText(this, "시스템 국가 코드로 설정: " + systemCountry, Toast.LENGTH_SHORT).show();
        });

        // 예제 7: 커스텀 국가 코드 입력
        findViewById(R.id.btnSetCustomCountry).setOnClickListener(v -> {
            showCountryCodeInputDialog();
        });

        // 예제 8: 현재 시스템 국가 코드 확인
        findViewById(R.id.btnShowSystemCountry).setOnClickListener(v -> {
            String systemCountry = countryCodeController.getSystemCountryCode();
            Toast.makeText(this, "현재 시스템 국가: " + systemCountry, Toast.LENGTH_LONG).show();
        });
    }

    /**
     * 사용자로부터 국가 코드 입력 받기
     */
    private void showCountryCodeInputDialog() {
        AlertDialog.Builder builder = new AlertDialog.Builder(this);
        builder.setTitle("국가 코드 설정");
        builder.setMessage("ISO 3166-1 두 글자 국가 코드를 입력하세요");

        final EditText input = new EditText(this);
        input.setHint("예: KR, US, JP");
        input.setFilters(new InputFilter[]{
                new InputFilter.LengthFilter(2),  // 최대 2글자
                new InputFilter.AllCaps()  // 자동 대문자 변환
        });
        builder.setView(input);

        builder.setPositiveButton("설정", (dialog, which) -> {
            String countryCode = input.getText().toString().trim().toUpperCase();
            if (!countryCode.isEmpty()) {
                countryCodeController.setCountryCode(countryCode);
                Toast.makeText(this, "국가 코드 설정: " + countryCode, Toast.LENGTH_SHORT).show();
            }
        });

        builder.setNegativeButton("취소", (dialog, which) -> dialog.cancel());
        builder.show();
    }
}
```

#### Kotlin에서 사용

```kotlin
class WifiCountryCodeController(private val context: Context) {

    /**
     * Wi-Fi 국가 코드 설정
     */
    fun setCountryCode(countryCode: String) {
        // 국가 코드 유효성 검증
        if (!isValidCountryCode(countryCode)) {
            Log.e("WifiCountryCodeController", "Invalid country code: $countryCode")
            return
        }

        // 자동으로 대문자로 변환
        val upperCountryCode = countryCode.uppercase()

        // Wi-Fi 국가 코드 설정 브로드캐스트 전송
        Intent("com.android.server.startupservice.config").apply {
            putExtra("setting", "wifi_country_code")
            putExtra("value", upperCountryCode)
            context.sendBroadcast(this)
        }

        Log.i("WifiCountryCodeController", "Wi-Fi country code set: $upperCountryCode")
    }

    /**
     * 대한민국으로 설정
     */
    fun setKorea() = setCountryCode("KR")

    /**
     * 미국으로 설정
     */
    fun setUSA() = setCountryCode("US")

    /**
     * 일본으로 설정
     */
    fun setJapan() = setCountryCode("JP")

    /**
     * 중국으로 설정
     */
    fun setChina() = setCountryCode("CN")

    /**
     * 유럽 연합으로 설정
     */
    fun setEU() = setCountryCode("EU")

    /**
     * 영국으로 설정
     */
    fun setUK() = setCountryCode("GB")

    /**
     * 호주로 설정
     */
    fun setAustralia() = setCountryCode("AU")

    /**
     * 캐나다로 설정
     */
    fun setCanada() = setCountryCode("CA")

    /**
     * 국가 코드 유효성 검증
     */
    private fun isValidCountryCode(countryCode: String): Boolean {
        if (countryCode.isEmpty()) return false
        val upperCode = countryCode.uppercase()
        return upperCode.length == 2 && upperCode.matches(Regex("[A-Z]{2}"))
    }

    /**
     * 현재 시스템의 국가 코드 가져오기
     */
    fun systemCountryCode(): String {
        return Locale.getDefault().country
    }

    /**
     * 시스템의 국가 코드로 Wi-Fi 국가 코드 설정
     */
    fun setToSystemCountry() {
        val systemCountry = systemCountryCode()
        if (systemCountry.isNotEmpty()) {
            setCountryCode(systemCountry)
        } else {
            Log.e("WifiCountryCodeController", "Cannot get system country code")
        }
    }
}

// Kotlin Activity 사용 예제
class MainActivity : AppCompatActivity() {
    private lateinit var countryCodeController: WifiCountryCodeController

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        countryCodeController = WifiCountryCodeController(this)

        // 대한민국
        findViewById<Button>(R.id.btnSetKorea).setOnClickListener {
            countryCodeController.setKorea()
            Toast.makeText(this, "국가 코드: 대한민국 (KR)", Toast.LENGTH_SHORT).show()
        }

        // 미국
        findViewById<Button>(R.id.btnSetUSA).setOnClickListener {
            countryCodeController.setUSA()
            Toast.makeText(this, "국가 코드: 미국 (US)", Toast.LENGTH_SHORT).show()
        }

        // 일본
        findViewById<Button>(R.id.btnSetJapan).setOnClickListener {
            countryCodeController.setJapan()
            Toast.makeText(this, "국가 코드: 일본 (JP)", Toast.LENGTH_SHORT).show()
        }

        // 시스템 국가 코드로 설정
        findViewById<Button>(R.id.btnSetSystemCountry).setOnClickListener {
            val systemCountry = countryCodeController.systemCountryCode()
            countryCodeController.setToSystemCountry()
            Toast.makeText(this, "시스템 국가: $systemCountry", Toast.LENGTH_SHORT).show()
        }

        // 커스텀 입력
        findViewById<Button>(R.id.btnSetCustomCountry).setOnClickListener {
            showCountryCodeInputDialog()
        }
    }

    private fun showCountryCodeInputDialog() {
        val input = EditText(this).apply {
            hint = "예: KR, US, JP"
            filters = arrayOf(
                InputFilter.LengthFilter(2),
                InputFilter.AllCaps()
            )
        }

        AlertDialog.Builder(this)
            .setTitle("국가 코드 설정")
            .setMessage("ISO 3166-1 두 글자 국가 코드를 입력하세요")
            .setView(input)
            .setPositiveButton("설정") { _, _ ->
                val countryCode = input.text.toString().trim().uppercase()
                if (countryCode.isNotEmpty()) {
                    countryCodeController.setCountryCode(countryCode)
                    Toast.makeText(this, "국가 코드 설정: $countryCode", Toast.LENGTH_SHORT).show()
                }
            }
            .setNegativeButton("취소", null)
            .show()
    }
}
```

---

### ADB로 테스트하기

#### Wi-Fi 국가 코드 설정

```bash
# 대한민국으로 설정
adb shell am broadcast -a com.android.server.startupservice.config --es setting "wifi_country_code" --es value "KR"
```

```bash
# 미국으로 설정
adb shell am broadcast -a com.android.server.startupservice.config --es setting "wifi_country_code" --es value "US"
```

```bash
# 일본으로 설정
adb shell am broadcast -a com.android.server.startupservice.config --es setting "wifi_country_code" --es value "JP"
```

---

### 주의사항

1. **유효한 국가 코드 사용**: ISO 3166-1 표준을 따르는 두 글자 국가 코드만 사용해야 합니다.
2. **대문자 사용**: 국가 코드는 반드시 대문자로 입력해야 합니다 (예: "kr" ❌, "KR" ✅).
3. **법적 준수**: 기기가 실제로 작동하는 지역의 국가 코드를 설정해야 합니다. 잘못된 국가 코드 설정은 해당 지역의 무선 통신 규정을 위반할 수 있습니다.
4. **재시작 필요 여부**: 일부 기기에서는 국가 코드 변경 후 Wi-Fi를 껐다 켜거나 기기를 재시작해야 설정이 완전히 적용될 수 있습니다.
