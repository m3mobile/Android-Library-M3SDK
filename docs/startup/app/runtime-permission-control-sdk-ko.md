# 런타임 권한 제어 SDK

> **참고** <br>
> **지원 기기**: Android 6.0 (API 23) 이상
> StartUp 앱 버전 6.4.17 부터 지원합니다. 

## 개요

이 SDK는 외부 애플리케이션이 브로드캐스트 인텐트를 통해 다른 앱의 위험 권한(Dangerous Permissions)을 부여하거나 취소할 수 있도록 지원합니다. 
이 기능은 사용자 상호작용 없이 권한을 제어해야 하는 시나리오에서 유용합니다.



### 빠른 시작

#### 권한 부여

```kotlin
// 카메라 권한 부여
val intent = Intent("com.android.server.startupservice.system").apply {
    putExtra("setting", "permission")
    putExtra("package", "com.example.cameraapp")
    putExtra("permission", "android.permission.CAMERA")
    putExtra("permission_mode", 1)  // 허용
}
context.sendBroadcast(intent)
```

#### 권한 거부

```kotlin
// 카메라 권한 거부
val intent = Intent("com.android.server.startupservice.system").apply {
    putExtra("setting", "permission")
    putExtra("package", "com.example.cameraapp")
    putExtra("permission", "android.permission.CAMERA")
    putExtra("permission_mode", 2)  // 거부 (중요: 2를 사용해야 함)
}
context.sendBroadcast(intent)
```

### API 참조

#### 브로드캐스트 액션

**액션**: `com.android.server.startupservice.system`

#### 파라미터

| 파라미터              | 타입     | 필수 여부 | 설명                                   |
|-------------------|--------|-------|--------------------------------------|
| `setting`         | String | 예     | 설정 타입. 권한 제어의 경우 `"permission"` 값 사용 |
| `package`         | String | 예     | 대상 앱의 패키지명                           |
| `permission`      | String | 예     | 권한명 (예: `android.permission.CAMERA`) |
| `permission_mode` | int    | 예     | `1`=허용, `2`=거부                       |

**permission_mode 값 상세 설명**:
- **1 (GRANT)**: 권한 허용. 앱이 해당 권한을 사용할 수 있습니다.
- **2 (DENY)**: 권한 거부. 앱이 해당 권한을 사용할 수 없습니다.

#### 지원하는 위험 권한 목록

이 SDK는 **Android의 모든 위험 권한(Dangerous Permissions)**을 지원합니다. 주요 권한 목록:

- **카메라**: `android.permission.CAMERA`
- **위치**: `android.permission.ACCESS_FINE_LOCATION`, `android.permission.ACCESS_COARSE_LOCATION`
- **연락처**: `android.permission.READ_CONTACTS`, `android.permission.WRITE_CONTACTS`
- **전화**: `android.permission.CALL_PHONE`, `android.permission.READ_CALL_LOG`, `android.permission.WRITE_CALL_LOG`, `android.permission.READ_PHONE_STATE`
- **마이크**: `android.permission.RECORD_AUDIO`
- **파일/미디어** (Android 12 이하): `android.permission.READ_EXTERNAL_STORAGE`, `android.permission.WRITE_EXTERNAL_STORAGE`
- **미디어** (Android 13+): `android.permission.READ_MEDIA_IMAGES`, `android.permission.READ_MEDIA_VIDEO`, `android.permission.READ_MEDIA_AUDIO`
- **달력**: `android.permission.READ_CALENDAR`, `android.permission.WRITE_CALENDAR`
- **문자/SMS**: `android.permission.READ_SMS`, `android.permission.SEND_SMS`
- **센서**: `android.permission.BODY_SENSORS`
- **알림** (Android 13+): `android.permission.POST_NOTIFICATIONS`
- **기타**: `android.permission.ACCESS_MEDIA_LOCATION`

#### 제약사항

다음과 같은 경우 권한 제어가 **불가능**합니다:

1. **앱이 권한을 선언하지 않은 경우**: 대상 앱의 AndroidManifest.xml에 해당 권한이 선언되어 있어야 합니다.
2. **시스템 고정 권한**: `SYSTEM_FIXED` 또는 `POLICY_FIXED` 플래그가 설정된 권한은 변경할 수 없습니다.
   - 예: 시스템 카메라 앱의 CAMERA 권한, 기본 전화 앱의 CALL_PHONE 권한
3. **설치 시 권한**: 일반 권한(Normal Permissions)은 런타임 제어 대상이 아닙니다.

**권한 플래그 확인 방법**:
```bash
adb shell dumpsys package [패키지명] | findstr "[권한명]"
```

출력 예시:
```
android.permission.CAMERA: granted=true, flags=[ SYSTEM_FIXED|GRANTED_BY_DEFAULT ]
```
위 경우 `SYSTEM_FIXED` 플래그로 인해 제어가 불가능합니다.

### 전체 예제

#### 권한 부여

**Kotlin 예시:**

```kotlin
// 카메라 권한 부여
val intent = Intent("com.android.server.startupservice.system").apply {
    putExtra("setting", "permission")
    putExtra("package", "com.example.cameraapp")
    putExtra("permission", "android.permission.CAMERA")
    putExtra("permission_mode", 1)  // 허용
}
context.sendBroadcast(intent)
```

**Java 예시:**

```java
// 카메라 권한 부여
Intent intent = new Intent("com.android.server.startupservice.system");
intent.putExtra("setting", "permission");
intent.putExtra("package", "com.example.cameraapp");
intent.putExtra("permission", "android.permission.CAMERA");
intent.putExtra("permission_mode", 1);  // 허용
context.sendBroadcast(intent);
```

#### 권한 거부

**Kotlin 예시:**

```kotlin
// 카메라 권한 거부
val intent = Intent("com.android.server.startupservice.system").apply {
    putExtra("setting", "permission")
    putExtra("package", "com.example.cameraapp")
    putExtra("permission", "android.permission.CAMERA")
    putExtra("permission_mode", 2)  // 거부 (중요: 2를 사용해야 함)
}
context.sendBroadcast(intent)
```

**Java 예시:**

```java
// 카메라 권한 거부
Intent intent = new Intent("com.android.server.startupservice.system");
intent.putExtra("setting", "permission");
intent.putExtra("package", "com.example.cameraapp");
intent.putExtra("permission", "android.permission.CAMERA");
intent.putExtra("permission_mode", 2);  // 거부 (중요: 2를 사용해야 함)
context.sendBroadcast(intent);
```

#### 배치 권한 제어

여러 권한을 동시에 제어하려면 각 권한에 대해 별도의 브로드캐스트를 전송합니다.

```kotlin
// 여러 권한을 한 번에 부여
fun grantMultiplePermissions(
    context: Context,
    packageName: String,
    permissions: List<String>
) {
    permissions.forEach { permission ->
        val intent = Intent("com.android.server.startupservice.system").apply {
            putExtra("setting", "permission")
            putExtra("package", packageName)
            putExtra("permission", permission)
            putExtra("permission_mode", 1)  // 허용
        }
        context.sendBroadcast(intent)
    }
}

// 사용 예시
grantMultiplePermissions(
    context,
    "com.example.app",
    listOf(
        "android.permission.CAMERA",
        "android.permission.RECORD_AUDIO",
        "android.permission.ACCESS_FINE_LOCATION"
    )
)
```

### ADB를 사용한 테스트

#### 권한 부여

```bash
# Youtube 에 마이크 사용 권한 부여
adb shell am broadcast -a com.android.server.startupservice.system --es setting "permission" --es package "com.google.android.youtube" --es permission "android.permission.RECORD_AUDIO" --ei permission_mode 1  
```

#### 권한 거부

```bash
# Youtube 에 마이크 사용 권한 거부
adb shell am broadcast -a com.android.server.startupservice.system --es setting "permission" --es package "com.google.android.youtube" --es permission "android.permission.RECORD_AUDIO" --ei permission_mode 2
```

#### 권한 상태 확인

```bash
# 특정 권한 상태 확인 (Windows)
adb shell dumpsys package com.google.android.youtube | findstr "RECORD_AUDIO"

# 출력 예시:
# android.permission.RECORD_AUDIO: granted=true, flags=[ POLICY_FIXED|USER_SENSITIVE_WHEN_GRANTED ]
```

```bash
# 모든 런타임 권한 확인 (Windows)
adb shell dumpsys package com.google.android.youtube | findstr "granted"

```

### 문제 해결

#### 권한 변경이 적용되지 않는 경우

**1. 앱이 권한을 선언했는지 확인**

```bash
# Windows에서 권한 확인
adb shell dumpsys package com.example.app | findstr "android.permission.CAMERA"

# 출력이 없으면 앱이 해당 권한을 선언하지 않은 것
```

**2. 권한 플래그 확인**

```bash
adb shell dumpsys package com.example.app | findstr "CAMERA"

# 출력 예시:
# android.permission.CAMERA: granted=true, flags=[ SYSTEM_FIXED|GRANTED_BY_DEFAULT ]
```

- `SYSTEM_FIXED` 또는 `POLICY_FIXED` 플래그가 있으면 제어 불가
- 시스템 앱이나 기본 앱의 핵심 권한에 주로 설정됨

**3. permission_mode 값이 올바른지 확인**

```bash
# 잘못된 예 (거부하려는데 0 사용)
--ei permission_mode 0  # 기본값으로 복원 (거부가 아님!)

# 올바른 예 (거부)
--ei permission_mode 2  # 명시적 거부
```

**4. 시스템 권한 목록 확인**

```bash
# 모든 위험 권한 그룹 확인
adb shell pm list permissions -g -d

# 특정 앱이 요청하는 권한 확인
adb shell dumpsys package com.example.app | findstr "requested permissions"
```

#### 일반적인 오류 상황

| 증상                               | 원인                                  | 해결 방법                       |
|----------------------------------|-------------------------------------|-----------------------------|
| 로그에 `result: true`인데 권한이 변경되지 않음 | `permission_mode=0` 사용 (기본값 복원)     | `permission_mode=2` 사용 (거부) |
| 권한이 앱 권한 목록에 없음                  | 앱이 AndroidManifest.xml에 권한을 선언하지 않음 | 권한을 선언한 다른 앱으로 테스트          |
| `SYSTEM_FIXED` 플래그               | 시스템 앱의 핵심 권한                        | 제어 불가, 다른 앱으로 테스트           |
| 권한은 변경되는데 앱 동작이 안 바뀜             | 앱이 권한 캐시를 사용                        | 앱 강제 종료 후 재시작               |
