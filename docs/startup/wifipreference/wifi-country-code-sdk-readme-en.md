# Wi-Fi Country Code SDK

> Supported from StartUp version 6.0.6 BETA.
>
> SM15, SL10, and SL10K devices are not supported.

## Overview

This SDK allows external Android applications to set the device's Wi-Fi country code via broadcast communication with the StartUp app.

The Wi-Fi country code is a critical setting that ensures the device complies with the wireless regulations of the region where it is operating. Each country has different rules regarding permissible Wi-Fi channels and transmission power, making the correct country code essential.

### Quick Start

> [!WARNING]
> Supported from StartUp version 6.0.6 BETA.
> 
> SL10 and SL10K devices are not supported.

#### Basic Usage

```java
// Set the Wi-Fi country code to South Korea ('KR')
Intent intent = new Intent("com.android.server.startupservice.config");
intent.putExtra("setting", "wifi_country_code");
intent.putExtra("value", "KR");
context.sendBroadcast(intent);

// Set the Wi-Fi country code to the United States ('US')
Intent intentUS = new Intent("com.android.server.startupservice.config");
intentUS.putExtra("setting", "wifi_country_code");
intentUS.putExtra("value", "US");
context.sendBroadcast(intentUS);
```

### API Reference

#### Broadcast Action

**Action**: `com.android.server.startupservice.config`

#### Parameters

| Parameter | Type   | Required | Description                                               |
|-----------|--------|----------|-----------------------------------------------------------|
| `setting` | String | Yes      | Must be set to `"wifi_country_code"`.                     |
| `value`   | String | Yes      | An ISO 3166-1 alpha-2 two-letter country code (e.g., "KR", "US", "JP"). |

---

### Detailed Configuration Guide

#### Wi-Fi Country Code

Sets the Wi-Fi country code to comply with the regulations of the operating region.

-   **`setting` value**: `"wifi_country_code"`
-   **`value` type**: `String`
-   **`value` description**: An ISO 3166-1 alpha-2 two-letter country code.

#### Example Country Codes

| Code | Country       | Description                               |
|------|---------------|-------------------------------------------|
| `KR` | South Korea   | Complies with South Korean Wi-Fi regulations. |
| `US` | United States | Complies with US Wi-Fi regulations.       |
| `JP` | Japan         | Complies with Japanese Wi-Fi regulations.   |
| `CN` | China         | Complies with Chinese Wi-Fi regulations.    |
| `EU` | European Union| Generic code for EU compliance.           |
| `GB` | United Kingdom| Complies with UK Wi-Fi regulations.         |
| `AU` | Australia     | Complies with Australian Wi-Fi regulations. |
| `CA` | Canada        | Complies with Canadian Wi-Fi regulations.   |

**Note**: For a complete list of ISO 3166-1 country codes, refer to the [official ISO website](https://www.iso.org/iso-3166-country-codes.html).

---

### Full Example

#### Client App Implementation

```java
import android.content.Context;
import android.content.Intent;
import android.util.Log;
import java.util.Locale;

public class WifiCountryCodeController {
    private Context context;

    public WifiCountryCodeController(Context context) {
        this.context = context;
    }

    /**
     * Sets the Wi-Fi country code.
     *
     * @param countryCode An ISO 3166-1 alpha-2 country code (e.g., "KR", "US").
     */
    public void setCountryCode(String countryCode) {
        if (!isValidCountryCode(countryCode)) {
            Log.e("WifiCountryCodeController", "Invalid country code: " + countryCode);
            return;
        }

        String upperCountryCode = countryCode.toUpperCase();

        Intent intent = new Intent("com.android.server.startupservice.config");
        intent.putExtra("setting", "wifi_country_code");
        intent.putExtra("value", upperCountryCode);
        context.sendBroadcast(intent);

        Log.i("WifiCountryCodeController", "Wi-Fi country code set to: " + upperCountryCode);
    }

    /**
     * Validates if the country code is a two-letter ISO 3166-1 format.
     */
    private boolean isValidCountryCode(String countryCode) {
        if (countryCode == null || countryCode.isEmpty()) {
            return false;
        }
        return countryCode.length() == 2 && countryCode.matches("[a-zA-Z]{2}");
    }

    /**
     * Retrieves the current system country code.
     */
    public String getSystemCountryCode() {
        return Locale.getDefault().getCountry();
    }
}
```

---

### Testing with ADB

#### Set Wi-Fi Country Code

```bash
# Set country code to South Korea
adb shell am broadcast -a com.android.server.startupservice.config --es setting "wifi_country_code" --es value "KR"
```

```bash
# Set country code to the United States
adb shell am broadcast -a com.android.server.startupservice.config --es setting "wifi_country_code" --es value "US"
```

---

### Important Notes

1.  **Valid Country Codes**: Only use ISO 3166-1 alpha-2 two-letter country codes.
2.  **Case Insensitive**: Country codes are typically uppercase, but the SDK handles conversion automatically.
3.  **Legal Compliance**: You are responsible for setting the correct country code for the region where the device is operating to comply with local laws.
4.  **Restart May Be Required**: On some devices, a Wi-Fi toggle (off/on) or a full device restart may be necessary for the changes to take full effect.
