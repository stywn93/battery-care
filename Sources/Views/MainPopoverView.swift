import SwiftUI

public struct MainPopoverView: View {
    @ObservedObject var batteryManager: BatteryManager
    @ObservedObject var bluetoothManager: BluetoothManager
    @ObservedObject var settings: SettingsManager
    
    public init(
        batteryManager: BatteryManager = .shared,
        bluetoothManager: BluetoothManager = .shared,
        settings: SettingsManager = .shared
    ) {
        self.batteryManager = batteryManager
        self.bluetoothManager = bluetoothManager
        self.settings = settings
    }
    
    public var body: some View {
        Group {
            if settings.showingSettings {
                SettingsSheetView(settings: settings)
            } else {
                dashboardView
            }
        }
        .padding(16)
        .frame(width: 350)
    }
    
    private var dashboardView: some View {
        VStack(spacing: 14) {
            // Header Bar
            HStack(spacing: 8) {
                HStack(spacing: 6) {
                    Image(systemName: "bolt.batteryblock.fill")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.green)
                    
                    Text("Battery Care")
                        .font(.system(size: 15, weight: .heavy, design: .rounded))
                    
                    Text("PRO")
                        .font(.system(size: 9, weight: .bold))
                        .padding(.horizontal, 5)
                        .padding(.vertical, 2)
                        .background(Color.green.opacity(0.18))
                        .foregroundColor(.green)
                        .cornerRadius(6)
                }
                
                Spacer()
                
                // Action Buttons with generous 30x30 clickable hit areas
                HStack(spacing: 6) {
                    PopoverHeaderButton(icon: "arrow.clockwise", help: "Refresh now") {
                        batteryManager.refresh()
                        bluetoothManager.refresh()
                    }
                    
                    PopoverHeaderButton(icon: "gearshape.fill", help: "Settings") {
                        withAnimation(.easeInOut(duration: 0.18)) {
                            settings.showingSettings = true
                        }
                    }
                    
                    PopoverHeaderButton(icon: "power", help: "Quit Battery Care") {
                        NSApplication.shared.terminate(nil)
                    }
                }
            }
            .padding(.horizontal, 2)
            
            // 1. Hero Liquid Battery Tank
            LiquidBatteryGauge(
                percentage: batteryManager.snapshot.percentage,
                isCharging: batteryManager.snapshot.isCharging,
                isPluggedIn: batteryManager.snapshot.isPluggedIn,
                isFullyCharged: batteryManager.snapshot.isFullyCharged,
                liveWatts: batteryManager.snapshot.liveWatts,
                chargerWatts: batteryManager.snapshot.chargerWattage,
                timeRemainingText: batteryManager.snapshot.timeFormatted
            )
            
            // 2. Health & Hardware Specs
            BatteryHealthCard(snapshot: batteryManager.snapshot)
            
            // 3. Bluetooth Connected Accessories
            BluetoothDevicesCard(devices: bluetoothManager.devices)
        }
    }
}

// Generous 30x30 clickable hit area with hover response
struct PopoverHeaderButton: View {
    let icon: String
    let help: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: 7)
                    .fill(Color.primary.opacity(0.06))
                
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(icon == "power" ? .red : .primary.opacity(0.85))
            }
            .frame(width: 28, height: 28)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .help(help)
    }
}
