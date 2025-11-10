# USB Settings Control SDK

> **Note** <br>
> This feature is supported from StartUp version 6.5.10 onwards. <br>
> Supported on US20 (Android 10), US30 (Android 13) devices.

## Overview

This SDK allows external Android applications to control the device's USB mode settings through broadcast communication with the StartUp app.
It provides privileged access to system settings.

### Quick Start

#### Basic Usage

```java
// Set USB mode to "No data transfer"
Intent intent = new Intent("com.android.server.startupservice.system");
intent.putExtra("setting","usb_setting");
intent.putExtra("usb_mode","none");

context.sendBroadcast(intent);
```

#### Using Result Callback

```java
// Send USB setting and receive result
Intent intent = new Intent("com.android.server.startupservice.system");
intent.putExtra("setting","usb_setting");
intent.putExtra("usb_mode","mtp");
// The value for "usb_result_action" can be any custom string you want.
intent.putExtra("usb_result_action","com.example.myapp.USB_RESULT"); 

context.sendBroadcast(intent);
```

### API Reference

#### Broadcast Action

**Action**: `com.android.server.startupservice.system`

#### Parameters

| Parameter           | Type   | Required | Description                                        |
|---------------------|--------|----------|----------------------------------------------------|
| `setting`           | String | Yes      | Setting type. Use `"usb_setting"` for USB control. |
| `usb_mode`          | String | Yes      | USB mode: one of "mtp", "midi", "ptp", "none".     |
| `usb_result_action` | String | No       | Custom action for the result callback broadcast.   |

#### USB Modes

| Mode Value | Description            | Use Case                             |
|------------|------------------------|--------------------------------------|
| `mtp`      | File Transfer (MTP)    | File transfer (default file manager) |
| `rndis`    | USB tethering          | Share internet connection            |
| `midi`     | MIDI                   | Connect musical instruments          |
| `ptp`      | PTP (Picture Transfer) | Transfer photos                      |
| `none`     | No data transfer       | Charging only (no data transfer)     |

#### Result Callback

If you provide the `usb_result_action` parameter, the StartUp app will send a result broadcast:

**Action**: Custom action string (e.g., `com.example.myapp.USB_RESULT`)

**Result Parameters**:

| Parameter           | Type    | Description                                                 |
|---------------------|---------|-------------------------------------------------------------|
| `usb_success`       | boolean | `true` if the operation was successful, `false` otherwise.  |
| `usb_error_message` | String  | Error description (only present if `usb_success` is false). |

### Error Handling

#### Error Scenarios

1.  **Invalid USB Mode**
    ```
    Error: "Invalid USB mode: invalid_mode. Valid modes are: mtp, midi, ptp, none"
    ```
    **Solution**: Use a valid USB mode (mtp, midi, ptp, none).

2.  **Unsupported Android Version**
    ```
    Error: "USB mode control requires Android 10 or higher"
    ```
    **Solution**: Requires Android 10 (API 29) or higher.

3.  **System Error**
    ```
    Error: "Failed to apply USB setting: [system error details]"
    ```
    **Solution**: Check system permissions and device status.

### Full Example

#### Client App Implementation

```java
public class UsbController {
    private Context context;
    private BroadcastReceiver resultReceiver;

    public UsbController(Context context) {
        this.context = context;
    }

    /**
     * Set USB mode with result callback
     * @param usbMode "mtp", "midi", "ptp", or "none"
     */
    public void setUsbMode(String usbMode) {
        // Register result receiver
        registerResultReceiver();

        // Send USB setting broadcast
        Intent intent = new Intent("com.android.server.startupservice.system");
        intent.putExtra("setting", "usb_setting");
        intent.putExtra("usb_mode", usbMode);
        intent.putExtra("usb_result_action", "com.example.myapp.USB_RESULT");
        context.sendBroadcast(intent);

        Log.i("UsbController", "USB mode setting sent: " + usbMode);
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
                boolean success = intent.getBooleanExtra("usb_success", false);
                String errorMessage = intent.getStringExtra("usb_error_message");

                if (success) {
                    Log.i("UsbController", "USB mode applied successfully");
                    onUsbModeSetSuccess();
                } else {
                    Log.e("UsbController", "USB mode setting failed: " + errorMessage);
                    onUsbModeSetFailed(errorMessage);
                }
            }
        };

        IntentFilter filter = new IntentFilter("com.example.myapp.USB_RESULT");
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
     * Override this method to handle success
     */
    protected void onUsbModeSetSuccess() {
        // Handle success (e.g., show toast, update UI)
    }

    /**
     * Override this method to handle failure
     */
    protected void onUsbModeSetFailed(String errorMessage) {
        // Handle failure (e.g., show error dialog)
    }
}
```

#### Usage in Activity

```java
public class MainActivity extends AppCompatActivity {
    private UsbController usbController;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        usbController = new UsbController(this) {
            @Override
            protected void onUsbModeSetSuccess() {
                Toast.makeText(MainActivity.this,
                        "USB mode set successfully", Toast.LENGTH_SHORT).show();
            }

            @Override
            protected void onUsbModeSetFailed(String errorMessage) {
                Toast.makeText(MainActivity.this,
                        "Failed: " + errorMessage, Toast.LENGTH_LONG).show();
            }
        };

        // Example: Set USB mode to "No data transfer"
        findViewById(R.id.btnNoDataTransfer).setOnClickListener(v -> {
            usbController.setUsbMode("none");
        });

        // Example: Set USB mode to File Transfer (MTP)
        findViewById(R.id.btnFileTransfer).setOnClickListener(v -> {
            usbController.setUsbMode("mtp");
        });

        // Example: Set USB mode to MIDI
        findViewById(R.id.btnMidi).setOnClickListener(v -> {
            usbController.setUsbMode("midi");
        });

        // Example: Set USB mode to PTP
        findViewById(R.id.btnPtp).setOnClickListener(v -> {
            usbController.setUsbMode("ptp");
        });
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        usbController.cleanup();
    }
}
```

### Testing with ADB

You can test the USB mode control feature from the terminal using ADB (Android Debug Bridge) commands.

#### Set USB Mode (No data transfer)

```bash
adb shell am broadcast -a com.android.server.startupservice.system --es setting "usb_setting" --es usb_mode "none"
```

#### Set USB Mode (File Transfer - MTP)

```bash
adb shell am broadcast -a com.android.server.startupservice.system --es setting "usb_setting" --es usb_mode "mtp"
```

#### Set USB Mode (MIDI)

```bash
adb shell am broadcast -a com.android.server.startupservice.system --es setting "usb_setting" --es usb_mode "midi"
```

#### Set USB Mode (PTP)

```bash
adb shell am broadcast -a com.android.server.startupservice.system --es setting "usb_setting" --es usb_mode "ptp"
```

#### Test Result Callback

```bash
# First, monitor the result in logcat
adb logcat | Select-string "USB_RESULT"
# or adb logcat | grep "USB_RESULT" 

# In another terminal, send the broadcast with the result action
adb shell am broadcast -a com.android.server.startupservice.system --es setting "usb_setting" --es usb_mode "none" --es usb_result_action "com.test.USB_RESULT"
```
