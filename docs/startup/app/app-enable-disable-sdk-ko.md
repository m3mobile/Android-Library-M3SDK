# 앱 활성화/비활성화 SDK

> **참고** <br>
> 
> StartUp 6.2.21 버전부터 지원됩니다. 

## 개요

이 SDK는 외부 애플리케이션이 브로드캐스트 인텐트를 통해 설치된 앱을 활성화하거나 비활성화할 수 있도록 지원합니다. 
비활성화된 앱은 실행할 수 없으며 시스템 리소스를 사용하지 않습니다.

### 빠른 시작

#### 앱 활성화

```kotlin
// 앱 활성화
val intent = Intent("com.android.server.startupservice.system").apply {
    putExtra("setting", "application")
    putExtra("package_name", "com.google.android.gms")
    putExtra("enable", true)
}
context.sendBroadcast(intent)
```

#### 앱 비활성화

```kotlin
// 앱 비활성화
val intent = Intent("com.android.server.startupservice.system").apply {
    putExtra("setting", "application")
    putExtra("package_name", "com.example.unwantedapp")
    putExtra("enable", false)
}
context.sendBroadcast(intent)
```

### API 참조

#### 브로드캐스트 액션

**액션**: `com.android.server.startupservice.system`

#### 파라미터

| 파라미터           | 타입      | 필수 여부 | 설명                                   |
|----------------|---------|-------|--------------------------------------|
| `setting`      | String  | 예     | 설정 타입. 앱 제어의 경우 `"application"` 값 사용 |
| `package_name` | String  | 예     | 대상 앱의 패키지명 (예: `com.example.myapp`)  |
| `enable`       | boolean | 예     | `true`이면 활성화, `false`이면 비활성화         |

### 전체 예제

#### 앱 활성화

**Kotlin 예시:**

```kotlin
// 앱 활성화
val intent = Intent("com.android.server.startupservice.system").apply {
    putExtra("setting", "application")
    putExtra("package_name", "com.google.android.calculator")
    putExtra("enable", true)
}
context.sendBroadcast(intent)
```

**Java 예시:**

```java
// 앱 활성화
Intent intent = new Intent("com.android.server.startupservice.system");
intent.putExtra("setting", "application");
intent.putExtra("package_name", "com.google.android.calculator");
intent.putExtra("enable", true);
context.sendBroadcast(intent);
```

#### 앱 비활성화

**Kotlin 예시:**

```kotlin
// 앱 비활성화
val intent = Intent("com.android.server.startupservice.system").apply {
    putExtra("setting", "application")
    putExtra("package_name", "com.google.android.calculator")
    putExtra("enable", false)
}
context.sendBroadcast(intent)
```

**Java 예시:**

```java
// 앱 비활성화
Intent intent = new Intent("com.android.server.startupservice.system");
intent.putExtra("setting", "application");
intent.putExtra("package_name", "com.google.android.calculator");
intent.putExtra("enable", false);
context.sendBroadcast(intent);
```

### ADB를 사용한 테스트

#### 앱 활성화

```bash
# 앱 활성화
adb shell am broadcast -a com.android.server.startupservice.system --es setting "application" --es package_name "com.google.android.calculator" --ez enable true
```

#### 앱 비활성화

```bash
# 앱 비활성화
adb shell am broadcast -a com.android.server.startupservice.system --es setting "application" --es package_name "com.google.android.calculator" --ez enable false
```

### 주의사항

- 시스템 앱도 비활성화할 수 있으나, 시스템 안정성에 영향을 줄 수 있어 주의가 필요합니다.
- 비활성화된 앱은 백그라운드에서 실행되지 않으며 알림을 보내지 않습니다.
- 비활성화된 앱을 다시 활성화하려면 `enable: true`로 브로드캐스트를 다시 전송하면 됩니다.


### 문제 해결

앱 비활성화 후 문제가 발생하면 다음을 확인하십시오.

```bash
# 1. 비활성화된 앱 목록 확인
adb shell pm list packages -d

# 2. 앱 다시 활성화
adb shell pm enable com.example.app

# 3. 앱 강제 정지 후 활성화
adb shell am force-stop com.example.app
adb shell pm enable com.example.app
```

