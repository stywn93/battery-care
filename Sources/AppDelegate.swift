import AppKit
import SwiftUI
import Combine

public class AppDelegate: NSObject, NSApplicationDelegate, NSPopoverDelegate {
    private var statusItem: NSStatusItem!
    private var popover: NSPopover!
    private var eventMonitor: Any?
    
    private let batteryManager = BatteryManager.shared
    private let bluetoothManager = BluetoothManager.shared
    private let settings = SettingsManager.shared
    private let notifications = NotificationManager.shared
    
    private var cancellables = Set<AnyCancellable>()
    
    public func applicationDidFinishLaunching(_ notification: Notification) {
        // Setup Menu Bar Status Item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem.button {
            button.action = #selector(togglePopover(_:))
            button.target = self
        }
        
        // Setup Popover
        popover = NSPopover()
        popover.contentSize = NSSize(width: 350, height: 570)
        popover.behavior = .transient
        popover.animates = true
        popover.delegate = self
        
        let contentView = MainPopoverView(
            batteryManager: batteryManager,
            bluetoothManager: bluetoothManager,
            settings: settings
        )
        popover.contentViewController = NSHostingController(rootView: contentView)
        
        // Listen to battery updates
        batteryManager.$snapshot
            .receive(on: DispatchQueue.main)
            .sink { [weak self] snapshot in
                self?.updateMenuBar(snapshot: snapshot)
                if let settings = self?.settings {
                    self?.notifications.evaluate(snapshot: snapshot, settings: settings)
                }
            }
            .store(in: &cancellables)
            
        // Listen to settings updates
        settings.objectWillChange
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                if let self = self {
                    self.updateMenuBar(snapshot: self.batteryManager.snapshot)
                }
            }
            .store(in: &cancellables)
            
        updateMenuBar(snapshot: batteryManager.snapshot)
    }
    
    @objc private func togglePopover(_ sender: AnyObject?) {
        guard let button = statusItem.button else { return }
        
        if popover.isShown {
            closePopover(sender)
        } else {
            showPopover(button)
        }
    }
    
    private func showPopover(_ button: NSStatusBarButton) {
        // Trigger quick refresh on open
        batteryManager.refresh()
        bluetoothManager.refresh()
        
        popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        popover.contentViewController?.view.window?.makeKey()
        
        // Monitor global outside mouse clicks to guarantee instant dismiss
        if eventMonitor == nil {
            eventMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] _ in
                self?.closePopover(nil)
            }
        }
    }
    
    private func closePopover(_ sender: AnyObject?) {
        if popover.isShown {
            popover.performClose(sender)
        }
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
            eventMonitor = nil
        }
    }
    
    public func popoverDidClose(_ notification: Notification) {
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
            eventMonitor = nil
        }
        settings.showingSettings = false
    }
    
    public func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false
    }
    
    private func updateMenuBar(snapshot: BatterySnapshot) {
        guard let button = statusItem.button else { return }
        
        let image = MenuBarBatteryRenderer.render(
            percentage: snapshot.percentage,
            isCharging: snapshot.isCharging,
            isPluggedIn: snapshot.isPluggedIn
        )
        button.image = image
        button.imagePosition = .imageLeading
        
        // Optional Title components (e.g. wattage or time remaining)
        var titleComponents: [String] = []
        
        if settings.showWattageInMenuBar {
            if snapshot.isCharging, let watts = snapshot.chargerWattage, watts > 0 {
                titleComponents.append("\(watts)W")
            } else if abs(snapshot.liveWatts) > 0.05 {
                titleComponents.append(String(format: "%+.0fW", snapshot.liveWatts))
            }
        }
        
        if settings.showTimeRemainingInMenuBar && snapshot.timeFormatted != "--" && snapshot.timeFormatted != "Fully Charged" {
            titleComponents.append(snapshot.timeFormatted)
        }
        
        button.title = titleComponents.isEmpty ? "" : " " + titleComponents.joined(separator: " ")
    }
}
