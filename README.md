# 🔋 Battery Care

A native, lightweight, and expressive macOS menu bar battery utility inspired by **Juicy Battery** — built completely with native **Swift & SwiftUI**, with **no license keys, no telemetry, and no paywalls**.

---

## ✨ Features

- **⚡️ Expressive Menu Bar Status Item**:
  - Dynamic battery icon reflecting actual charge level and charging bolt.
  - Live percentage (`100%`, `80%`, etc.).
  - Live power draw / wattage (`+65W` input when charging, `-12W` when on battery) — toggleable.
  - Estimated time remaining (`1h 45m` or `Charged`).
- **🌊 Liquid Battery Tank**:
  - Rounded battery visualizer with fluid gradient fill and glossy highlight.
  - Color dynamically shifts from fresh emerald green to warm amber and alert red.
- **❤️ Battery Health & Longevity Diagnostics**:
  - Maximum Capacity % (Health percentage = Full Charge / Design Capacity).
  - Cycle count tracking with Apple service thresholds.
  - Battery condition badge (`Normal`, `Fair`, `Service Recommended`).
  - Hardware specs: Voltage (V), Amperage (mA), Current & Design Capacity (mAh), and connected Charger Wattage (e.g. 65W USB-C PD).
- **🎧 Connected Bluetooth Accessories**:
  - Automatically lists paired and connected Bluetooth audio devices, keyboards, mice, and AirPods.
  - Shows connected status and accessory battery levels.
- **🔔 Smart Battery Alerts & Audio**:
  - Audio cues on charger connect (`Hero`) and disconnect (`Pop`).
  - **80% Charge Alert**: Alerts you when battery reaches 80% to help prolong battery lifespan.
  - **100% Full Charge Alert**: Notifies when charging is complete.
  - **Low Battery Alert**: Customizable threshold (10%, 15%, 20%, 25%).
- **🚀 Ultra Lightweight**:
  - Single native Apple Silicon Mach-O binary (~570 KB).
  - Zero heavy third-party frameworks.
  - Pure IOKit & IOBluetooth system APIs for minimal battery impact (<0.1% CPU).

---

## 🛠️ Building & Running

### Requirements
- macOS 14.0 or higher (Sonoma / Sequoia)
- Apple Silicon (M1/M2/M3/M4) or Intel Mac
- Command Line Tools or Xcode

### Quick Start
```bash
# Clone or navigate to the repository
cd /Users/macbokprom12021/PycharmProjects/rea/juicy

# Build the app bundle
make build

# Run the app
make run

# Optional: Install to /Applications
make install
```

### 🔔 Testing Notifications
1. **Via UI**: Klik ikon JuicyBar di menu bar → klik ikon gir (⚙️) → klik **"Test Low Battery"** pada section **TEST NOTIFICATIONS & AUDIO**.
2. **Via Terminal**:
```bash
make test-notify
```

---

## 📁 Project Structure

```
juicy/
├── Makefile                     # Build & run automation
├── build.sh                     # Build script (swiftc + codesign)
├── Resources/
│   └── Info.plist               # App metadata (LSUIElement: true)
└── Sources/
    ├── main.swift               # NSApplication entrypoint
    ├── AppDelegate.swift        # NSStatusItem & NSPopover lifecycle
    ├── Models/
    │   ├── BatterySnapshot.swift      # Immutable battery metrics
    │   ├── BatteryManager.swift       # IOKit & IOPS reader
    │   ├── BluetoothDevice.swift      # Accessory data model
    │   ├── BluetoothManager.swift     # IOBluetooth device scanner
    │   ├── SettingsManager.swift      # User preferences (UserDefaults)
    │   └── NotificationManager.swift  # Audio & UserNotification engine
    └── Views/
        ├── MainPopoverView.swift      # Popover flyout container
        ├── LiquidBatteryGauge.swift   # Animated liquid battery tank
        ├── BatteryHealthCard.swift    # Health & hardware statistics
        ├── BluetoothDevicesCard.swift # Bluetooth accessories section
        └── SettingsSheetView.swift    # Preferences modal
```

---

## 📄 License
MIT License. Free and open source.
