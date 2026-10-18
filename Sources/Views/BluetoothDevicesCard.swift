import SwiftUI

public struct BluetoothDevicesCard: View {
    public let devices: [BluetoothDeviceInfo]
    
    public init(devices: [BluetoothDeviceInfo]) {
        self.devices = devices
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label("Connected Accessories", systemImage: "antenna.radiowaves.left.and.right")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.primary)
                Spacer()
                Text("\(connectedCount) Connected")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.secondary)
            }
            
            if devices.isEmpty {
                HStack {
                    Spacer()
                    Text("No Bluetooth devices paired")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .padding(.vertical, 8)
            } else {
                VStack(spacing: 6) {
                    ForEach(devices.prefix(4)) { dev in
                        HStack(spacing: 8) {
                            Image(systemName: dev.iconName)
                                .font(.system(size: 14))
                                .foregroundColor(dev.isConnected ? .accentColor : .secondary)
                                .frame(width: 22)
                            
                            Text(dev.name)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(dev.isConnected ? .primary : .secondary)
                                .lineLimit(1)
                            
                            Spacer()
                            
                            if dev.isConnected {
                                if let batt = dev.batteryLevel {
                                    HStack(spacing: 4) {
                                        Image(systemName: "battery.100")
                                            .font(.system(size: 11))
                                            .foregroundColor(.green)
                                        Text("\(batt)%")
                                            .font(.system(size: 11, weight: .bold, design: .rounded))
                                    }
                                } else {
                                    Text("Connected")
                                        .font(.system(size: 10, weight: .semibold))
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(Color.green.opacity(0.15))
                                        .foregroundColor(.green)
                                        .cornerRadius(6)
                                }
                            } else {
                                Text("Offline")
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundColor(.secondary.opacity(0.7))
                            }
                        }
                        .padding(.vertical, 2)
                    }
                }
            }
        }
        .padding(14)
        .background(Color.primary.opacity(0.04))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.primary.opacity(0.08), lineWidth: 1)
        )
    }
    
    private var connectedCount: Int {
        devices.filter { $0.isConnected }.count
    }
}
