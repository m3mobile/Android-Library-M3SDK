# USB 설정 제어 SDK

> **참고** <br>
> 이 기능은 StartUp 버전 6.5.10 부터 지원됩니다. <br>
> US20 (Android 10), US30 (Android 13) 기기에 지원됩니다. 

## 개요

이 SDK는 외부 안드로이드 애플리케이션이 StartUp 앱과의 브로드캐스트 통신을 통해 기기의 USB 모드 설정을 제어할 수 있도록 합니다.
시스템 설정에 대한 특권 액세스를 제공합니다.

### 빠른 시작

#### 기본 사용법

```java
// Set USB mode to "No data transfer"
Intent intent = new Intent("com.android.server.startupservice.system");
intent.putExtra("setting","usb_setting");
intent.putExtra("usb_mode","none");

context.sendBroadcast(intent);
```

#### 결과 콜백 사용

```java
// Send USB setting and receive result
Intent intent = new Intent("com.android.server.startupservice.system");
intent.putExtra("setting","usb_setting");
intent.putExtra("usb_mode","mtp");
// The value for "usb_result_action" can be any custom string you want.
intent.putExtra("usb_result_action","com.example.myapp.USB_RESULT"); 

context.sendBroadcast(intent);
```

### API 참조

#### 브로드캐스트 액션

**액션**: `com.android.server.startupservice.system`

#### 파라미터

| 파라미터                | 타입     | 필수 여부 | 설명                                        |
|---------------------|--------|-------|-------------------------------------------|
| `setting`           | String | 예     | 설정 타입. USB 제어의 경우 `"usb_setting"` 값 사용    |
| `usb_mode`          | String | 예     | USB 모드: "mtp", "midi", "ptp", "none" 중 하나 |
| `usb_result_action` | String | 아니요   | 결과 콜백 브로드캐스트를 위한 사용자 지정 액션                |

#### USB 모드

| 모드 값    | 설명                     | 용도                |
|---------|------------------------|-------------------|
| `mtp`   | File Transfer (MTP)    | 파일 전송 (기본 파일 관리자) |
| `rndis` | USB tethering          | 인터넷 연결 공유         |
| `midi`  | MIDI                   | 악기 연결             |
| `ptp`   | PTP (Picture Transfer) | 사진 전송             |
| `none`  | No data transfer       | 충전만 (데이터 전송 없음)   |

#### 결과 콜백

만약 `usb_result_action` 파라미터를 제공하면, StartUp 앱은 결과 브로드캐스트를 전송합니다:

**액션**: 사용자 지정 액션 문자열 (예: `com.example.myapp.USB_RESULT`)

**결과 파라미터**:

| 파라미터                | 타입      | 설명                                  |
|---------------------|---------|-------------------------------------|
| `usb_success`       | boolean | 작업이 성공하면 `true`, 실패하면 `false`       |
| `usb_error_message` | String  | 오류 설명 (`usb_success`가 false일 때만 존재) |

### 오류 처리

#### 오류 시나리오

1. **잘못된 USB 모드**
   ```
   Error: "Invalid USB mode: invalid_mode. Valid modes are: mtp, midi, ptp, none"
   ```
   **해결책**: 유효한 USB 모드를 사용하십시오 (mtp, midi, ptp, none).

2. **지원하지 않는 Android 버전**
   ```
   Error: "USB mode control requires Android 10 or higher"
   ```
   **해결책**: Android 10 (API 29) 이상이 필요합니다.

3. **시스템 오류**
   ```
   Error: "Failed to apply USB setting: [system error details]"
   ```
   **해결책**: 시스템 권한 및 기기 상태를 확인하십시오.

### 전체 예제

#### 클라이언트 앱 구현

```java
public class UsbController {
    private Context context;
    private BroadcastReceiver resultReceiver;

    public UsbController(Context context) {
        this.context = context;
    }

    /**
     * Set USB mode with result callback
     * @param usbMode "mtp", "midi", "ptp", or "none"
     */
    public void setUsbMode(String usbMode) {
        // Register result receiver
        registerResultReceiver();

        // Send USB setting broadcast
        Intent intent = new Intent("com.android.server.startupservice.system");
        intent.putExtra("setting", "usb_setting");
        intent.putExtra("usb_mode", usbMode);
        intent.putExtra("usb_result_action", "com.example.myapp.USB_RESULT");
        context.sendBroadcast(intent);

        Log.i("UsbController", "USB mode setting sent: " + usbMode);
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
                boolean success = intent.getBooleanExtra("usb_success", false);
                String errorMessage = intent.getStringExtra("usb_error_message");

                if (success) {
                    Log.i("UsbController", "USB mode applied successfully");
                    onUsbModeSetSuccess();
                } else {
                    Log.e("UsbController", "USB mode setting failed: " + errorMessage);
                    onUsbModeSetFailed(errorMessage);
                }
            }
        };

        IntentFilter filter = new IntentFilter("com.example.myapp.USB_RESULT");
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
    protected void onUsbModeSetSuccess() {
        // Handle success (e.g., show toast, update UI)
    }

    /**
     * Override this method to handle failure
     */
    protected void onUsbModeSetFailed(String errorMessage) {
        // Handle failure (e.g., show error dialog)
    }
}
```

#### Activity에서 사용

```java
public class MainActivity extends AppCompatActivity {
    private UsbController usbController;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        usbController = new UsbController(this) {
            @Override
            protected void onUsbModeSetSuccess() {
                Toast.makeText(MainActivity.this,
                        "USB mode set successfully", Toast.LENGTH_SHORT).show();
            }

            @Override
            protected void onUsbModeSetFailed(String errorMessage) {
                Toast.makeText(MainActivity.this,
                        "Failed: " + errorMessage, Toast.LENGTH_LONG).show();
            }
        };

        // Example: Set USB mode to "No data transfer"
        findViewById(R.id.btnNoDataTransfer).setOnClickListener(v -> {
            usbController.setUsbMode("none");
        });

        // Example: Set USB mode to File Transfer (MTP)
        findViewById(R.id.btnFileTransfer).setOnClickListener(v -> {
            usbController.setUsbMode("mtp");
        });

        // Example: Set USB mode to MIDI
        findViewById(R.id.btnMidi).setOnClickListener(v -> {
            usbController.setUsbMode("midi");
        });

        // Example: Set USB mode to PTP
        findViewById(R.id.btnPtp).setOnClickListener(v -> {
            usbController.setUsbMode("ptp");
        });
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        usbController.cleanup();
    }
}
```

### ADB를 사용한 테스트

ADB(Android Debug Bridge) 명령어를 사용하여 터미널에서 USB 모드 제어 기능을 테스트할 수 있습니다.

#### USB 모드 설정 (No data transfer)

```bash
adb shell am broadcast -a com.android.server.startupservice.system --es setting "usb_setting" --es usb_mode "none"
```

#### USB 모드 설정 (File Transfer - MTP)

```bash
adb shell am broadcast -a com.android.server.startupservice.system --es setting "usb_setting" --es usb_mode "mtp"
```

#### USB 모드 설정 (MIDI)

```bash
adb shell am broadcast -a com.android.server.startupservice.system --es setting "usb_setting" --es usb_mode "midi"
```

#### USB 모드 설정 (PTP)

```bash
adb shell am broadcast -a com.android.server.startupservice.system --es setting "usb_setting" --es usb_mode "ptp"
```

#### 결과 콜백 테스트

```bash
# 먼저, logcat에서 결과 모니터링
adb logcat | Select-string "USB_RESULT"
# 혹은 adb logcat | grep "USB_RESULT" 

# 다른 터미널에서 결과 액션과 함께 브로드캐스트 전송
adb shell am broadcast -a com.android.server.startupservice.system --es setting "usb_setting" --es usb_mode "none" --es usb_result_action "com.test.USB_RESULT"
```
