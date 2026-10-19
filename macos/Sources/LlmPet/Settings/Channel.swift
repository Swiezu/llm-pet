import AppKit
import SwiftUI

struct Channel: Codable, Identifiable, Hashable {
    static let mainID = "main"

    var id: String
    var name: String
    var color: String
    var muted = false

    var isMain: Bool { id == Self.mainID }
    var background: Color { Color(hex: color) }
    var foreground: Color { NSColor(hex: color).luminance > 0.55 ? .black.opacity(0.85) : .white }
}

extension NSColor {
    convenience init(hex: String) {
        let value = UInt32(hex.trimmingCharacters(in: CharacterSet(charactersIn: "#")), radix: 16) ?? 0xFFFFFF
        self.init(srgbRed: CGFloat((value >> 16) & 0xFF) / 255, green: CGFloat((value >> 8) & 0xFF) / 255, blue: CGFloat(value & 0xFF) / 255, alpha: 1)
    }

    var hex: String {
        let color = usingColorSpace(.sRGB) ?? self
        return String(format: "#%02X%02X%02X", Int(round(color.redComponent * 255)), Int(round(color.greenComponent * 255)), Int(round(color.blueComponent * 255)))
    }

    var luminance: CGFloat {
        let color = usingColorSpace(.sRGB) ?? self
        return 0.2126 * color.redComponent + 0.7152 * color.greenComponent + 0.0722 * color.blueComponent
    }
}

extension Color {
    init(hex: String) {
        self.init(nsColor: NSColor(hex: hex))
    }
}
