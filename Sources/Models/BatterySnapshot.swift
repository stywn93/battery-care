import Foundation

public struct BatterySnapshot: Equatable {
    public var percentage: Int = 100
    public var isCharging: Bool = false
    public var isPluggedIn: Bool = false
    public var isFullyCharged: Bool = false
    public var isLowPowerMode: Bool = false
    
    public var voltageVolts: Double = 0.0
    public var amperageMilliAmps: Double = 0.0
    public var liveWatts: Double = 0.0
    
    public var cycleCount: Int = 0
    public var healthPercentage: Double = 100.0
    public var currentCapacityMah: Int = 0
    public var fullChargeCapacityMah: Int = 0
    public var designCapacityMah: Int = 0
    
    public var chargerWattage: Int? = nil
    public var timeRemainingMinutes: Int? = nil
    public var condition: String = "Normal"
    public var serialNumber: String = ""
    public var deviceName: String = ""
    
    public var statusDescription: String {
        if isFullyCharged && isPluggedIn {
            return "Fully Charged (AC Connected)"
        } else if isCharging {
            if let watts = chargerWattage, watts > 0 {
                return "Charging (\(watts)W Adapter)"
            }
            return "Charging"
        } else if isPluggedIn {
            return "Connected to Power"
        } else {
            return "On Battery Power"
        }
    }
    
    public var timeFormatted: String {
        guard let minutes = timeRemainingMinutes, minutes > 0, minutes < 60000 else {
            return isFullyCharged ? "Fully Charged" : "--"
        }
        let h = minutes / 60
        let m = minutes % 60
        if h > 0 {
            return "\(h)h \(m)m"
        } else {
            return "\(m) mins"
        }
    }
}
