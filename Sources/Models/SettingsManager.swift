import Foundation
import SwiftUI
import Combine

public class SettingsManager: ObservableObject {
    public static let shared = SettingsManager()
    
    private let defaults = UserDefaults.standard
    
    @Published public var showPercentageInMenuBar: Bool {
        didSet { defaults.set(showPercentageInMenuBar, forKey: "showPercentageInMenuBar") }
    }
    
    @Published public var showWattageInMenuBar: Bool {
        didSet { defaults.set(showWattageInMenuBar, forKey: "showWattageInMenuBar") }
    }
    
    @Published public var showTimeRemainingInMenuBar: Bool {
        didSet { defaults.set(showTimeRemainingInMenuBar, forKey: "showTimeRemainingInMenuBar") }
    }
    
    @Published public var enableSoundEffects: Bool {
        didSet { defaults.set(enableSoundEffects, forKey: "enableSoundEffects") }
    }
    
    @Published public var notifyOnLowBattery: Bool {
        didSet { defaults.set(notifyOnLowBattery, forKey: "notifyOnLowBattery") }
    }
    
    @Published public var lowBatteryThreshold: Int {
        didSet { defaults.set(lowBatteryThreshold, forKey: "lowBatteryThreshold") }
    }
    
    @Published public var notifyOn80Percent: Bool {
        didSet { defaults.set(notifyOn80Percent, forKey: "notifyOn80Percent") }
    }
    
    @Published public var notifyOnFullCharge: Bool {
        didSet { defaults.set(notifyOnFullCharge, forKey: "notifyOnFullCharge") }
    }
    
    @Published public var refreshInterval: Double {
        didSet { defaults.set(refreshInterval, forKey: "refreshInterval") }
    }
    
    @Published public var enableScreenGlow: Bool {
        didSet { defaults.set(enableScreenGlow, forKey: "enableScreenGlow") }
    }
    
    @Published public var showingSettings: Bool = false
    
    private init() {
        self.showPercentageInMenuBar = defaults.object(forKey: "showPercentageInMenuBar") as? Bool ?? true
        self.showWattageInMenuBar = defaults.object(forKey: "showWattageInMenuBar") as? Bool ?? false
        self.showTimeRemainingInMenuBar = defaults.object(forKey: "showTimeRemainingInMenuBar") as? Bool ?? false
        self.enableSoundEffects = defaults.object(forKey: "enableSoundEffects") as? Bool ?? true
        self.notifyOnLowBattery = defaults.object(forKey: "notifyOnLowBattery") as? Bool ?? true
        self.lowBatteryThreshold = defaults.object(forKey: "lowBatteryThreshold") as? Int ?? 20
        self.notifyOn80Percent = defaults.object(forKey: "notifyOn80Percent") as? Bool ?? true
        self.notifyOnFullCharge = defaults.object(forKey: "notifyOnFullCharge") as? Bool ?? true
        self.refreshInterval = defaults.object(forKey: "refreshInterval") as? Double ?? 2.0
        self.enableScreenGlow = defaults.object(forKey: "enableScreenGlow") as? Bool ?? true
    }
}
