import AppKit

public class MenuBarBatteryRenderer {
    
    public static func render(
        percentage: Int,
        isCharging: Bool,
        isPluggedIn: Bool,
        isFullyCharged: Bool
    ) -> NSImage {
        let pct = max(0, min(100, percentage))
        let isFull = isFullyCharged || pct >= 100
        
        // Show bolt whenever connected to power or charging
        let showChargingBolt = isCharging || isPluggedIn
        
        // Dimensions
        let boltWidth: CGFloat = showChargingBolt ? 11.0 : 0.0
        let spacing: CGFloat = showChargingBolt ? 4.0 : 0.0
        let batteryWidth: CGFloat = pct >= 100 ? 42.0 : 38.0
        
        let totalWidth: CGFloat = boltWidth + spacing + batteryWidth
        let height: CGFloat = 17.0
        let size = NSSize(width: totalWidth, height: height)
        
        // Colors
        let greenColor = NSColor(red: 0.18, green: 0.82, blue: 0.44, alpha: 1.0)
        let redColor = NSColor(red: 1.0, green: 0.28, blue: 0.28, alpha: 1.0)
        let amberColor = NSColor(red: 1.0, green: 0.65, blue: 0.0, alpha: 1.0)
        let boltYellowColor = NSColor(red: 1.0, green: 0.82, blue: 0.0, alpha: 1.0)
        
        let strokeColor: NSColor
        let fillColor: NSColor
        let textColor: NSColor
        let useTemplate: Bool
        
        if showChargingBolt {
            // Connected to power / Charging -> Green battery + Yellow Bolt
            strokeColor = greenColor
            fillColor = greenColor
            textColor = .white
            useTemplate = false
        } else if isFull {
            // Full Battery on Battery Power -> Vibrant Green
            strokeColor = greenColor
            fillColor = greenColor
            textColor = .white
            useTemplate = false
        } else if pct <= 20 {
            // Low Battery -> Vibrant Red
            strokeColor = redColor
            fillColor = redColor
            textColor = .white
            useTemplate = false
        } else if pct <= 40 {
            // Medium-low -> Amber
            strokeColor = amberColor
            fillColor = amberColor.withAlphaComponent(0.9)
            textColor = .white
            useTemplate = false
        } else {
            // Normal Discharging -> Clean adaptive template
            strokeColor = .labelColor
            fillColor = .labelColor.withAlphaComponent(0.35)
            textColor = .labelColor
            useTemplate = true
        }
        
        let image = NSImage(size: size, flipped: false) { bounds in
            var startX: CGFloat = 0.0
            
            // 1. Draw Small Lightning Bolt Icon BESIDE the battery if charging / plugged in
            if showChargingBolt {
                let boltRect = NSRect(x: 0.5, y: 1.5, width: 10.0, height: 14.0)
                let boltPath = NSBezierPath()
                let w = boltRect.width
                let h = boltRect.height
                let x = boltRect.minX
                let y = boltRect.minY
                
                // Crisp vector lightning bolt
                boltPath.move(to: NSPoint(x: x + w * 0.58, y: y + h))
                boltPath.line(to: NSPoint(x: x + w * 0.12, y: y + h * 0.48))
                boltPath.line(to: NSPoint(x: x + w * 0.48, y: y + h * 0.48))
                boltPath.line(to: NSPoint(x: x + w * 0.35, y: y))
                boltPath.line(to: NSPoint(x: x + w * 0.92, y: y + h * 0.54))
                boltPath.line(to: NSPoint(x: x + w * 0.54, y: y + h * 0.54))
                boltPath.close()
                
                boltYellowColor.setFill()
                boltPath.fill()
                
                startX = boltWidth + spacing
            }
            
            // 2. Draw battery body outline
            let bodyWidth = batteryWidth - 4.5
            let bodyRect = NSRect(x: startX + 1.0, y: 1.0, width: bodyWidth, height: height - 2.0)
            let bodyPath = NSBezierPath(roundedRect: bodyRect, xRadius: 4.5, yRadius: 4.5)
            strokeColor.setStroke()
            bodyPath.lineWidth = 1.3
            bodyPath.stroke()
            
            // 3. Draw battery terminal nipple on the right edge
            let tipHeight: CGFloat = 6.0
            let tipRect = NSRect(
                x: startX + bodyWidth + 1.2,
                y: (height - tipHeight) / 2.0,
                width: 2.3,
                height: tipHeight
            )
            let tipPath = NSBezierPath(roundedRect: tipRect, xRadius: 1.2, yRadius: 1.2)
            strokeColor.setFill()
            tipPath.fill()
            
            // 4. Draw internal battery liquid fill level
            let maxFillWidth = bodyWidth - 4.0
            let fillWidth = max(3.0, maxFillWidth * CGFloat(pct) / 100.0)
            let fillRect = NSRect(x: startX + 2.0, y: 2.0, width: fillWidth, height: height - 4.0)
            let fillPath = NSBezierPath(roundedRect: fillRect, xRadius: 3.0, yRadius: 3.0)
            
            fillColor.setFill()
            fillPath.fill()
            
            // 5. Clean Percentage number INSIDE the battery body
            let text = "\(pct)"
            let font = NSFont.systemFont(ofSize: 9.8, weight: .heavy)
            
            var attrs: [NSAttributedString.Key: Any] = [
                .font: font,
                .foregroundColor: textColor
            ]
            
            if !useTemplate {
                let shadow = NSShadow()
                shadow.shadowColor = NSColor.black.withAlphaComponent(0.35)
                shadow.shadowOffset = NSSize(width: 0, height: -0.5)
                shadow.shadowBlurRadius = 1.0
                attrs[.shadow] = shadow
            }
            
            let attrStr = NSAttributedString(string: text, attributes: attrs)
            let textSize = attrStr.size()
            
            let textRect = NSRect(
                x: bodyRect.midX - (textSize.width / 2.0),
                y: bodyRect.midY - (textSize.height / 2.0) - 0.5,
                width: textSize.width,
                height: textSize.height
            )
            attrStr.draw(in: textRect)
            
            return true
        }
        
        image.isTemplate = useTemplate
        return image
    }
}
