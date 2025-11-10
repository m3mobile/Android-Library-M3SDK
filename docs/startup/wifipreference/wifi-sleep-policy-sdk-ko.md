# Wi-Fi Sleep Policy SDK

> **Note** <br>
> StartUp 버전 6.0.6 BETA 버전부터 지원합니다.

화면이 꺼진 상태(대기 모드)에서 Wi-Fi 동작 방식을 제어합니다.

## 브로드캐스트 액션

### 설정 API

| 액션                                             | 목적                       |
|------------------------------------------------|--------------------------|
| `com.android.server.startupservice.config`     | Wi-Fi Sleep Policy 설정 변경 |

---

## API 상세

### 파라미터

| 파라미터      | 타입     | 값             | 설명              |
|-----------|--------|---------------|-----------------|
| `setting` | String | `wifi_sleep`  | 설정 키            |
| `value`   | int    | `0`, `1`, `2` | Sleep Policy 모드 |

### Sleep Policy 모드

| 값   | 모드                   | 설명                                   |
|-----|----------------------|--------------------------------------|
| `0` | Never                | 화면이 꺼진 상태에서도 Wi-Fi 연결 유지 (배터리 소비 많음) |
| `1` | Only when plugged in | AC 전원 연결 시에만 Wi-Fi 유지                |
| `2` | Always               | 화면이 꺼지면 Wi-Fi 비활성화 (배터리 절약)          |

### Kotlin 코드 예시

```kotlin
// Wi-Fi Sleep Policy 설정 - 항상 연결 유지
fun setWifiSleepPolicyNever(context: Context) {
    val intent = Intent("com.android.server.startupservice.config").apply {
        putExtra("setting", "wifi_sleep")
        putExtra("value", 0) // Never
    }
    context.sendBroadcast(intent)
}

// Wi-Fi Sleep Policy 설정 - 화면 꺼질 때 Wi-Fi 비활성화
fun setWifiSleepPolicyAlways(context: Context) {
    val intent = Intent("com.android.server.startupservice.config").apply {
        putExtra("setting", "wifi_sleep")
        putExtra("value", 2) // Always
    }
    context.sendBroadcast(intent)
}

// Wi-Fi Sleep Policy 설정 - 전원 연결 시에만 유지
fun setWifiSleepPolicyPluggedOnly(context: Context) {
    val intent = Intent("com.android.server.startupservice.config").apply {
        putExtra("setting", "wifi_sleep")
        putExtra("value", 1) // Only when plugged in
    }
    context.sendBroadcast(intent)
}
```

### ADB 명령어 예시

```bash
# Wi-Fi 항상 연결 유지 (Sleep Policy: Never)
adb shell am broadcast -a com.android.server.startupservice.config --es setting "wifi_sleep" --ei value 0
```

```bash
# Wi-Fi 항상 연결 유지 (Sleep Policy: Never)
adb shell am broadcast -a com.android.server.startupservice.config --es setting "wifi_sleep" --ei value 1
```

```bash
# Wi-Fi 화면 꺼질 때 비활성화 (Sleep Policy: Always)
adb shell am broadcast -a com.android.server.startupservice.config --es setting "wifi_sleep" --ei value 2
```

### 응답 정보

- **응답 형식**: 별도 응답 브로드캐스트 없음1
