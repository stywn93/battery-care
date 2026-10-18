import SwiftUI

public struct BatteryHealthCard: View {
    public let snapshot: BatterySnapshot
    
    public init(snapshot: BatterySnapshot) {
        self.snapshot = snapshot
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Label("Battery Health & Details", systemImage: "heart.text.square.fill")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text(snapshot.condition)
                    .font(.system(size: 11, weight: .semibold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(conditionColor.opacity(0.18))
                    .foregroundColor(conditionColor)
                    .cornerRadius(8)
            }
            
            // Health percentage meter
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Maximum Capacity")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(String(format: "%.1f%%", snapshot.healthPercentage))
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(conditionColor)
                }
                
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.primary.opacity(0.08))
                            .frame(height: 7)
                        Capsule()
                            .fill(conditionColor)
                            .frame(width: max(8, geo.size.width * CGFloat(min(100.0, snapshot.healthPercentage)) / 100.0), height: 7)
                    }
                }
                .frame(height: 7)
            }
            
            Divider()
                .opacity(0.4)
            
            // Grid of specs
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                StatItem(label: "Cycle Count", value: "\(snapshot.cycleCount) cycles", icon: "arrow.triangle.2.circlepath")
                StatItem(
                    label: "Charger",
                    value: snapshot.chargerWattage != nil ? "\(snapshot.chargerWattage!)W Connected" : "Disconnected",
                    icon: "bolt.badge.automatic.fill"
                )
                StatItem(
                    label: "Capacity",
                    value: "\(snapshot.fullChargeCapacityMah) / \(snapshot.designCapacityMah) mAh",
                    icon: "scalemass.fill"
                )
                StatItem(
                    label: "Voltage",
                    value: String(format: "%.2f V", snapshot.voltageVolts),
                    icon: "speedometer"
                )
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
    
    private var conditionColor: Color {
        if snapshot.healthPercentage >= 80 {
            return .green
        } else if snapshot.healthPercentage >= 70 {
            return .orange
        } else {
            return .red
        }
    }
}

private struct StatItem: View {
    let label: String
    let value: String
    let icon: String
    
    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 13))
                .foregroundColor(.accentColor)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.primary)
                    .lineLimit(1)
            }
            Spacer()
        }
    }
}
