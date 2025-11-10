# Airplane Mode Control SDK

> **Note** <br>
> This feature is supported from StartUp version 5.3.4 and above.

## Overview

This SDK allows external Android applications to turn the device's Airplane Mode on or off through broadcast communication with the StartUp app.

### Quick Start

#### Basic Usage

```java
// Enable Airplane Mode
Intent intent = new Intent("com.android.server.startupservice.system");
intent.putExtra("setting", "airplane");
intent.putExtra("airplane", true); // true: on, false: off
context.sendBroadcast(intent);
```

### API Reference

#### Broadcast Action

**Action**: `com.android.server.startupservice.system`

#### Parameters

| Parameter  | Type    | Required | Description                                                |
|------------|---------|----------|------------------------------------------------------------|
| `setting`  | String  | Yes      | Setting type. Use `"airplane"` for Airplane Mode control.  |
| `airplane` | boolean | Yes      | Airplane Mode state. `true` to enable, `false` to disable. |

### Important Notes

#### 1. Immediate Effect

This setting is applied to the system as soon as the broadcast is sent.

### Full Example

#### Client App Implementation

```java
public class AirplaneModeController {
    private Context context;

    public AirplaneModeController(Context context) {
        this.context = context;
    }

    /**
     * Sets the state of Airplane Mode.
     * @param enable true to enable, false to disable.
     */
    public void setAirplaneMode(boolean enable) {
        // Send Airplane Mode setting broadcast
        Intent intent = new Intent("com.android.server.startupservice.system");
        intent.putExtra("setting", "airplane");
        intent.putExtra("airplane", enable);
        context.sendBroadcast(intent);

        Log.i("AirplaneModeController", "Airplane Mode setting sent: " + enable);
    }
}
```

#### Usage in Activity

```java
public class MainActivity extends AppCompatActivity {
    private AirplaneModeController airplaneModeController;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        airplaneModeController = new AirplaneModeController(this);

        // Example: Turn Airplane Mode On
        findViewById(R.id.btnAirplaneOn).setOnClickListener(v -> {
            airplaneModeController.setAirplaneMode(true);
            Toast.makeText(this, "Airplane Mode ON", Toast.LENGTH_SHORT).show();
        });

        // Example: Turn Airplane Mode Off
        findViewById(R.id.btnAirplaneOff).setOnClickListener(v -> {
            airplaneModeController.setAirplaneMode(false);
            Toast.makeText(this, "Airplane Mode OFF", Toast.LENGTH_SHORT).show();
        });
    }
}
```

### Testing with ADB

You can test the Airplane Mode setting feature from the terminal using ADB (Android Debug Bridge) commands.

#### Turn Airplane Mode On

```bash
adb shell am broadcast -a com.android.server.startupservice.system --es setting "airplane" --ez airplane true
```

#### Turn Airplane Mode Off

```bash
adb shell am broadcast -a com.android.server.startupservice.system --es setting "airplane" --ez airplane false
```

#### Verify Setting

The Airplane Mode status can be visually confirmed via the device's status bar or Settings menu. Alternatively, you can check the system setting with the following command:

```bash
# '1' means on, '0' means off.
adb shell settings get global airplane_mode_on
```
