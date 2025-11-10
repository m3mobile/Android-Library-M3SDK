# 볼륨 및 사운드 SDK

## 개요

Android-App-StartUp의 볼륨 및 사운드 설정 SDK는 외부 앱이 브로드캐스트 인텐트를 통해 기기의 다양한 오디오 스트림 볼륨을 제어할 수 있는 두 가지 API를 제공합니다.

- **CONFIG API:** 설정을 JSON으로 저장하여, 부팅 후에도 설정을 유지해야 할 때 사용합니다.
- **SYSTEM API:** 설정을 저장하지 않고, 즉시 일회성으로 볼륨을 변경할 때 사용합니다.

---

## 브로드캐스트 액션

### 1. CONFIG API
- **액션:** `com.android.server.startupservice.config`
- **특징:**
    - 브로드캐스트 수신 즉시 볼륨이 변경됩니다.
    
### 2. SYSTEM API
- **액션:** `com.android.server.startupservice.system`
- **특징:**
    - 브로드캐스트 수신 즉시 볼륨이 변경됩니다.

두 API 는 액션 문자열만 다를 뿐 동작은 같습니다. 

---

## CONFIG API

`com.android.server.startupservice.config` 액션을 사용하며, 파라미터 이름은 `volume_` 접두사로 시작합니다.

### 1. 미디어 볼륨

| 파라미터           | 타입  | 범위   | 설명                       |
|----------------|-----|------|--------------------------|
| `volume_media` | int | 0-15 | 미디어(음악, 비디오, 게임 등) 재생 음량 |

> **호환성 (Compatibility)**
> - 모든 기기에서 지원됩니다.

**ADB 테스트 예시:**
```bash
# 미디어 음량 10으로 설정
adb shell am broadcast -a com.android.server.startupservice.config --es setting "volume" --ei volume_media 10
```

### 2. 벨소리 볼륨

| 파라미터              | 타입  | 범위          | 설명                        |
|-------------------|-----|-------------|---------------------------|
| `volume_ringtone` | int | 0-7 또는 0-15 | 전화 수신음 음량. 범위는 기기별로 다릅니다. |

> **호환성 (Compatibility)**
> - **최대값 15:** `SL10`, `SL10K`, `SL20`, `SL20K`, `SL20P`, `SL25`, `PC10`
> - **최대값 7:** 그 외 모든 모델
>
> **기능적 제약 (Android 14+):**
> - `volume_ringtone`이 `0`으로 설정된 경우, `volume_notification`은 `0`으로 자동으로 설정됩니다.
> 
> **기능적 제약 (Android 13 이하 버전):**
> - `volume_ringtone`과 `volume_notification`의 독립적인 제어가 불가능합니다.

**ADB 테스트 예시:**
```bash
# 벨소리 음량 5로 설정
adb shell am broadcast -a com.android.server.startupservice.config --es setting "volume" --ei volume_ringtone 5
```

### 3. 알림 볼륨

| 파라미터                  | 타입  | 범위          | 설명                     |
|-----------------------|-----|-------------|------------------------|
| `volume_notification` | int | 0-7 또는 0-15 | 알림음 음량. 범위는 기기별로 다릅니다. |

> **호환성 (Compatibility)**
> - **OS 종속성:** 이 파라미터는 **Android 14 (API 34) 이상**에서만 독립적으로 동작합니다.
> - **하위 호환성:** Android 13 이하에서는 `volume_notification` 브로드캐스트를 통한 알림 볼륨 제어가 동작하지 않습니다. 이 경우, `volume_ringtone` 브로드캐스트를 사용하여 벨소리 볼륨을 조절하면 알림 볼륨도 함께 조절됩니다.
> - **최대값 (Android 14+):**
>   - **최대값 15:** `SL10`, `SL10K`, `SL20`, `SL20K`, `SL20P`, `SL25`, `PC10`
>   - **최대값 7:** 그 외 모든 모델
>
> **기능적 제약 (Android 14+):**
> - `volume_ringtone`이 `0`으로 설정된 경우, `volume_notification`은 `0`보다 큰 값으로 설정할 수 없습니다.

**ADB 테스트 예시:**
```bash
# 알림 음량 5로 설정 (Android 14+)
adb shell am broadcast -a com.android.server.startupservice.config --es setting "volume" --ei volume_notification 5
```

### 4. 알람 볼륨

| 파라미터           | 타입  | 범위          | 설명                     |
|----------------|-----|-------------|------------------------|
| `volume_alarm` | int | 0-7 또는 0-15 | 알람음 음량. 범위는 기기별로 다릅니다. |

> **호환성 (Compatibility)**
> - **최대값 15:** `SL10`, `SL10K`, `SL20`, `SL20K`, `SL20P`, `PC10`
> - **최대값 7:** 그 외 모든 모델

**ADB 테스트 예시:**
```bash
# 알람 음량 7로 설정
adb shell am broadcast -a com.android.server.startupservice.config --es setting "volume" --ei volume_alarm 7
```

### 5. 진동 모드

| 파라미터              | 타입      | 설명                                     |
|-------------------|---------|----------------------------------------|
| `volume_vibrator` | boolean | `true`: 진동 모드 활성화, `false`: 진동 모드 비활성화 |

> **호환성 (Compatibility)**
> - 모든 기기에서 지원됩니다.
>
> **기능적 제약:**
> - 진동 모드로 설정하면, `volume_ringtone` 과 `volume_notification` 은 자동으로 0 으로 조정됩니다.

**ADB 테스트 예시:**
```bash
# 진동 모드 활성화
adb shell am broadcast -a com.android.server.startupservice.config --es setting "volume" --ez volume_vibrator true
```
### CONFIG API 전체 예시

**Kotlin 예시:**
```kotlin
// 여러 볼륨 설정을 한 번에 구성
val intent = Intent("com.android.server.startupservice.config").apply {
    putExtra("setting", "volume")
    putExtra("volume_media", 10)
    putExtra("volume_ringtone", 5)
    putExtra("volume_alarm", 7)
    putExtra("volume_vibrator", false)
    
    if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
        putExtra("volume_notification", 5)
    }
}
context.sendBroadcast(intent)
```

**Java 예시:**
```java
// 여러 볼륨 설정을 한 번에 구성
Intent intent = new Intent("com.android.server.startupservice.config");
intent.putExtra("setting", "volume");
intent.putExtra("volume_media", 10);
intent.putExtra("volume_ringtone", 5);
intent.putExtra("volume_alarm", 7);
intent.putExtra("volume_vibrator", false);

if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
    intent.putExtra("volume_notification", 5);
}
context.sendBroadcast(intent);
```

**ADB 예시:**
```bash
# 여러 볼륨을 한 번에 설정 (Android 14+ 기준) 후 적용
adb shell am broadcast -a com.android.server.startupservice.config --es setting "volume" --ei volume_media 10 --ei volume_ringtone 5 --ei volume_notification 5 --ei volume_alarm 7 --ez volume_vibrator false
```

---

## SYSTEM API

`com.android.server.startupservice.system` 액션을 사용하며, 파라미터 이름에 `volume_` 접두사가 없습니다.

### 1. 미디어 볼륨

| 파라미터    | 타입  | 범위   | 설명                       |
|---------|-----|------|--------------------------|
| `media` | int | 0-15 | 미디어(음악, 비디오, 게임 등) 재생 음량 |

> **호환성 (Compatibility)**
> - 모든 기기에서 지원됩니다.

**ADB 테스트 예시:**
```bash
# 미디어 음량 10으로 즉시 설정
adb shell am broadcast -a com.android.server.startupservice.system --es setting "volume" --ei media 10
```

### 2. 벨소리 볼륨

| 파라미터       | 타입  | 범위          | 설명                        |
|------------|-----|-------------|---------------------------|
| `ringtone` | int | 0-7 또는 0-15 | 전화 수신음 음량. 범위는 기기별로 다릅니다. |

> **호환성 (Compatibility)**
> - **최대값 15:** `SL10`, `SL10K`, `SL20`, `SL20K`, `SL20P`, `SL25`, `PC10`
> - **최대값 7:** 그 외 모든 모델
>
> **기능적 제약 (Android 14+):**
> - `ringtone`이 `0`으로 설정된 경우, `notification`은 `0`으로 자동으로 설정됩니다.
>
> **기능적 제약 (Android 13 이하 버전):**
> - `ringtone`과 `notification`의 독립적인 제어가 불가능합니다.


**ADB 테스트 예시:**
```bash
# 벨소리 음량 5로 즉시 설정
adb shell am broadcast -a com.android.server.startupservice.system --es setting "volume" --ei ringtone 5
```

### 3. 알림 볼륨

| 파라미터           | 타입  | 범위          | 설명                     |
|----------------|-----|-------------|------------------------|
| `notification` | int | 0-7 또는 0-15 | 알림음 음량. 범위는 기기별로 다릅니다. |

> **호환성 (Compatibility)**
> - **OS 종속성:** 이 파라미터는 **Android 14 (API 34) 이상**에서만 독립적으로 동작합니다.
> - **하위 호환성:** Android 13 이하에서는 `notification` 브로드캐스트를 통한 알림 볼륨 제어가 동작하지 않습니다. 이 경우, `ringtone` 브로드캐스트를 사용하여 벨소리 볼륨을 조절하면 알림 볼륨도 함께 조절됩니다.
> - **최대값 (Android 14+):**
>   - **최대값 15:** `SL10`, `SL10K`, `SL20`, `SL20K`, `SL20P`, `SL25`, `PC10`
>   - **최대값 7:** 그 외 모든 모델
>
> **기능적 제약 (Android 14+):**
> - `ringtone`이 `0`으로 설정된 경우, `notification`은 `0`보다 큰 값으로 설정할 수 없습니다.

**ADB 테스트 예시:**
```bash
# 알림 음량 5로 즉시 설정 (Android 14+)
adb shell am broadcast -a com.android.server.startupservice.system --es setting "volume" --ei notification 5
```

### 4. 알람 볼륨

| 파라미터    | 타입  | 범위          | 설명                     |
|---------|-----|-------------|------------------------|
| `alarm` | int | 0-7 또는 0-15 | 알람음 음량. 범위는 기기별로 다릅니다. |

> **호환성 (Compatibility)**
> - **최대값 15:** `SL10`, `SL10K`, `SL20`, `SL20K`, `SL20P`, `PC10`
> - **최대값 7:** 그 외 모든 모델

**ADB 테스트 예시:**
```bash
# 알람 음량 7로 즉시 설정
adb shell am broadcast -a com.android.server.startupservice.system --es setting "volume" --ei alarm 7
```

### 5. 진동 모드

| 파라미터       | 타입      | 설명                                     |
|------------|---------|----------------------------------------|
| `vibrator` | boolean | `true`: 진동 모드 활성화, `false`: 진동 모드 비활성화 |

> **호환성 (Compatibility)**
> - 모든 기기에서 지원됩니다.
>
> **기능적 제약:**
> - 진동 모드로 설정하면, `ringtone`과 `notification`은 자동으로 0으로 조정됩니다.

**ADB 테스트 예시:**
```bash
# 진동 모드 활성화
adb shell am broadcast -a com.android.server.startupservice.system --es setting "volume" --ez vibrator true
```

### SYSTEM API 전체 예시

**Kotlin 예시:**
```kotlin
// 미디어 음량을 즉시 12로 설정
val intent = Intent("com.android.server.startupservice.system").apply {
    putExtra("setting", "volume")
    putExtra("media", 12)
}
context.sendBroadcast(intent)
```

**Java 예시:**
```java
// 벨소리 음량을 즉시 최대로 설정
Intent intent = new Intent("com.android.server.startupservice.system");
intent.putExtra("setting", "volume");
intent.putExtra("ringtone", 7); // 기기 모델에 따라 최대값 확인 필요
context.sendBroadcast(intent);
```

**ADB 예시:**
```bash
# 미디어 음량을 즉시 12로, 알람 음량을 5로 설정
adb shell am broadcast -a com.android.server.startupservice.system --es setting "volume" --ei media 12 --ei alarm 5
```

---
