# Wi-Fi Captive Portal SDK

공공 Wi-Fi의 캡티브 포털(인증 페이지) 감지 기능을 제어합니다.

> **Note** <br>
> StartUp 버전 6.0.6 BETA 버전부터 지원합니다. <br>
> [안드로이드 11 부터 지원](https://developer.android.com/about/versions/11/features/captive-portal?hl=ko)하며,
> SL20 기기는 지원하지 않습니다.

## 브로드캐스트 액션

### 설정 API

| 액션                                         | 목적                   |
|--------------------------------------------|----------------------|
| `com.android.server.startupservice.config` | Captive Portal 설정 변경 |

---

## API 상세

### 파라미터

| 파라미터      | 타입     | 값                | 설명     |
|-----------|--------|------------------|--------|
| `setting` | String | `captive_portal` | 설정 키   |
| `value`   | int    | `0`, `1`         | 활성화 여부 |

### 기능 설명

| 값   | 상태   | 동작                              |
|-----|------|---------------------------------|
| `0` | 비활성화 | 캡티브 포털 감지 안 함, 일반 인터넷 연결 확인만 수행 |
| `1` | 활성화  | 캡티브 포털 자동 감지, 로그인 필요 시 알림 제공    |

### 사용 사례

- **활성화(1)**: 공공 Wi-Fi가 많은 카페, 공항, 호텔 환경
- **비활성화(0)**: 회사 네트워크, 집 Wi-Fi 등 인증이 불필요한 환경

### Kotlin 코드 예시

```kotlin
// Captive Portal 활성화
fun enableCaptivePortalDetection(context: Context) {
    val intent = Intent("com.android.server.startupservice.config").apply {
        putExtra("setting", "captive_portal")
        putExtra("value", 1) // Enable
    }
    context.sendBroadcast(intent)
}

// Captive Portal 비활성화
fun disableCaptivePortalDetection(context: Context) {
    val intent = Intent("com.android.server.startupservice.config").apply {
        putExtra("setting", "captive_portal")
        putExtra("value", 0) // Disable
    }
    context.sendBroadcast(intent)
}
```

### ADB 명령어 예시

```bash
# Captive Portal 활성화
adb shell am broadcast -a com.android.server.startupservice.config --es setting "captive_portal" --ei value 1
```

```bash
# Captive Portal 비활성화
adb shell am broadcast -a com.android.server.startupservice.config --es setting "captive_portal" --ei value 0
```

### 응답 정보

- **응답 형식**: 별도 응답 브로드캐스트 없음
- **모니터링**: 시스템 설정 > 네트워크 > Wi-Fi > 고급에서 확인 가능
