# Wi-Fi Open Network Notification SDK

> **Note** <br>
> StartUp 버전 6.0.6 BETA 버전부터 지원합니다.

보안이 없는 Wi-Fi 네트워크 감지 알림 기능을 제어합니다.

## 브로드캐스트 액션

### 설정 API

| 액션                                             | 목적                              | 특징                  |
|------------------------------------------------|---------------------------------|---------------------|
| `com.android.server.startupservice.config`     | Open Network Notification 설정 변경 | JSON 저장, 재부팅 후에도 유지 |
| `com.android.server.startupservice.config.fin` | 설정 완료 신호                        | 모든 config 설정 일괄 적용  |

---

## API 상세

### 파라미터

| 파라미터      | 타입     | 값                | 설명     |
|-----------|--------|------------------|--------|
| `setting` | String | `wifi_open_noti` | 설정 키   |
| `value`   | int    | `0`, `1`         | 활성화 여부 |

### 기능 설명

| 값   | 상태   | 동작                            |
|-----|------|-------------------------------|
| `0` | 비활성화 | Open Network(보안 없음) 감지 알림 안 함 |
| `1` | 활성화  | Open Network 자동 감지 및 알림 표시    |

### 사용 사례

- **활성화(1)**: 일반 사용자 환경, 보안 인식 높이기 필요
- **비활성화(0)**: 통제된 환경(기업/교육), 보안 설정이 이미 완료된 상황

### Kotlin 코드 예시

```kotlin
// Open Network Notification 활성화
fun enableOpenNetworkNotification(context: Context) {
    val intent = Intent("com.android.server.startupservice.config").apply {
        putExtra("setting", "wifi_open_noti")
        putExtra("value", 1) // Enable
    }
    context.sendBroadcast(intent)
}

// Open Network Notification 비활성화
fun disableOpenNetworkNotification(context: Context) {
    val intent = Intent("com.android.server.startupservice.config").apply {
        putExtra("setting", "wifi_open_noti")
        putExtra("value", 0) // Disable
    }
    context.sendBroadcast(intent)
}
```

### ADB 명령어 예시

```bash
# Open Network Notification 활성화
adb shell am broadcast -a com.android.server.startupservice.config --es setting "wifi_open_noti" --ei value 1
```

```bash
# Open Network Notification 비활성화
adb shell am broadcast -a com.android.server.startupservice.config --es setting "wifi_open_noti" --ei value 0
```

### 응답 정보

- **응답 형식**: 별도 응답 브로드캐스트 없음
- **적용 시점**: `config.fin` 액션 수신 후 약 1-2초 이내
- **알림 동작**: 시스템 상태바에 "Open network available" 알림 표시

