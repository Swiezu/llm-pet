import SwiftUI

enum DillyDally {
    static let duration = 7.2
}

extension Pose {
    private mutating func amble(_ t: TimeInterval, from: CGFloat, to: CGFloat, start: TimeInterval, length: TimeInterval) {
        let p = CGFloat((t - start) / length)
        let eased = p * p * (3 - 2 * p)
        dx = from + (to - from) * eased
        flip = to < from
        let step = Int((t - start) / 0.32) % 2
        legs = step == 0 ? [0.35, 0, 0.35, 0] : [0, 0.35, 0, 0.35]
        bob = step == 0 ? -0.1 : 0
        look = 0.4
    }

    mutating func dillyDally(t: TimeInterval, clock: TimeInterval) {
        switch t {
        case ..<1.4:
            amble(t, from: 0, to: -45, start: 0, length: 1.4)
            lookY = -0.15
        case ..<2.3:
            dx = -45
            flip = true
            look = 0.3
            lookY = 0.3
            if t >= 1.55 && t < 1.75 {
                legs = [0, 0, 0, 0.6]
                tilt = -5
            }
            if t >= 1.65 { pebble = CGFloat((t - 1.65) / 0.6) }
        case ..<3.6:
            dx = -45
            tilt = 4 * sin(2 * .pi * (t - 2.3) / 1.3)
            left = .tucked
            right = .tucked
            eyes = .happy
            lookY = -0.25
            notes = true
        case ..<4.4:
            dx = -45
            look = 0.2
            lookY = 0.3
            legs = [0, Int((t - 3.6) / 0.2) % 2 == 0 ? 0.3 : 0, 0, 0]
            sy = 1 - 0.03 * CGFloat(sin(.pi * (t - 3.6) / 0.8))
        case ..<6.0:
            amble(t, from: -45, to: 32, start: 4.4, length: 1.6)
            lookY = -0.3
        case ..<6.9:
            amble(t, from: 32, to: 0, start: 6.0, length: 0.9)
        default:
            let q = CGFloat((t - 6.9) / 0.3)
            sy = 1 - 0.05 * sin(.pi * q)
            sx = 1 + 0.03 * sin(.pi * q)
            eyes = .closed
        }
    }
}
