#!/usr/bin/env bash
set -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DIR"

echo "=== Building Battery Care ==="

SDK_PATH="/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk"
BUILD_DIR="$DIR/build"
APP_BUNDLE="$BUILD_DIR/BatteryCare.app"
CONTENTS="$APP_BUNDLE/Contents"
MACOS="$CONTENTS/MacOS"
RESOURCES="$CONTENTS/Resources"

mkdir -p "$MACOS" "$RESOURCES" /tmp/clang-cache

SWIFT_SOURCES=(
    "Sources/Models/BatterySnapshot.swift"
    "Sources/Models/BatteryManager.swift"
    "Sources/Models/BluetoothDevice.swift"
    "Sources/Models/BluetoothManager.swift"
    "Sources/Models/ScreenGlowManager.swift"
    "Sources/Models/MenuBarBatteryRenderer.swift"
    "Sources/Models/SettingsManager.swift"
    "Sources/Models/NotificationManager.swift"
    "Sources/Views/LiquidBatteryGauge.swift"
    "Sources/Views/BatteryHealthCard.swift"
    "Sources/Views/BluetoothDevicesCard.swift"
    "Sources/Views/SettingsSheetView.swift"
    "Sources/Views/MainPopoverView.swift"
    "Sources/AppDelegate.swift"
    "Sources/main.swift"
)

echo "Compiling Swift sources..."
xcrun --sdk "$SDK_PATH" swiftc \
    -sdk "$SDK_PATH" \
    -target arm64-apple-macos14.0 \
    -swift-version 5 \
    -module-cache-path /tmp/clang-cache \
    -O \
    -framework Cocoa \
    -framework SwiftUI \
    -framework IOKit \
    -framework IOBluetooth \
    -framework UserNotifications \
    "${SWIFT_SOURCES[@]}" \
    -o "$MACOS/BatteryCare"

echo "Copying Info.plist..."
cp "Resources/Info.plist" "$CONTENTS/Info.plist"

echo "Signing bundle..."
codesign --force --deep --sign - "$APP_BUNDLE" 2>/dev/null || true

echo "=== Build Complete! ==="
echo "App created at: $APP_BUNDLE"
