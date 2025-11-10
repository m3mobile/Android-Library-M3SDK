
# Key Setting SDK

> **Note:** <br>
> This feature is available in KeyTool V1.2.6 or higher and only on SL20, SL20P, and SL20K.

## Overview

This SDK allows external Android applications to remap physical keys on KeyToolSL20 applications through broadcast communication. External apps can change the function assigned to any physical key and enable or disable wake-up functionality for that key.

### Quick Start

#### Basic Usage

```java
// Remap a physical key to a new function
Intent intent = new Intent("com.m3.keytoolsl20.ACTION_SET_KEY");
intent.putExtra("key_title", "Left Scan");  // Key to remap
intent.putExtra("key_function", "Scan");    // New function
intent.putExtra("key_wakeup", false);       // Wake-up enabled?

context.sendBroadcast(intent);
```

#### Control Wake-up Only

```java
// Enable wake-up for a key without changing function
Intent intent = new Intent("com.m3.keytoolsl20.ACTION_SET_KEY");
intent.putExtra("key_title", "Right Scan");
intent.putExtra("key_wakeup", true);

context.sendBroadcast(intent);
```

#### Change Function Only

```java
// Change key function without modifying wake-up settings
Intent intent = new Intent("com.m3.keytoolsl20.ACTION_SET_KEY");
intent.putExtra("key_title", "Left Scan");
intent.putExtra("key_function", "Scan");

context.sendBroadcast(intent);
```

#### Control Function and Wake-up Together

```java
// Remap a key and receive result
Intent intent = new Intent("com.m3.keytoolsl20.ACTION_SET_KEY");
intent.putExtra("key_title", "Left Scan");
intent.putExtra("key_function", "com.example.myapp");
intent.putExtra("key_wakeup", true);
intent.putExtra("key_setting_result_action", "com.example.myapp.KEY_SETTING_RESULT");

context.sendBroadcast(intent);
```

## API Reference

### Broadcast Action

**Action**: `com.m3.keytoolsl20.ACTION_SET_KEY`

### Parameters

| Parameter                   | Type    | Required | Description                                               |
|-----------------------------|---------|----------|-----------------------------------------------------------|
| `key_title`                 | String  | Yes      | Key name to remap (e.g., "Left Scan")                     |
| `key_function`              | String  | No       | New function assignment (e.g., "Scan", "com.example.app") |
| `key_wakeup`                | boolean | No       | Enable/disable wake-up for this key                       |
| `key_setting_result_action` | String  | No       | Custom action for result callback broadcast               |

**Important**: At least **one of** `key_function` or `key_wakeup` must be provided. (Both cannot be omitted)


## Supported Keys and Assignable Functions

The available keys and assignable functions vary depending on the device model.

### SL20, SL25

#### Supported Keys
- `"Left Scan"` - Left scan button
- `"Right Scan"` - Right scan button (if available)
- `"Volume Up"` - Volume up key
- `"Volume Down"` - Volume down key
- `"Back"` - Back button
- `"Home"` - Home button
- `"Recent"` - Recent apps button
- `"Camera"` - Camera button

#### Assignable Functions
- **System Functions**: `"Default"`, `"Disable"`, `"Scan"`, `"Volume up"`, `"Volume down"`, `"Back"`, `"Home"`, `"Menu"`, `"Camera"`
- **Special Functions**: `"★"`
- **Custom App**: Package name (e.g., `"com.example.myapp"`)

### SL20P

#### Supported Keys
- `"Left Scan"`, `"Right Scan"`, `"Volume Up"`, `"Volume Down"`, `"Back"`, `"Home"`, `"Recent"`, `"Camera"`

#### Assignable Functions
- **System Functions**: `"Default"`, `"Disable"`, `"Scan"`, `"Volume up"`, `"Volume down"`, `"Back"`, `"Home"`, `"Menu"`, `"Camera"`
- **Special Functions**: `"★"`
- **Custom App**: Package name (e.g., `"com.example.myapp"`)
- **Keyboard Input**:
    - **Function Keys**: `"F1"` to `"F12"`
    - **Navigation Keys**: `"↑"`, `"↓"`, `"←"`, `"→"`, `"Enter"`, `"Tab"`, `"Space"`, `"Del"`, `"ESC"`, `"Search"`
    - **Alphanumeric**: `"A"`-`"Z"`, `"a"`-`"z"`, `"0"`-`"9"`
    - **Special Characters**: `"`!`, `"@"`, `"#"` etc. (including `"£"`, `"€"`, `"¥"`, `"₩"`)

### SL20K

#### Supported Keys
- **Scan and Physical Buttons**: `"Left Scan"`, `"Right Scan"`, `"Volume Up"`, `"Volume Down"`, `"Back"`, `"Home"`, `"Recent"`, `"Camera"`, `"Front Scan"`
- **Navigation and Function Keys**: `"←"`, `"↑"`, `"↓"`, `"→"`, `"Enter"`, `"Esc"`, `"Tab"`, `"Shift"`, `"Delete"`, `"Alt"`, `"Ctrl"`, `"Fn"`
- **Function Keys**: `"F1"` to `"F8"`
- **Alphanumeric**: `"A"`-`"Z"`, `"0"`-`"9"`
- **Special Characters**: `"."`, `"★"`

#### Assignable Functions
- [Supports all functions available on SL20P](#assignable-functions-1).

### WD10

- Currently under development.

## Result Callbacks

If you provide the `key_setting_result_action` parameter, KeyToolSL20 will send a result broadcast:

**Action**: Custom action string you provided (e.g., `com.example.myapp.KEY_SETTING_RESULT`)

**Result Parameters**:

| Parameter                   | Type   | Description                                |
|-----------------------------|--------|--------------------------------------------|
| `key_setting_result_code`   | int    | Result code (0=success, positive=error)    |
| `key_setting_error_message` | String | Error description (only when error occurs) |

### Result Codes

| Code | Constant                                 | Description                     |
|------|------------------------------------------|---------------------------------|
| `0`  | `KEY_SETTING_RESULT_OK`                  | Key setting succeeded           |
| `1`  | `KEY_SETTING_RESULT_ERROR_INVALID_KEY`   | Key title not found             |
| `2`  | `KEY_SETTING_RESULT_ERROR_FILE_WRITE`    | Failed to save settings to file |
| `3`  | `KEY_SETTING_RESULT_ERROR_MISSING_PARAM` | Required parameters missing     |

## Complete Example

### Java Implementation

```java
public class KeySettingClient {
    private Context context;
    private BroadcastReceiver resultReceiver;

    public KeySettingClient(Context context) {
        this.context = context;
    }

    /**
     * Set key mapping with result callback
     */
    public void setKeyMapping(String keyTitle, String keyFunction, boolean enableWakeup) {
        if (keyTitle == null || keyTitle.isEmpty() || keyFunction == null || keyFunction.isEmpty()) {
            throw new IllegalArgumentException("Key title and function cannot be empty");
        }

        // Register result receiver
        registerResultReceiver();

        // Send key setting broadcast
        Intent intent = new Intent("com.m3.keytoolsl20.ACTION_SET_KEY");
        intent.putExtra("key_title", keyTitle);
        intent.putExtra("key_function", keyFunction);
        intent.putExtra("key_wakeup", enableWakeup);
        intent.putExtra("key_setting_result_action", "com.example.myapp.KEY_SETTING_RESULT");
        context.sendBroadcast(intent);

        android.util.Log.i("KeySettingClient", "Key mapping request sent: title=" + keyTitle + ", function=" + keyFunction);
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
                int resultCode = intent.getIntExtra("key_setting_result_code", -1);
                String errorMessage = intent.getStringExtra("key_setting_error_message");

                if (resultCode == 0) {  // KEY_SETTING_RESULT_OK
                    android.util.Log.i("KeySettingClient", "Key mapping changed successfully");
                    onKeyMappingSuccess();
                } else {
                    android.util.Log.e("KeySettingClient", "Key mapping change failed: " + errorMessage);
                    onKeyMappingFailed(errorMessage);
                }
            }
        };

        android.content.IntentFilter filter = new android.content.IntentFilter("com.example.myapp.KEY_SETTING_RESULT");
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
     * Override to handle success
     */
    protected void onKeyMappingSuccess() {
        // Handle success (e.g., show toast, update UI)
    }

    /**
     * Override to handle failure
     */
    protected void onKeyMappingFailed(String errorMessage) {
        // Handle failure (e.g., show error dialog)
    }
}
```

### Kotlin Implementation

```kotlin
class KeySettingClient(private val context: Context) {
    private var resultReceiver: BroadcastReceiver? = null

    /**
     * Set key mapping with result callback
     */
    fun setKeyMapping(keyTitle: String, keyFunction: String, enableWakeup: Boolean) {
        require(keyTitle.isNotEmpty()) { "Key title cannot be empty" }
        require(keyFunction.isNotEmpty()) { "Key function cannot be empty" }

        // Register result receiver
        registerResultReceiver()

        // Send key setting broadcast
        val intent = Intent("com.m3.keytoolsl20.ACTION_SET_KEY").apply {
            putExtra("key_title", keyTitle)
            putExtra("key_function", keyFunction)
            putExtra("key_wakeup", enableWakeup)
            putExtra("key_setting_result_action", "com.example.myapp.KEY_SETTING_RESULT")
        }
        context.sendBroadcast(intent)

        android.util.Log.i("KeySettingClient", "Key mapping request sent: title=$keyTitle, function=$keyFunction")
    }

    /**
     * Register broadcast receiver for result callback
     */
    private fun registerResultReceiver() {
        if (resultReceiver != null) {
            return // Already registered
        }

        resultReceiver = object : BroadcastReceiver() {
            override fun onReceive(context: Context?, intent: Intent?) {
                val resultCode = intent?.getIntExtra("key_setting_result_code", -1) ?: -1
                val errorMessage = intent?.getStringExtra("key_setting_error_message")

                if (resultCode == 0) {  // KEY_SETTING_RESULT_OK
                    android.util.Log.i("KeySettingClient", "Key mapping changed successfully")
                    onKeyMappingSuccess()
                } else {
                    android.util.Log.e("KeySettingClient", "Key mapping change failed: $errorMessage")
                    onKeyMappingFailed(errorMessage)
                }
            }
        }

        val filter = android.content.IntentFilter("com.example.myapp.KEY_SETTING_RESULT")
        context.registerReceiver(resultReceiver, filter)
    }

    /**
     * Unregister result receiver (call in onDestroy)
     */
    fun cleanup() {
        resultReceiver?.let {
            context.unregisterReceiver(it)
            resultReceiver = null
        }
    }

    /**
     * Override to handle success
     */
    protected open fun onKeyMappingSuccess() {
        // Handle success (e.g., show toast, update UI)
    }

    /**
     * Override to handle failure
     */
    protected open fun onKeyMappingFailed(errorMessage: String?) {
        // Handle failure (e.g., show error dialog)
    }
}
```

### Usage in Activity

```java
public class MainActivity extends AppCompatActivity {
    private KeySettingClient keySettingClient;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        keySettingClient = new KeySettingClient(this) {
            @Override
            protected void onKeyMappingSuccess() {
                android.widget.Toast.makeText(MainActivity.this,
                        "Key mapping changed successfully", android.widget.Toast.LENGTH_SHORT).show();
            }

            @Override
            protected void onKeyMappingFailed(String errorMessage) {
                android.widget.Toast.makeText(MainActivity.this,
                        "Failed: " + errorMessage, android.widget.Toast.LENGTH_LONG).show();
            }
        };

        // Example: Remap left scan key to camera function
        findViewById(R.id.btnRemapToCamera).setOnClickListener(v -> {
            keySettingClient.setKeyMapping("Left Scan", "Camera", false);
        });

        // Example: Remap left scan key to open custom app
        findViewById(R.id.btnRemapToApp).setOnClickListener(v -> {
            keySettingClient.setKeyMapping("Left Scan", "com.example.myapp", true);
        });

        // Example: Remap left scan key to F1
        findViewById(R.id.btnRemapToF1).setOnClickListener(v -> {
            keySettingClient.setKeyMapping("Left Scan", "F1", false);
        });
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        keySettingClient.cleanup();
    }
}
```

## Testing with ADB

You can test the key setting functionality using ADB (Android Debug Bridge) commands from the terminal.

### Control Wake-up Only

```bash
# Enable wake-up for left scan key
adb shell am broadcast -a com.m3.keytoolsl20.ACTION_SET_KEY --es key_title "'Left Scan'" --ez key_wakeup true

# Disable wake-up for right scan key
adb shell am broadcast -a com.m3.keytoolsl20.ACTION_SET_KEY --es key_title "'Right Scan'" --ez key_wakeup false
```

### Change Function Only

```bash
# Change left scan key function to Scan
adb shell am broadcast -a com.m3.keytoolsl20.ACTION_SET_KEY --es key_title "'Left Scan'" --es key_function "'Scan'"

# Change left scan key function to Volume up
adb shell am broadcast -a com.m3.keytoolsl20.ACTION_SET_KEY --es key_title "'Left Scan'" --es key_function "'Volume up'"

# Change multiple keys to different functions
adb shell am broadcast -a com.m3.keytoolsl20.ACTION_SET_KEY --es key_title "'Volume Up'" --es key_function "'Back'"
adb shell am broadcast -a com.m3.keytoolsl20.ACTION_SET_KEY --es key_title "'Volume Down'" --es key_function "'Disable'"
```

### Control Function and Wake-up Together

```bash
# Remap key to system function while setting wake-up
adb shell am broadcast -a com.m3.keytoolsl20.ACTION_SET_KEY --es key_title "'Left Scan'" --es key_function "'Volume up'" --ez key_wakeup true
adb shell am broadcast -a com.m3.keytoolsl20.ACTION_SET_KEY --es key_title "'Volume Up'" --es key_function "'Scan'" --ez key_wakeup false
adb shell am broadcast -a com.m3.keytoolsl20.ACTION_SET_KEY --es key_title "'Right Scan'" --es key_function "'Default'" --ez key_wakeup false
```

### Remap Key to Custom App

```bash
# Remap key to custom app without wake-up settings
adb shell am broadcast -a com.m3.keytoolsl20.ACTION_SET_KEY --es key_title "'Left Scan'" --es key_function "'com.example.myapplication'"

# Remap key to custom app with wake-up enabled
adb shell am broadcast -a com.m3.keytoolsl20.ACTION_SET_KEY --es key_title "'Left Scan'" --es key_function "'com.example.myapplication'" --ez key_wakeup true
```

### Remap Key to Keyboard Input

```bash
# Change key to keyboard function
adb shell am broadcast -a com.m3.keytoolsl20.ACTION_SET_KEY --es key_title "'Left Scan'" --es key_function "'F1'"

# Change key to keyboard function with wake-up disabled
adb shell am broadcast -a com.m3.keytoolsl20.ACTION_SET_KEY --es key_title "'Left Scan'" --es key_function "'F1'" --ez key_wakeup false
```

### Testing with Result Callback

```bash
# Monitor logcat for result
adb logcat | grep "KeySettingClient"

# Send key setting with custom result action
adb shell am broadcast -a com.m3.keytoolsl20.ACTION_SET_KEY --es key_title "'Left Scan'" --es key_function "'Scan'" --ez key_wakeup true --es key_setting_result_action "com.example.myapp.KEY_SETTING_RESULT"

# Control wake-up only with result callback
adb shell am broadcast -a com.m3.keytoolsl20.ACTION_SET_KEY --es key_title "'Right Scan'" --ez key_wakeup true --es key_setting_result_action "com.example.myapp.KEY_SETTING_RESULT"
```

### Testing Invalid Parameters (Error Cases)

```bash
# Invalid key name
adb shell am broadcast -a com.m3.keytoolsl20.ACTION_SET_KEY --es key_title "'InvalidKey'" --es key_function "'Scan'"

# Both parameters omitted (error - at least one required)
adb shell am broadcast -a com.m3.keytoolsl20.ACTION_SET_KEY --es key_title "'Left Scan'"

# key_title omitted (error - required parameter)
adb shell am broadcast -a com.m3.keytoolsl20.ACTION_SET_KEY --es key_function "'Scan'"
```

## Error Handling

### key_title Missing

**Error Message**: `"Required parameter is missing: key_title"`

**Result Code**: `KEY_SETTING_RESULT_ERROR_MISSING_PARAM` (3)

**Solution**: Always include the `key_title` parameter in the intent.

### Both key_function and key_wakeup Missing

**Error Message**: `"Both key_function and key_wakeup are missing. At least one is required."`

**Result Code**: `KEY_SETTING_RESULT_ERROR_MISSING_PARAM` (3)

**Solution**: Provide at least one of `key_function` or `key_wakeup` parameters.

### Invalid Key Title

**Error Message**: `"Key not found: InvalidKeyName"`

**Result Code**: `KEY_SETTING_RESULT_ERROR_INVALID_KEY` (1)

**Solution**: Use a valid key name from the supported keys list.

### File Write Failure

**Error Message**: `"Failed to save key settings: [error details]"`

**Result Code**: `KEY_SETTING_RESULT_ERROR_FILE_WRITE` (2)

**Solution**:
- Check device storage space
- Verify file system permissions
- Ensure KeyToolSL20 app has write access to configuration files

## Constants Reference

### Public Constants from KeySettingReceiver

```kotlin
// Broadcast action
const val ACTION_SET_KEY = "com.m3.keytoolsl20.ACTION_SET_KEY"

// Result codes
const val KEY_SETTING_RESULT_OK = 0
const val KEY_SETTING_RESULT_ERROR_INVALID_KEY = 1
const val KEY_SETTING_RESULT_ERROR_FILE_WRITE = 2
const val KEY_SETTING_RESULT_ERROR_MISSING_PARAM = 3

// Result message key
const val KEY_SETTING_EXTRA_ERROR_MESSAGE = "key_setting_error_message"
```
