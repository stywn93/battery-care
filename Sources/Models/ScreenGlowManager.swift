import AppKit

public class ScreenGlowManager {
    public static let shared = ScreenGlowManager()
    
    private var windows: [NSWindow] = []
    private var isFlashing: Bool = false
    
    private init() {}
    
    public func flash(color: NSColor, title: String? = nil, duration: TimeInterval = 3.5, pulses: Int = 3) {
        guard SettingsManager.shared.enableScreenGlow else { return }
        
        DispatchQueue.main.async {
            self.stopCurrentGlow()
            let glowWindows = self.prepareWindows(color: color, title: title)
            self.animatePulses(windows: glowWindows, totalPulses: pulses, duration: duration)
        }
    }
    
    private func prepareWindows(color: NSColor, title: String?) -> [NSWindow] {
        // Recreate or resize windows for current screens
        for w in windows {
            w.orderOut(nil)
        }
        windows.removeAll()
        
        for screen in NSScreen.screens {
            let window = NSWindow(
                contentRect: screen.frame,
                styleMask: [.borderless],
                backing: .buffered,
                defer: false
            )
            window.isReleasedWhenClosed = false
            window.isOpaque = false
            window.backgroundColor = .clear
            window.hasShadow = false
            window.level = .screenSaver
            window.ignoresMouseEvents = true
            window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary]
            window.alphaValue = 0.0
            
            let glowView = ScreenGlowView(frame: NSRect(origin: .zero, size: screen.frame.size), color: color, title: title)
            window.contentView = glowView
            window.orderFrontRegardless()
            windows.append(window)
        }
        return windows
    }
    
    private func animatePulses(windows: [NSWindow], totalPulses: Int, duration: TimeInterval) {
        isFlashing = true
        var currentStep = 0
        let totalSteps = max(2, totalPulses * 2)
        let stepDuration = duration / Double(totalSteps)
        
        func nextStep() {
            guard self.isFlashing, !self.windows.isEmpty else { return }
            currentStep += 1
            
            let isEnd = currentStep >= totalSteps
            let targetAlpha: CGFloat = isEnd ? 0.0 : (currentStep % 2 == 1 ? 0.95 : 0.25)
            
            NSAnimationContext.runAnimationGroup({ context in
                context.duration = stepDuration
                context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
                for w in self.windows {
                    w.animator().alphaValue = targetAlpha
                }
            }, completionHandler: {
                DispatchQueue.main.async {
                    if isEnd {
                        self.stopCurrentGlow()
                    } else if self.isFlashing {
                        nextStep()
                    }
                }
            })
        }
        
        nextStep()
    }
    
    public func stopCurrentGlow() {
        isFlashing = false
        for w in windows {
            w.alphaValue = 0.0
            w.orderOut(nil)
        }
        windows.removeAll()
    }
}

// Custom View drawing the glowing border vignette & banner
public class ScreenGlowView: NSView {
    private var glowColor: NSColor
    private var title: String?
    
    public init(frame frameRect: NSRect, color: NSColor, title: String?) {
        self.glowColor = color
        self.title = title
        super.init(frame: frameRect)
        self.wantsLayer = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func update(color: NSColor, title: String?) {
        self.glowColor = color
        self.title = title
        self.needsDisplay = true
    }
    
    public override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        guard let context = NSGraphicsContext.current?.cgContext else { return }
        let bounds = self.bounds
        let glowDepth: CGFloat = 55.0
        
        let cgColor = glowColor.cgColor
        let clearColor = glowColor.withAlphaComponent(0.0).cgColor
        let midColor = glowColor.withAlphaComponent(0.35).cgColor
        
        guard let gradient = CGGradient(
            colorsSpace: CGColorSpaceCreateDeviceRGB(),
            colors: [cgColor, midColor, clearColor] as CFArray,
            locations: [0.0, 0.45, 1.0]
        ) else { return }
        
        // 1. Top Edge Glow
        context.saveGState()
        context.drawLinearGradient(
            gradient,
            start: CGPoint(x: bounds.midX, y: bounds.maxY),
            end: CGPoint(x: bounds.midX, y: bounds.maxY - glowDepth),
            options: []
        )
        context.restoreGState()
        
        // 2. Bottom Edge Glow
        context.saveGState()
        context.drawLinearGradient(
            gradient,
            start: CGPoint(x: bounds.midX, y: bounds.minY),
            end: CGPoint(x: bounds.midX, y: bounds.minY + glowDepth),
            options: []
        )
        context.restoreGState()
        
        // 3. Left Edge Glow
        context.saveGState()
        context.drawLinearGradient(
            gradient,
            start: CGPoint(x: bounds.minX, y: bounds.midY),
            end: CGPoint(x: bounds.minX + glowDepth, y: bounds.midY),
            options: []
        )
        context.restoreGState()
        
        // 4. Right Edge Glow
        context.saveGState()
        context.drawLinearGradient(
            gradient,
            start: CGPoint(x: bounds.maxX, y: bounds.midY),
            end: CGPoint(x: bounds.maxX - glowDepth, y: bounds.midY),
            options: []
        )
        context.restoreGState()
        
        // 5. Intense crisp inner border (3px)
        context.saveGState()
        context.setStrokeColor(glowColor.withAlphaComponent(0.85).cgColor)
        context.setLineWidth(3.0)
        let strokeRect = bounds.insetBy(dx: 1.5, dy: 1.5)
        let path = CGPath(roundedRect: strokeRect, cornerWidth: 20, cornerHeight: 20, transform: nil)
        context.addPath(path)
        context.strokePath()
        context.restoreGState()
        
        // 6. Optional Top Center Notification Banner
        if let title = title {
            drawCenterBadge(title: title, bounds: bounds)
        }
    }
    
    private func drawCenterBadge(title: String, bounds: NSRect) {
        let badgeWidth: CGFloat = 360
        let badgeHeight: CGFloat = 100
        let badgeRect = NSRect(
            x: (bounds.width - badgeWidth) / 2.0,
            y: (bounds.height - badgeHeight) / 2.0, // Exactly centered vertically and horizontally!
            width: badgeWidth,
            height: badgeHeight
        )
        
        // Card background (Dark translucent HUD)
        let path = NSBezierPath(roundedRect: badgeRect, xRadius: 22, yRadius: 22)
        NSColor.black.withAlphaComponent(0.88).setFill()
        path.fill()
        
        // Neon border matching the glow color
        glowColor.withAlphaComponent(0.85).setStroke()
        path.lineWidth = 2.5
        path.stroke()
        
        // App header inside badge
        let headerAttrs: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 11, weight: .heavy),
            .foregroundColor: glowColor
        ]
        let headerStr = NSAttributedString(string: "BATTERY CARE", attributes: headerAttrs)
        let headerSize = headerStr.size()
        let headerRect = NSRect(
            x: badgeRect.midX - (headerSize.width / 2.0),
            y: badgeRect.maxY - 28,
            width: headerSize.width,
            height: headerSize.height
        )
        headerStr.draw(in: headerRect)
        
        // Main title (large and prominent)
        let titleAttrs: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 18, weight: .bold),
            .foregroundColor: NSColor.white
        ]
        let titleStr = NSAttributedString(string: title, attributes: titleAttrs)
        let titleSize = titleStr.size()
        let titleRect = NSRect(
            x: badgeRect.midX - (titleSize.width / 2.0),
            y: badgeRect.minY + 22,
            width: titleSize.width,
            height: titleSize.height
        )
        titleStr.draw(in: titleRect)
    }
}
