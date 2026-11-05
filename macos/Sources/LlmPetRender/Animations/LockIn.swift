import SwiftUI

enum LockIn {
    static let duration = 7.5
}

extension Pose {
    mutating func lockIn(t: TimeInterval, clock: TimeInterval) {
        switch t {
        case ..<0.4:
            right = .chin
            left = .tucked
            look = 0.2 * CGFloat(t / 0.4)
        case ..<2.2:
            right = .chin
            left = .tucked
            look = 0.4
            lookY = -0.3
            tilt = 4
            thought = 1 + Int((t - 0.4) / 0.35) % 3
        case ..<2.5:
            let k = CGFloat(sin(.pi * (t - 2.2) / 0.3))
            left = .tucked
            right = .tucked
            eyes = .focused
            sy = 1 - 0.1 * k
            sx = 1 + 0.06 * k
            aura = 1
            band = .head
        case ..<6.3:
            let beat = Int(clock / 0.05)
            left = .tucked
            right = .tucked
            eyes = .focused
            dx = beat % 2 == 0 ? 0.6 : -0.6
            sy = 0.97
            aura = 0.6 + 0.4 * CGFloat(beat % 3) / 2
            steam = true
            band = .head
        case ..<6.7:
            let q = (t - 6.3) / 0.4
            eyes = .wide
            right = .up
            lift = 10 * CGFloat(sin(.pi * q))
            bulb = CGFloat(t - 6.3)
        default:
            eyes = .happy
            bulb = CGFloat(t - 6.3)
            right = t < 7.1 ? .up : .side
        }
    }
}
