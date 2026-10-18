import Foundation
import AppKit
import UserNotifications

public class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
    public static let shared = NotificationManager()
    
    private var lastPluggedIn: Bool? = nil
    private var alertedLowBattery: Bool = false
    private var alerted80Percent: Bool = false
    private var alertedFullCharge: Bool = false
    private var isFirstEvaluation: Bool = true
    
    private override init() {
        super.init()
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        requestAuthorization()
    }
    
    public func requestAuthorization() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error.localizedDescription)")
            }
        }
    }
    
    // Allows notifications to show banner even when app is active/focused
    public func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        if #available(macOS 11.0, *) {
            completionHandler([.banner, .sound, .badge])
        } else {
            completionHandler([.alert, .sound, .badge])
        }
    }
    
    // Testing helpers
    public func testLowBatteryAlert(percentage: Int = 15) {
        sendNotification(
            title: "Low Battery Warning ⚠️",
            body: "[TEST] Battery is down to \(percentage)%. Plug in your charger soon."
        )
        if SettingsManager.shared.enableSoundEffects {
            NSSound(named: "Blow")?.play()
        }
        ScreenGlowManager.shared.flash(
            color: .systemRed,
            title: "⚠️ Low Battery (\(percentage)%)",
            duration: 4.0,
            pulses: 4
        )
    }
    
    public func test80PercentAlert() {
        sendNotification(
            title: "Battery Care Target (80%) ⚡️",
            body: "[TEST] Battery reached 80%. Unplug to maximize battery lifespan, or keep charging if you're traveling."
        )
        if SettingsManager.shared.enableSoundEffects {
            NSSound(named: "Ping")?.play()
        }
        ScreenGlowManager.shared.flash(
            color: .systemOrange,
            title: "⚡️ 80% Charge Limit Reached",
            duration: 3.5,
            pulses: 3
        )
    }
    
    public func testFullChargeAlert() {
        sendNotification(
            title: "Fully Charged 🔋",
            body: "[TEST] Your MacBook is 100% charged and ready to go."
        )
        if SettingsManager.shared.enableSoundEffects {
            NSSound(named: "Glass")?.play()
        }
        ScreenGlowManager.shared.flash(
            color: .systemGreen,
            title: "🔋 100% Fully Charged",
            duration: 3.5,
            pulses: 3
        )
    }
    
    public func evaluate(snapshot: BatterySnapshot, settings: SettingsManager) {
        if isFirstEvaluation {
            isFirstEvaluation = false
            lastPluggedIn = snapshot.isPluggedIn
            alertedLowBattery = (snapshot.percentage <= settings.lowBatteryThreshold)
            alerted80Percent = (snapshot.percentage >= 80)
            alertedFullCharge = (snapshot.isFullyCharged || snapshot.percentage >= 100)
            return
        }
        
        // 1. Plugged in / Unplugged sound effect & subtle glow
        if let last = lastPluggedIn {
            if !last && snapshot.isPluggedIn {
                // Plugged in!
                if settings.enableSoundEffects {
                    NSSound(named: "Hero")?.play()
                }
                ScreenGlowManager.shared.flash(
                    color: .systemGreen,
                    title: "⚡️ Charger Connected",
                    duration: 1.6,
                    pulses: 1
                )
            } else if last && !snapshot.isPluggedIn {
                // Unplugged!
                if settings.enableSoundEffects {
                    NSSound(named: "Pop")?.play()
                }
            }
        }
        lastPluggedIn = snapshot.isPluggedIn
        
        // 2. Low battery notification & red screen glow
        if settings.notifyOnLowBattery && !snapshot.isPluggedIn {
            if snapshot.percentage <= settings.lowBatteryThreshold {
                if !alertedLowBattery {
                    alertedLowBattery = true
                    sendNotification(
                        title: "Low Battery Warning ⚠️",
                        body: "Battery is down to \(snapshot.percentage)%. Plug in your charger soon."
                    )
                    if settings.enableSoundEffects {
                        NSSound(named: "Blow")?.play()
                    }
                    ScreenGlowManager.shared.flash(
                        color: .systemRed,
                        title: "⚠️ Low Battery Warning (\(snapshot.percentage)%)",
                        duration: 4.5,
                        pulses: 4
                    )
                }
            } else {
                alertedLowBattery = false
            }
        } else {
            alertedLowBattery = false
        }
        
        // 3. 80% charge notification & amber screen glow
        if settings.notifyOn80Percent && snapshot.isCharging {
            if snapshot.percentage >= 80 && snapshot.percentage < 85 {
                if !alerted80Percent {
                    alerted80Percent = true
                    sendNotification(
                        title: "Battery Care Target (80%) ⚡️",
                        body: "Battery reached 80%. Unplug to maximize battery lifespan, or keep charging if you're traveling."
                    )
                    if settings.enableSoundEffects {
                        NSSound(named: "Ping")?.play()
                    }
                    ScreenGlowManager.shared.flash(
                        color: .systemOrange,
                        title: "⚡️ 80% Charge Limit Reached",
                        duration: 3.5,
                        pulses: 3
                    )
                }
            } else if snapshot.percentage < 75 {
                alerted80Percent = false
            }
        }
        
        // 4. 100% full charge notification & emerald green screen glow
        if settings.notifyOnFullCharge && snapshot.isPluggedIn {
            if snapshot.isFullyCharged || snapshot.percentage >= 100 {
                if !alertedFullCharge {
                    alertedFullCharge = true
                    sendNotification(
                        title: "Fully Charged 🔋",
                        body: "Your MacBook is 100% charged and ready to go."
                    )
                    if settings.enableSoundEffects {
                        NSSound(named: "Glass")?.play()
                    }
                    ScreenGlowManager.shared.flash(
                        color: .systemGreen,
                        title: "🔋 100% Fully Charged",
                        duration: 3.5,
                        pulses: 3
                    )
                }
            } else if snapshot.percentage < 95 {
                alertedFullCharge = false
            }
        }
    }
    
    public func sendNotification(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let req = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(req)
    }
}
