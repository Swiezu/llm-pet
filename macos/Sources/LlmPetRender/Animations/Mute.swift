import SwiftUI

enum Mute {
    static let duration = 3.4
}

extension Pose {
    private mutating func zipper(_ closed: CGFloat) {
        let start = point(4.2, 4.7)
        let end = point(7.9, 4.7)
        let pixel = Style.unit / 2
        let reach = start.x + (end.x - start.x) * min(1, max(0, closed))
        var x = start.x
        var index = 0
        while x <= reach {
            dot(index % 2 == 0 ? "j" : "h", x, start.y + pixel / 2)
            dot(index % 2 == 0 ? "h" : "j", x, start.y - pixel / 2)
            x += pixel
            index += 1
        }
        if closed > 0 { place(Art.zipperPull, reach + pixel, start.y - pixel) }
    }

    mutating func mute(t: TimeInterval, clock: TimeInterval) {
        let icon = point(5.0, -3.6)
        let side = point(7.6, -3.6)
        let fade = t > 2.8 ? 1 - (t - 2.8) / 0.6 : 1
        place(Art.speaker, at: icon, opacity: fade, scale: 0.5 + 0.5 * Pose.ease(CGFloat(t / 0.25)))
        switch t {
        case ..<0.6:
            eyes = .wide
            lookY = -0.3
            if t > 0.25 { place(Art.speakerWaves[Int(clock / 0.18) % 2], at: side) }
        case ..<1.0:
            eyes = .wide
            lookY = -0.3
            place(Art.muteCross, at: side, scale: 0.3 + 0.7 * Pose.ease(CGFloat((t - 0.6) / 0.3)))
        case ..<1.3:
            left = .chin
            right = .chin
            eyes = .closed
            place(Art.muteCross, at: side)
        case ..<2.0:
            let p = CGFloat((t - 1.3) / 0.7)
            left = .chin
            right = .reach(0.6)
            eyes = .closed
            place(Art.muteCross, at: side)
            zipper(Pose.ease(p))
        default:
            eyes = t < 2.6 ? .closed : .happy
            bob = t < 2.6 ? 0.15 * CGFloat(sin((t - 2.0) * 16)) : 0
            place(Art.muteCross, at: side, opacity: fade)
            zipper(1)
        }
    }

    mutating func unmute(t: TimeInterval, clock: TimeInterval) {
        let icon = point(5.0, -3.6)
        let side = point(7.6, -3.6)
        let fade = t > 2.8 ? 1 - (t - 2.8) / 0.6 : 1
        place(Art.speaker, at: icon, opacity: fade, scale: 0.5 + 0.5 * Pose.ease(CGFloat(t / 0.25)))
        switch t {
        case ..<0.3:
            eyes = .closed
            zipper(1)
            place(Art.muteCross, at: side)
        case ..<1.0:
            let p = CGFloat((t - 0.3) / 0.7)
            right = .reach(0.6)
            eyes = .open
            zipper(1 - Pose.ease(p))
            place(Art.muteCross, at: side)
        case ..<1.3:
            eyes = .wide
            lookY = -0.3
            place(Art.muteCross, at: side, scale: 1 - Pose.ease(CGFloat((t - 1.0) / 0.3)))
        default:
            let beat = Int((t - 1.3) / 0.3)
            eyes = .happy
            notes = t < 2.9
            left = beat % 2 == 0 ? .diagUp : .side
            right = beat % 2 == 0 ? .side : .diagUp
            bob = beat % 2 == 0 ? -0.15 : 0
            place(Art.speakerWaves[Int(clock / 0.18) % 2], at: side, opacity: fade)
        }
    }
}
