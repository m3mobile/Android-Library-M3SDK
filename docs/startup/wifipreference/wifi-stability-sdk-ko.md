# Wi-Fi Stability (안정성) SDK

Wi-Fi 연결의 안정성 수준을 설정합니다. 신호 강도 변화에 대한 재연결 정책을 제어합니다.

> [!WARNING]
> **Android 13 이상 버전에서는 호환되지 않음**
> 
> Android 13 (API 33)부터 Wi-Fi 관련 내부 정책 변경으로 인해 이 SDK를 통한 안정성 설정이 더 이상 적용되지 않습니다.

## 브로드캐스트 액션

### 설정 API

| 액션                                             | 목적                    | 특징                  |
|------------------------------------------------|-----------------------|---------------------|
| `com.android.server.startupservice.config`     | Wi-Fi Stability 설정 변경 | JSON 저장, 재부팅 후에도 유지 |
| `com.android.server.startupservice.config.fin` | 설정 완료 신호              | 모든 config 설정 일괄 적용  |

---

## API 상세

### 파라미터

| 파라미터      | 타입     | 값                | 설명     |
|-----------|--------|------------------|--------|
| `setting` | String | `wifi_stability` | 설정 키   |
| `value`   | int    | `1`, `2`         | 안정성 모드 |

### Stability 모드

| 값   | 모드     | 설명                                   |
|-----|--------|--------------------------------------|
| `1` | Normal | 일반적인 Wi-Fi 안정성 (신호 약할 때 가끔 재연결)      |
| `2` | High   | 높은 안정성 (신호가 약해도 연결 유지 시도, 배터리 소비 증가) |

### Kotlin 코드 예시

```kotlin
// Wi-Fi 안정성 설정 - 일반 모드
fun setWifiStabilityNormal(context: Context) {
    val intent = Intent("com.android.server.startupservice.config").apply {
        putExtra("setting", "wifi_stability")
        putExtra("value", 1) // Normal
    }
    context.sendBroadcast(intent)
}

// Wi-Fi 안정성 설정 - 높은 안정성
fun setWifiStabilityHigh(context: Context) {
    val intent = Intent("com.android.server.startupservice.config").apply {
        putExtra("setting", "wifi_stability")
        putExtra("value", 2) // High
    }
    context.sendBroadcast(intent)
}
```

### ADB 명령어 예시

```bash
# Wi-Fi 안정성 설정 - 일반 모드
adb shell am broadcast -a com.android.server.startupservice.config --es setting "wifi_stability" --ei value 1
```

```bash
# Wi-Fi 안정성 설정 - 높은 안정성
adb shell am broadcast -a com.android.server.startupservice.config --es setting "wifi_stability" --ei value 2
```

### 응답 정보

- **응답 형식**: 별도 응답 브로드캐스트 없음
- **적용 시점**: `config.fin` 액션 수신 후 약 1-2초 이내
