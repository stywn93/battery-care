import Foundation
import IOKit
import IOKit.ps
import Combine

public class BatteryManager: ObservableObject {
    public static let shared = BatteryManager()
    
    @Published public var snapshot: BatterySnapshot = BatterySnapshot()
    
    private var timer: Timer?
    private var runLoopSource: CFRunLoopSource?
    
    public init() {
        refresh()
        startMonitoring()
    }
    
    deinit {
        stopMonitoring()
    }
    
    public func startMonitoring(interval: TimeInterval = 2.0) {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            self?.refresh()
        }
        
        // Also register for IOKit power source notifications
        let context = UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
        runLoopSource = IOPSNotificationCreateRunLoopSource({ context in
            guard let context = context else { return }
            let manager = Unmanaged<BatteryManager>.fromOpaque(context).takeUnretainedValue()
            DispatchQueue.main.async {
                manager.refresh()
            }
        }, context).takeRetainedValue()
        
        if let source = runLoopSource {
            CFRunLoopAddSource(CFRunLoopGetCurrent(), source, .defaultMode)
        }
    }
    
    public func stopMonitoring() {
        timer?.invalidate()
        timer = nil
        if let source = runLoopSource {
            CFRunLoopRemoveSource(CFRunLoopGetCurrent(), source, .defaultMode)
            runLoopSource = nil
        }
    }
    
    public func refresh() {
        var snap = BatterySnapshot()
        
        // 1. Read IOPS for power source state and time remaining
        if let psInfo = IOPSCopyPowerSourcesInfo()?.takeRetainedValue(),
           let psList = IOPSCopyPowerSourcesList(psInfo)?.takeRetainedValue() as? [CFTypeRef] {
            for ps in psList {
                if let desc = IOPSGetPowerSourceDescription(psInfo, ps)?.takeUnretainedValue() as? [String: Any] {
                    if let cur = desc[kIOPSCurrentCapacityKey] as? Int {
                        snap.percentage = cur
                    }
                    if let isChg = desc[kIOPSIsChargingKey] as? Bool {
                        snap.isCharging = isChg
                    }
                    if let state = desc[kIOPSPowerSourceStateKey] as? String {
                        snap.isPluggedIn = (state == kIOPSACPowerValue)
                    }
                    if let charged = desc[kIOPSIsChargedKey] as? Bool {
                        snap.isFullyCharged = charged
                    }
                    if let lpm = desc["LPM Active"] as? Int {
                        snap.isLowPowerMode = (lpm == 1)
                    }
                    if snap.isCharging {
                        if let timeToFull = desc[kIOPSTimeToFullChargeKey] as? Int, timeToFull > 0 {
                            snap.timeRemainingMinutes = timeToFull
                        }
                    } else if !snap.isPluggedIn {
                        if let timeToEmpty = desc[kIOPSTimeToEmptyKey] as? Int, timeToEmpty > 0 {
                            snap.timeRemainingMinutes = timeToEmpty
                        }
                    }
                }
            }
        }
        
        // 2. Read AppleSmartBattery for low-level diagnostics
        let service = IOServiceGetMatchingService(kIOMainPortDefault, IOServiceMatching("AppleSmartBattery"))
        if service != 0 {
            defer { IOObjectRelease(service) }
            var props: Unmanaged<CFMutableDictionary>?
            if IORegistryEntryCreateCFProperties(service, &props, kCFAllocatorDefault, 0) == KERN_SUCCESS,
               let dict = props?.takeRetainedValue() as? [String: Any] {
                
                if let cur = dict["CurrentCapacity"] as? Int {
                    snap.percentage = cur
                }
                if let isChg = dict["IsCharging"] as? Bool {
                    snap.isCharging = isChg
                }
                if let ext = dict["ExternalConnected"] as? Bool {
                    snap.isPluggedIn = ext
                }
                if let fully = dict["FullyCharged"] as? Bool {
                    snap.isFullyCharged = fully
                }
                if let cycles = dict["CycleCount"] as? Int {
                    snap.cycleCount = cycles
                }
                if let serial = dict["Serial"] as? String {
                    snap.serialNumber = serial
                }
                if let devName = dict["DeviceName"] as? String {
                    snap.deviceName = devName
                }
                
                let voltageMv = Double(dict["Voltage"] as? Int ?? 0)
                snap.voltageVolts = voltageMv / 1000.0
                
                // Amperage can be negative (discharging) or positive (charging)
                var rawAmps = Double(dict["Amperage"] as? Int ?? 0)
                if rawAmps == 0, let inst = dict["InstantAmperage"] as? Int {
                    rawAmps = Double(inst)
                }
                snap.amperageMilliAmps = rawAmps
                
                // Adapter details
                if let adapter = dict["AdapterDetails"] as? [String: Any] {
                    if let watts = adapter["Watts"] as? Int {
                        snap.chargerWattage = watts
                    }
                }
                
                // Live wattage from PowerTelemetryData or Amperage
                var calculatedWatts: Double = 0.0
                if let telem = dict["PowerTelemetryData"] as? [String: Any] {
                    if snap.isPluggedIn {
                        if let sysPowerIn = telem["SystemPowerIn"] as? Int, sysPowerIn > 0 {
                            calculatedWatts = Double(sysPowerIn) / 1000.0
                        } else if let sysLoad = telem["SystemLoad"] as? Int, sysLoad > 0 {
                            calculatedWatts = Double(sysLoad) / 1000.0
                        }
                    } else {
                        if let sysLoad = telem["SystemLoad"] as? Int, sysLoad > 0 {
                            calculatedWatts = -(Double(sysLoad) / 1000.0)
                        }
                    }
                }
                
                // If telemetry was 0, compute from voltage * amperage
                if calculatedWatts == 0.0 && rawAmps != 0.0 {
                    calculatedWatts = (voltageMv * rawAmps) / 1_000_000.0
                }
                snap.liveWatts = calculatedWatts
                
                // Battery capacities and health
                if let bdata = dict["BatteryData"] as? [String: Any] {
                    let design = bdata["DesignCapacity"] as? Int ?? 0
                    let full = bdata["FullChargeCapacity"] as? Int ?? 0
                    let curCap = bdata["CurrentCapacity"] as? Int ?? (bdata["RemainingCapacity"] as? Int ?? 0)
                    
                    snap.designCapacityMah = design
                    snap.fullChargeCapacityMah = full
                    snap.currentCapacityMah = curCap
                    
                    if design > 0 && full > 0 {
                        snap.healthPercentage = min(100.0, (Double(full) / Double(design)) * 100.0)
                    }
                } else {
                    if let design = dict["DesignCapacity"] as? Int {
                        snap.designCapacityMah = design
                    }
                    if let full = dict["MaxCapacity"] as? Int {
                        snap.fullChargeCapacityMah = full
                    }
                }
                
                // Determine battery health condition
                if snap.healthPercentage >= 80.0 {
                    snap.condition = "Normal"
                } else if snap.healthPercentage >= 70.0 {
                    snap.condition = "Fair"
                } else {
                    snap.condition = "Service Recommended"
                }
            }
        }
        
        DispatchQueue.main.async {
            self.snapshot = snap
        }
    }
}
