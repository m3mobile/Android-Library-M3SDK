# Wakeup 제어 SDK (Deprecated)

>**참고:** 이 기능은 KeyTool V1.2.5 이상이면서 SL20P 에서만 사용 가능합니다.

## 개요

이 SDK는 외부 안드로이드 애플리케이션이 KeyToolSL20 애플리케이션과의 브로드캐스트 통신을 통해 특정 물리 키(좌/우 스캔 키)의 Wake-up 기능을 활성화 또는 비활성화할 수 있도록 합니다.

**경고: 이 기능은 더 이상 사용되지 않습니다 (Deprecated).**

이 리시버(`WakeupControlReceiver`)는 기존 고객사(DIXI)와의 하위 호환성을 유지하기 위해서만 존재합니다.

**신규 개발의 경우, 통합된 API인 `KeySettingReceiver`를 사용해야 합니다.** `KeySettingReceiver`는 Wake-up 기능 설정을 포함하여 모든 키에 대한 포괄적인 제어를 제공합니다. 자세한 내용은 `KEY_SETTING_SDK_KO.md` 문서를 참조하십시오.

### 빠른 시작

#### Java 예제

```java
// 왼쪽 스캔 키의 Wake-up 기능 활성화
Intent intent = new Intent("net.m3.keytool.WAKEUP_CONTROL_LEFT");
intent.putExtra("wakeup_enable", true);
context.sendBroadcast(intent);

// 오른쪽 스캔 키의 Wake-up 기능 비활성화
Intent intentRight = new Intent("net.m3.keytool.WAKEUP_CONTROL_RIGHT");
intentRight.putExtra("wakeup_enable", false);
context.sendBroadcast(intentRight);
```

#### Kotlin 예제

```kotlin
// 왼쪽 스캔 키의 Wake-up 기능 활성화
val intent = Intent("net.m3.keytool.WAKEUP_CONTROL_LEFT").apply {
    putExtra("wakeup_enable", true)
}
context.sendBroadcast(intent)

// 오른쪽 스캔 키의 Wake-up 기능 비활성화
val intentRight = Intent("net.m3.keytool.WAKEUP_CONTROL_RIGHT").apply {
    putExtra("wakeup_enable", false)
}
context.sendBroadcast(intentRight)
```

## API 참조

### 브로드캐스트 액션

| 액션                                    | 설명                        |
|---------------------------------------|---------------------------|
| `net.m3.keytool.WAKEUP_CONTROL_LEFT`  | 왼쪽 스캔 키의 Wake-up을 제어합니다.  |
| `net.m3.keytool.WAKEUP_CONTROL_RIGHT` | 오른쪽 스캔 키의 Wake-up을 제어합니다. |

### 파라미터

| 파라미터            | 타입      | 필수 여부 | 설명                                                     |
|-----------------|---------|-------|--------------------------------------------------------|
| `wakeup_enable` | boolean | 예     | `true`로 설정하면 Wake-up 기능이 활성화되고, `false`로 설정하면 비활성화됩니다. |

## ADB를 이용한 테스트

터미널에서 ADB(Android Debug Bridge) 명령어를 사용하여 Wake-up 설정 기능을 테스트할 수 있습니다.

### 왼쪽 스캔 키 Wake-up 활성화

```bash
adb shell am broadcast -a net.m3.keytool.WAKEUP_CONTROL_LEFT --ez wakeup_enable true
```

### 왼쪽 스캔 키 Wake-up 비활성화

```bash
adb shell am broadcast -a net.m3.keytool.WAKEUP_CONTROL_LEFT --ez wakeup_enable false
```

### 오른쪽 스캔 키 Wake-up 활성화

```bash
adb shell am broadcast -a net.m3.keytool.WAKEUP_CONTROL_RIGHT --ez wakeup_enable true
```

### 오른쪽 스캔 키 Wake-up 비활성화

```bash
adb shell am broadcast -a net.m3.keytool.WAKEUP_CONTROL_RIGHT --ez wakeup_enable false
```

## 제한 사항

- 이 SDK는 **SL20P 모델**에만 적용됩니다.
- 제어할 수 있는 키는 좌측 스캔(`LSCAN`) 및 우측 스캔(`RSCAN`) 키로 제한됩니다.
- 이 기능은 **Deprecated** 되었으므로 신규 개발에 사용하는 것을 권장하지 않습니다.
- 신규 개발 시에는 `KEY_SETTING_SDK_KO.md` 문서를 참고하여 `com.m3.keytoolsl20.ACTION_SET_KEY` 액션을 사용하십시오.
