import Foundation

public struct BluetoothDeviceInfo: Identifiable, Equatable {
    public var id: String
    public var name: String
    public var isConnected: Bool
    public var batteryLevel: Int? // 0 - 100
    public var deviceType: BluetoothDeviceCategory
    
    public var iconName: String {
        switch deviceType {
        case .airPods:
            return "airpodspro"
        case .headphones:
            return "headphones"
        case .keyboard:
            return "keyboard"
        case .mouse:
            return "magicmouse"
        case .trackpad:
            return "trackpad"
        case .other:
            return "wave.3.right.circle"
        }
    }
}

public enum BluetoothDeviceCategory: Equatable {
    case airPods
    case headphones
    case keyboard
    case mouse
    case trackpad
    case other
}
