# APK 설치 SDK

> **참고** <br> 
> 
> Startup 5.3.4 버전부터 지원합니다.

## 개요

이 SDK는 외부 애플리케이션이 브로드캐스트 인텐트를 통해 디바이스에 APK 파일을 설치할 수 있게 해주는 API입니다. 
로컬 파일 경로 또는 URL에서 APK를 다운로드하여 설치하는 두 가지 방식을 지원합니다.

### 빠른 시작

#### 기본 사용법 (로컬 파일)

```kotlin
// 로컬 파일에서 APK 설치
val intent = Intent("com.android.server.startupservice.system").apply {
    putExtra("setting", "apk_install")
    putExtra("type", 0)  // 로컬 파일
    putExtra("path", "/sdcard/downloads/myapp.apk")
}
context.sendBroadcast(intent)
```

#### 기본 사용법 (URL)

```kotlin
// URL에서 APK 다운로드 및 설치
val intent = Intent("com.android.server.startupservice.system").apply {
    putExtra("setting", "apk_install")
    putExtra("type", 1)  // URL 다운로드
    putExtra("url", "https://github.com/skydoves/pokedex-compose/releases/download/1.0.3/pokedex-compose.apk")
}
context.sendBroadcast(intent)
```

### API 참조

#### 브로드캐스트 액션

**액션**: `com.android.server.startupservice.system`

#### 파라미터

| 파라미터      | 타입     | 필수 여부          | 설명                                                                                                          |
|-----------|--------|----------------|-------------------------------------------------------------------------------------------------------------|
| `setting` | String | 필수             | 설정 타입. APK 설치의 경우 `"apk_install"` 값 사용                                                                      |
| `type`    | int    | 필수             | 설치 방식. `0`: 로컬 파일, `1`: URL 다운로드                                                                            |
| `path`    | String | `type=0`일 때 필수 | APK 파일의 절대 경로 (예: `/sdcard/downloads/myapp.apk`)                                                            |
| `url`     | String | `type=1`일 때 필수 | APK 다운로드 URL (예: `https://github.com/skydoves/pokedex-compose/releases/download/1.0.3/pokedex-compose.apk`) |

### 전체 예제

#### 로컬 파일 설치

**Kotlin 예시:**

```kotlin
// 로컬 파일에서 APK 설치
val intent = Intent("com.android.server.startupservice.system").apply {
    putExtra("setting", "apk_install")
    putExtra("type", 0)  // 로컬 파일
    putExtra("path", "/sdcard/downloads/myapp.apk")
}
context.sendBroadcast(intent)
```

**Java 예시:**
```java
// 로컬 파일에서 APK 설치
Intent intent = new Intent("com.android.server.startupservice.system");
intent.putExtra("setting", "apk_install");
intent.putExtra("type", 0);  // 로컬 파일
intent.putExtra("path", "/sdcard/downloads/myapp.apk");
context.sendBroadcast(intent);
```

#### URL에서 다운로드 및 설치

**Kotlin 예시:**

```kotlin
// URL에서 APK 다운로드 및 설치
val intent = Intent("com.android.server.startupservice.system").apply {
    putExtra("setting", "apk_install")
    putExtra("type", 1)  // URL 다운로드
    putExtra("url", "https://github.com/skydoves/pokedex-compose/releases/download/1.0.3/pokedex-compose.apk")
}
context.sendBroadcast(intent)
```

**Java 예시:**

```java
// URL에서 APK 다운로드 및 설치
Intent intent = new Intent("com.android.server.startupservice.system");
intent.putExtra("setting", "apk_install");
intent.putExtra("type", 1);  // URL 다운로드
intent.putExtra("url", "https://github.com/skydoves/pokedex-compose/releases/download/1.0.3/pokedex-compose.apk");
context.sendBroadcast(intent);
```

### ADB를 사용한 테스트

#### 로컬 파일 설치

```bash
# 로컬 파일에서 APK 설치
adb shell am broadcast -a com.android.server.startupservice.system --es setting "apk_install" --ei type 0 --es path "/sdcard/downloads/myapp.apk"
```

#### URL에서 다운로드 및 설치

```bash
# URL에서 APK 다운로드 및 설치
adb shell am broadcast -a com.android.server.startupservice.system --es setting "apk_install" --ei type 1 --es url "https://github.com/skydoves/pokedex-compose/releases/download/1.0.3/pokedex-compose.apk"
```

### 주의사항

- URL에서 다운로드 시, APK는 `/data/downloads/` 디렉토리에 저장됩니다.
- URL 설치는 네트워크 연결이 필요합니다.
- 다운로드 진행 상황은 브로드캐스트로 모니터링할 수 있습니다 (`android.app.DownloadManager.ACTION_DOWNLOAD_COMPLETE`).
- APK 설치 후 즉시 관련 앱을 활성화하거나 권한을 설정하려고 하면 타이밍 이슈가 발생할 수 있습니다. 설치 완료를 확인한 후 다음 작업을 진행해야 합니다.


### 문제 해결

APK 설치 실패 시 다음을 확인하십시오.

```bash
# 1. 로그 확인
adb logcat | grep -i "apk\|install"

# 2. 파일 존재 확인
adb shell ls -la /data/downloads/myapp.apk

# 3. 파일 권한 확인
adb shell stat /data/downloads/myapp.apk

# 4. APK 무결성 확인
adb shell md5sum /data/downloads/myapp.apk
```
