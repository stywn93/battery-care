import SwiftUI

public struct SettingsSheetView: View {
    @ObservedObject var settings: SettingsManager
    
    public init(settings: SettingsManager) {
        self.settings = settings
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header with Back Button
            HStack {
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.18)) {
                        settings.showingSettings = false
                    }
                }) {
                    HStack(spacing: 5) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 12, weight: .bold))
                        Text("Back")
                            .font(.system(size: 13, weight: .semibold))
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.primary.opacity(0.08))
                    .cornerRadius(8)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                
                Spacer()
                
                Text("Settings")
                    .font(.system(size: 15, weight: .bold))
                
                Spacer()
                
                // Balance spacer
                Color.clear
                    .frame(width: 60, height: 20)
            }
            
            Divider()
            
            // Menu Bar Display Options
            VStack(alignment: .leading, spacing: 8) {
                Text("MENU BAR DISPLAY")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.secondary)
                
                Toggle("Show Live Wattage next to Icon", isOn: $settings.showWattageInMenuBar)
                Toggle("Show Time Remaining next to Icon", isOn: $settings.showTimeRemainingInMenuBar)
            }
            .toggleStyle(.switch)
            
            Divider()
            
            // Alerts & Audio Options
            VStack(alignment: .leading, spacing: 8) {
                Text("NOTIFICATIONS & AUDIO")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.secondary)
                
                Toggle("Enable Sound Effects (Plug / Unplug / Alerts)", isOn: $settings.enableSoundEffects)
                Toggle("Screen Glow Overlay (Juicy Alert Glow)", isOn: $settings.enableScreenGlow)
                Toggle("Alert on 80% Charge (Battery Longevity)", isOn: $settings.notifyOn80Percent)
                Toggle("Alert on 100% Full Charge", isOn: $settings.notifyOnFullCharge)
                Toggle("Alert on Low Battery", isOn: $settings.notifyOnLowBattery)
                
                if settings.notifyOnLowBattery {
                    HStack {
                        Text("Low Battery Threshold:")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                        Spacer()
                        Picker("", selection: $settings.lowBatteryThreshold) {
                            Text("10%").tag(10)
                            Text("15%").tag(15)
                            Text("20%").tag(20)
                            Text("25%").tag(25)
                        }
                        .pickerStyle(.segmented)
                        .frame(width: 160)
                    }
                    .padding(.leading, 10)
                }
            }
            .toggleStyle(.switch)
            
            Divider()
            
            // Test Alerts Section
            VStack(alignment: .leading, spacing: 8) {
                Text("TEST NOTIFICATIONS & AUDIO")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.secondary)
                
                HStack(spacing: 8) {
                    Button(action: {
                        NotificationManager.shared.testLowBatteryAlert(percentage: settings.lowBatteryThreshold)
                    }) {
                        Label("Low Batt", systemImage: "battery.25")
                            .font(.system(size: 11, weight: .medium))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.primary.opacity(0.06))
                            .cornerRadius(6)
                    }
                    .buttonStyle(.plain)
                    
                    Button(action: {
                        NotificationManager.shared.test80PercentAlert()
                    }) {
                        Label("80%", systemImage: "bolt.fill")
                            .font(.system(size: 11, weight: .medium))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.primary.opacity(0.06))
                            .cornerRadius(6)
                    }
                    .buttonStyle(.plain)
                    
                    Button(action: {
                        NotificationManager.shared.testFullChargeAlert()
                    }) {
                        Label("100%", systemImage: "battery.100")
                            .font(.system(size: 11, weight: .medium))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.primary.opacity(0.06))
                            .cornerRadius(6)
                    }
                    .buttonStyle(.plain)
                }
            }
            
            Divider()
            
            // macOS System Battery Settings & Quit App
            HStack {
                Button(action: {
                    if let url = URL(string: "x-apple.systempreferences:com.apple.Battery-Settings.extension") {
                        NSWorkspace.shared.open(url)
                    }
                }) {
                    Label("macOS Settings", systemImage: "macwindow")
                        .font(.system(size: 11, weight: .medium))
                }
                .buttonStyle(.plain)
                
                Spacer()
                
                Button(action: {
                    NSApplication.shared.terminate(nil)
                }) {
                    Text("Quit App")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.red)
                }
                .buttonStyle(.plain)
            }
        }
    }
}
