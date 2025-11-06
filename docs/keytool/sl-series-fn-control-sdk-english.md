# FN Key Control SDK

>**참고:** 이 기능은 KeyTool V1.2.6 이상이면서 SL20K 기기에서 사용할 수 있습니다.

## Overview

This SDK allows external Android applications to control the FN key state on KeyToolSL20 applications through broadcast communication. The FN key can be disabled, enabled, or locked to suit different use cases.

### Quick Start

#### Basic Usage

```java
// Set FN key to enable state
Intent intent = new Intent("com.m3.keytoolsl20.ACTION_CONTROL_FN_STATE");
intent.putExtra("fn_state", 1);  // 0=disable, 1=enable, 2=lock

context.sendBroadcast(intent);
```

#### Using Result Callbacks

```java
// Send FN state change and receive result
Intent intent = new Intent("com.m3.keytoolsl20.ACTION_CONTROL_FN_STATE");
intent.putExtra("fn_state", 1);
intent.putExtra("fn_control_result_action", "com.example.myapp.FN_CONTROL_RESULT");

context.sendBroadcast(intent);
```

## API Reference

### Broadcast Action

**Action**: `com.m3.keytoolsl20.ACTION_CONTROL_FN_STATE`

### Parameters

| Parameter                  | Type    | Required | Description                                 |
|----------------------------|---------|----------|---------------------------------------------|
| `fn_state`                 | Integer | Yes      | FN state: 0=disable, 1=enable, 2=lock       |
| `fn_control_result_action` | String  | No       | Custom action for result callback broadcast |

## FN Key States

| State Value | Name      | Description        |
|-------------|-----------|--------------------|
| `0`         | `DISABLE` | FN key is disabled |
| `1`         | `ENABLE`  | FN key is enabled  |
| `2`         | `LOCK`    | FN key is locked   |

## Result Callbacks

If you provide the `fn_control_result_action` parameter, KeyToolSL20 will send a result broadcast:

**Action**: Custom action string you provided (e.g., `com.example.myapp.FN_CONTROL_RESULT`)

**Result Parameters**:

| Parameter                  | Type   | Description                                |
|----------------------------|--------|--------------------------------------------|
| `fn_control_result_code`   | int    | Result code (0=success, positive=error)    |
| `fn_control_error_message` | String | Error description (only when error occurs) |

### Result Codes

| Code | Constant                                      | Description                             |
|------|-----------------------------------------------|-----------------------------------------|
| `0`  | `FN_CONTROL_RESULT_OK`                        | FN state changed successfully           |
| `1`  | `FN_CONTROL_RESULT_ERROR_SERVICE_CALL`        | Error calling PlatformService           |
| `2`  | `FN_CONTROL_RESULT_ERROR_INVALID_STATE`       | Invalid FN state value (not 0, 1, or 2) |
| `3`  | `FN_CONTROL_RESULT_ERROR_SERVICE_BIND_FAILED` | Failed to bind to PlatformService       |
| `4`  | `FN_CONTROL_RESULT_ERROR_TIMEOUT`             | PlatformService connection timeout      |

## Complete Example

### Java Implementation

```java
public class FnControlClient {
    private Context context;
    private BroadcastReceiver resultReceiver;

    public FnControlClient(Context context) {
        this.context = context;
    }

    /**
     * Set FN state with result callback
     */
    public void setFnState(int state) {
        if (state < 0 || state > 2) {
            throw new IllegalArgumentException("FN state must be 0, 1, or 2");
        }

        // Register result receiver
        registerResultReceiver();

        // Send FN state setting broadcast
        Intent intent = new Intent("com.m3.keytoolsl20.ACTION_CONTROL_FN_STATE");
        intent.putExtra("fn_state", state);
        intent.putExtra("fn_control_result_action", "com.example.myapp.FN_CONTROL_RESULT");
        context.sendBroadcast(intent);

        String stateName = getStateName(state);
        android.util.Log.i("FnControlClient", "FN state change requested: state=" + stateName);
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
                int resultCode = intent.getIntExtra("fn_control_result_code", -1);
                String errorMessage = intent.getStringExtra("fn_control_error_message");

                if (resultCode == 0) {  // FN_CONTROL_RESULT_OK
                    android.util.Log.i("FnControlClient", "FN state changed successfully");
                    onFnStateSetSuccess();
                } else {
                    android.util.Log.e("FnControlClient", "FN state change failed: " + errorMessage);
                    onFnStateSetFailed(errorMessage);
                }
            }
        };

        android.content.IntentFilter filter = new android.content.IntentFilter("com.example.myapp.FN_CONTROL_RESULT");
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
    protected void onFnStateSetSuccess() {
        // Handle success (e.g., show toast, update UI)
    }

    /**
     * Override to handle failure
     */
    protected void onFnStateSetFailed(String errorMessage) {
        // Handle failure (e.g., show error dialog)
    }

    private String getStateName(int state) {
        switch (state) {
            case 0: return "DISABLE";
            case 1: return "ENABLE";
            case 2: return "LOCK";
            default: return "UNKNOWN";
        }
    }
}
```

### Kotlin Implementation

```kotlin
class FnControlClient(private val context: Context) {
    private var resultReceiver: BroadcastReceiver? = null

    /**
     * Set FN state with result callback
     */
    fun setFnState(state: Int) {
        require(state in 0..2) { "FN state must be 0, 1, or 2" }

        // Register result receiver
        registerResultReceiver()

        // Send FN state setting broadcast
        val intent = Intent("com.m3.keytoolsl20.ACTION_CONTROL_FN_STATE").apply {
            putExtra("fn_state", state)
            putExtra("fn_control_result_action", "com.example.myapp.FN_CONTROL_RESULT")
        }
        context.sendBroadcast(intent)

        val stateName = getStateName(state)
        android.util.Log.i("FnControlClient", "FN state change requested: state=$stateName")
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
                val resultCode = intent?.getIntExtra("fn_control_result_code", -1) ?: -1
                val errorMessage = intent?.getStringExtra("fn_control_error_message")

                if (resultCode == 0) {  // FN_CONTROL_RESULT_OK
                    android.util.Log.i("FnControlClient", "FN state changed successfully")
                    onFnStateSetSuccess()
                } else {
                    android.util.Log.e("FnControlClient", "FN state change failed: $errorMessage")
                    onFnStateSetFailed(errorMessage)
                }
            }
        }

        val filter = android.content.IntentFilter("com.example.myapp.FN_CONTROL_RESULT")
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
    protected open fun onFnStateSetSuccess() {
        // Handle success (e.g., show toast, update UI)
    }

    /**
     * Override to handle failure
     */
    protected open fun onFnStateSetFailed(errorMessage: String?) {
        // Handle failure (e.g., show error dialog)
    }

    private fun getStateName(state: Int): String = when (state) {
        0 -> "DISABLE"
        1 -> "ENABLE"
        2 -> "LOCK"
        else -> "UNKNOWN"
    }
}
```

### Usage in Activity

```java
public class MainActivity extends AppCompatActivity {
    private FnControlClient fnControlClient;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        fnControlClient = new FnControlClient(this) {
            @Override
            protected void onFnStateSetSuccess() {
                android.widget.Toast.makeText(MainActivity.this,
                        "FN key state changed successfully", android.widget.Toast.LENGTH_SHORT).show();
            }

            @Override
            protected void onFnStateSetFailed(String errorMessage) {
                android.widget.Toast.makeText(MainActivity.this,
                        "Failed: " + errorMessage, android.widget.Toast.LENGTH_LONG).show();
            }
        };

        // Example: Set FN key to enable
        findViewById(R.id.btnEnable).setOnClickListener(v -> {
            fnControlClient.setFnState(1);
        });

        // Example: Set FN key to disable
        findViewById(R.id.btnDisable).setOnClickListener(v -> {
            fnControlClient.setFnState(0);
        });

        // Example: Set FN key to lock
        findViewById(R.id.btnLock).setOnClickListener(v -> {
            fnControlClient.setFnState(2);
        });
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        fnControlClient.cleanup();
    }
}
```

## Testing with ADB

You can test the FN key control functionality using ADB (Android Debug Bridge) commands from the terminal.

### Set FN State to Enable

```bash
adb shell am broadcast -a com.m3.keytoolsl20.ACTION_CONTROL_FN_STATE --ei fn_state 1
```

### Set FN State to Disable

```bash
adb shell am broadcast -a com.m3.keytoolsl20.ACTION_CONTROL_FN_STATE --ei fn_state 0
```

### Set FN State to Lock

```bash
adb shell am broadcast -a com.m3.keytoolsl20.ACTION_CONTROL_FN_STATE --ei fn_state 2
```

### Testing with Result Callback

```bash
# Monitor logcat for results
adb logcat | grep "FnControlClient"

# In another terminal, send FN state change with custom result action
adb shell am broadcast -a com.m3.keytoolsl20.ACTION_CONTROL_FN_STATE \
    --ei fn_state 1 \
    --es fn_control_result_action "com.example.myapp.FN_CONTROL_RESULT"
```

### Testing Invalid State (Error Case)

```bash
adb shell am broadcast -a com.m3.keytoolsl20.ACTION_CONTROL_FN_STATE --ei fn_state 5
```

## Error Handling

### Invalid FN State Value

**Error Message**: `"Invalid FN state: 5. Must be 0, 1, or 2."`

**Result Code**: `FN_CONTROL_RESULT_ERROR_INVALID_STATE` (2)

**Solution**: Ensure you pass a valid FN state value (0, 1, or 2).

### Service Binding Failure

**Error Message**: `"Failed to bind to PlatformService"`

**Result Code**: `FN_CONTROL_RESULT_ERROR_SERVICE_BIND_FAILED` (3)

**Solution**:
- Verify KeyToolSL20 app is installed and running
- Check device has system privileges (sharedUserId)
- Verify no permission issues in manifest

### Service Call Error

**Error Message**: `"RemoteException: [error details]"`

**Result Code**: `FN_CONTROL_RESULT_ERROR_SERVICE_CALL` (1)

**Solution**: Check logcat for detailed error information and system status.

### Connection Timeout

**Error Message**: `"PlatformService connection timeout"`

**Result Code**: `FN_CONTROL_RESULT_ERROR_TIMEOUT` (4)

**Solution**:
- Ensure PlatformService is running
- Check device performance and system load
- Try the operation again after a delay

## Constants Reference

### Public Constants from FnControlReceiver

```kotlin
// Broadcast action
const val ACTION_CONTROL_FN_STATE = "com.m3.keytoolsl20.ACTION_CONTROL_FN_STATE"

// Result codes
const val FN_CONTROL_RESULT_OK = 0
const val FN_CONTROL_RESULT_CANCELED = -1
const val FN_CONTROL_RESULT_ERROR_SERVICE_CALL = 1
const val FN_CONTROL_RESULT_ERROR_INVALID_STATE = 2
const val FN_CONTROL_RESULT_ERROR_SERVICE_BIND_FAILED = 3
const val FN_CONTROL_RESULT_ERROR_TIMEOUT = 4

// Result message key
const val FN_CONTROL_EXTRA_ERROR_MESSAGE = "fn_control_error_message"
```
