import AppKit

public class MenuBarBatteryRenderer {
    
    public static func render(percentage: Int, isCharging: Bool, isPluggedIn: Bool) -> NSImage {
        let pct = max(0, min(100, percentage))
        
        // Dynamic width: wider for 3 digits (100%) or charging bolt
        let width: CGFloat
        if isCharging {
            width = pct >= 100 ? 46.0 : 42.0
        } else {
            width = pct >= 100 ? 42.0 : 38.0
        }
        
        let height: CGFloat = 17.0
        let size = NSSize(width: width, height: height)
        
        let image = NSImage(size: size, flipped: false) { bounds in
            let bodyWidth = width - 4.5
            let bodyRect = NSRect(x: 1.0, y: 1.0, width: bodyWidth, height: height - 2.0)
            
            // 1. Draw battery body outline
            let bodyPath = NSBezierPath(roundedRect: bodyRect, xRadius: 4.5, yRadius: 4.5)
            NSColor.labelColor.setStroke()
            bodyPath.lineWidth = 1.3
            bodyPath.stroke()
            
            // 2. Draw battery terminal nipple on the right edge
            let tipHeight: CGFloat = 6.0
            let tipRect = NSRect(
                x: bodyWidth + 1.2,
                y: (height - tipHeight) / 2.0,
                width: 2.3,
                height: tipHeight
            )
            let tipPath = NSBezierPath(roundedRect: tipRect, xRadius: 1.2, yRadius: 1.2)
            NSColor.labelColor.setFill()
            tipPath.fill()
            
            // 3. Draw internal battery liquid fill level
            let maxFillWidth = bodyWidth - 4.0
            let fillWidth = max(3.0, maxFillWidth * CGFloat(pct) / 100.0)
            let fillRect = NSRect(x: 2.0, y: 2.0, width: fillWidth, height: height - 4.0)
            let fillPath = NSBezierPath(roundedRect: fillRect, xRadius: 3.0, yRadius: 3.0)
            
            if pct <= 20 && !isCharging {
                // Warning fill
                NSColor.labelColor.withAlphaComponent(0.45).setFill()
            } else {
                // Normal fill
                NSColor.labelColor.withAlphaComponent(0.35).setFill()
            }
            fillPath.fill()
            
            // 4. Draw Percentage & Bolt INSIDE the battery body
            let text: String
            if isCharging {
                text = "⚡\(pct)"
            } else {
                text = "\(pct)"
            }
            
            let fontSize: CGFloat = isCharging ? 8.8 : 9.8
            let font = NSFont.systemFont(ofSize: fontSize, weight: .heavy)
            let attrs: [NSAttributedString.Key: Any] = [
                .font: font,
                .foregroundColor: NSColor.labelColor
            ]
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
        
        image.isTemplate = true
        return image
    }
}
