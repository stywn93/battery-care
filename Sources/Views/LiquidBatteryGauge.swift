import SwiftUI

public struct LiquidBatteryGauge: View {
    public let percentage: Int
    public let isCharging: Bool
    public let isPluggedIn: Bool
    public let isFullyCharged: Bool
    public let liveWatts: Double
    public let chargerWatts: Int?
    public let timeRemainingText: String
    
    public init(
        percentage: Int,
        isCharging: Bool,
        isPluggedIn: Bool,
        isFullyCharged: Bool,
        liveWatts: Double,
        chargerWatts: Int?,
        timeRemainingText: String
    ) {
        self.percentage = max(0, min(100, percentage))
        self.isCharging = isCharging
        self.isPluggedIn = isPluggedIn
        self.isFullyCharged = isFullyCharged
        self.liveWatts = liveWatts
        self.chargerWatts = chargerWatts
        self.timeRemainingText = timeRemainingText
    }
    
    private var primaryColor: Color {
        if isCharging {
            return Color(red: 0.18, green: 0.85, blue: 0.44) // Juicy Emerald
        } else if percentage <= 20 {
            return Color(red: 1.0, green: 0.28, blue: 0.28) // Vibrant Warning Red
        } else if percentage <= 40 {
            return Color(red: 1.0, green: 0.65, blue: 0.0) // Juicy Warm Amber
        } else {
            return Color(red: 0.18, green: 0.82, blue: 0.46) // Fresh Green
        }
    }
    
    private var secondaryColor: Color {
        if isCharging {
            return Color(red: 0.08, green: 0.68, blue: 0.32)
        } else if percentage <= 20 {
            return Color(red: 0.82, green: 0.16, blue: 0.18)
        } else if percentage <= 40 {
            return Color(red: 0.88, green: 0.48, blue: 0.0)
        } else {
            return Color(red: 0.10, green: 0.62, blue: 0.35)
        }
    }
    
    public var body: some View {
        VStack(spacing: 14) {
            // Big Battery Container with Terminal Cap on the Right
            HStack(spacing: 5) {
                // Main Battery Body
                ZStack {
                    // Outer border track
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(Color.primary.opacity(0.08))
                        .overlay(
                            RoundedRectangle(cornerRadius: 22, style: .continuous)
                                .stroke(Color.primary.opacity(0.16), lineWidth: 2)
                        )
                    
                    // Liquid Fill inside
                    GeometryReader { geo in
                        let fillWidth = max(28, geo.size.width * CGFloat(percentage) / 100.0)
                        ZStack(alignment: .topLeading) {
                            // Base gradient liquid
                            RoundedRectangle(cornerRadius: 19, style: .continuous)
                                .fill(
                                    LinearGradient(
                                        colors: [primaryColor, secondaryColor],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .frame(width: fillWidth, height: geo.size.height - 6)
                            
                            // Glossy glass reflection on top half
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(
                                    LinearGradient(
                                        colors: [Color.white.opacity(0.38), Color.white.opacity(0.04)],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .frame(width: max(0, fillWidth - 6), height: (geo.size.height - 6) * 0.45)
                                .padding(.leading, 3)
                                .padding(.top, 2)
                        }
                        .padding(3)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: percentage)
                    }
                    
                    // Centered Big Percentage & Status inside Battery
                    VStack(spacing: 3) {
                        HStack(spacing: 8) {
                            if isCharging {
                                Image(systemName: "bolt.fill")
                                    .font(.system(size: 30, weight: .bold))
                                    .foregroundColor(.yellow)
                                    .shadow(color: .black.opacity(0.3), radius: 3, x: 0, y: 1)
                            } else if isPluggedIn {
                                Image(systemName: "powerplug.fill")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.white)
                                    .shadow(color: .black.opacity(0.3), radius: 2)
                            }
                            
                            // Giant Bold Percentage Number
                            Text("\(percentage)%")
                                .font(.system(size: 42, weight: .heavy, design: .rounded))
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.4), radius: 4, x: 0, y: 2)
                        }
                        
                        // Status Subtitle inside Battery
                        Text(stateText)
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundColor(.white.opacity(0.95))
                            .shadow(color: .black.opacity(0.4), radius: 2, x: 0, y: 1)
                    }
                }
                .frame(height: 105) // Big Juicy Battery Height!
                
                // Positive Battery Terminal Nipple
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .fill(Color.primary.opacity(0.20))
                    .frame(width: 7, height: 38)
            }
            
            // Sub-metrics row: Live Wattage & Time Remaining
            HStack {
                // Live Wattage Pill
                HStack(spacing: 5) {
                    Image(systemName: isPluggedIn ? "bolt.fill" : "arrow.up.circle.fill")
                        .foregroundColor(isCharging ? .green : (isPluggedIn ? .blue : .orange))
                        .font(.system(size: 12))
                    
                    if abs(liveWatts) > 0.05 {
                        Text(String(format: "%+.1f W", liveWatts))
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                    } else if let adapter = chargerWatts, adapter > 0 {
                        Text("\(adapter)W Connected")
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                    } else {
                        Text("-- W")
                            .font(.system(size: 12, weight: .medium))
                    }
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Color.primary.opacity(0.06))
                .cornerRadius(10)
                
                Spacer()
                
                // Time Remaining Pill
                HStack(spacing: 5) {
                    Image(systemName: "clock.fill")
                        .foregroundColor(.secondary)
                        .font(.system(size: 12))
                    Text(timeRemainingText)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Color.primary.opacity(0.06))
                .cornerRadius(10)
            }
        }
    }
    
    private var stateText: String {
        if isFullyCharged && isPluggedIn {
            return "Fully Charged"
        } else if isCharging {
            if let watts = chargerWatts, watts > 0 {
                return "Charging (\(watts)W)"
            }
            return "Charging"
        } else if isPluggedIn {
            return "Connected to Power"
        } else {
            return "On Battery Power"
        }
    }
}
