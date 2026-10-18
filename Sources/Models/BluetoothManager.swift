import Foundation
import IOBluetooth
import Combine

public class BluetoothManager: ObservableObject {
    public static let shared = BluetoothManager()
    
    @Published public var devices: [BluetoothDeviceInfo] = []
    
    private var timer: Timer?
    
    public init() {
        refresh()
        startMonitoring()
    }
    
    deinit {
        timer?.invalidate()
    }
    
    public func startMonitoring(interval: TimeInterval = 5.0) {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            self?.refresh()
        }
    }
    
    public func refresh() {
        guard let paired = IOBluetoothDevice.pairedDevices() as? [IOBluetoothDevice] else {
            DispatchQueue.main.async {
                self.devices = []
            }
            return
        }
        
        var list: [BluetoothDeviceInfo] = []
        for dev in paired {
            let name = dev.nameOrAddress ?? "Unknown Device"
            let address = dev.addressString ?? UUID().uuidString
            let connected = dev.isConnected()
            
            var battery: Int? = nil
            if connected {
                battery = queryBattery(device: dev)
            }
            
            let category = categorize(name: name, device: dev)
            list.append(BluetoothDeviceInfo(
                id: address,
                name: name,
                isConnected: connected,
                batteryLevel: battery,
                deviceType: category
            ))
        }
        
        // Sort: connected first, then alphabetical
        list.sort { d1, d2 in
            if d1.isConnected != d2.isConnected {
                return d1.isConnected && !d2.isConnected
            }
            return d1.name < d2.name
        }
        
        DispatchQueue.main.async {
            self.devices = list
        }
    }
    
    private func queryBattery(device: IOBluetoothDevice) -> Int? {
        let selectors = ["batteryPercentCombined", "batteryPercentSingle", "batteryPercentCase", "batteryPercentLeft"]
        for selName in selectors {
            let sel = Selector((selName))
            if device.responds(to: sel) {
                if let raw = device.perform(sel)?.toOpaque() {
                    let val = Int(bitPattern: raw)
                    if val > 0 && val <= 100 {
                        return val
                    }
                }
            }
        }
        return nil
    }
    
    private func categorize(name: String, device: IOBluetoothDevice) -> BluetoothDeviceCategory {
        let lower = name.lowercased()
        if lower.contains("airpod") {
            return .airPods
        } else if lower.contains("headphone") || lower.contains("earphone") || lower.contains("soundcore") || lower.contains("buds") || lower.contains("wh-") || lower.contains("wf-") {
            return .headphones
        } else if lower.contains("keyboard") || lower.contains("keychron") || lower.contains("gt-65") || lower.contains("vortex") {
            return .keyboard
        } else if lower.contains("mouse") || lower.contains("mx master") || lower.contains("magic mouse") {
            return .mouse
        } else if lower.contains("trackpad") {
            return .trackpad
        }
        return .other
    }
}
