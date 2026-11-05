import SwiftUI

enum Typing {
    static let duration = 6.6
    static let sitDepth: CGFloat = 0.85
}

extension Pose {
    private mutating func sit(_ amount: CGFloat) {
        bob = Typing.sitDepth * amount
        legLength = 1.2 - Typing.sitDepth * amount
    }

    mutating func typing(t: TimeInterval, clock: TimeInterval) {
        switch t {
        case ..<0.35:
            let p = CGFloat(t / 0.35)
            sit(1 - (1 - p) * (1 - p))
            look = 0.3
        case ..<0.75:
            let q = CGFloat((t - 0.35) / 0.4)
            sit(1)
            keyboard = Keyboard(dx: 7 * (1 - q) * (1 - q) - 0.6 * sin(.pi * q))
            right = .diagDown
            look = 0.5
        case ..<0.95:
            let s = (t - 0.75) / 0.2
            sit(1)
            keyboard = Keyboard(dy: s < 0.7 ? -1.2 * CGFloat(sin(.pi * s / 1.4)) : -1.2 * CGFloat(1 - (s - 0.7) / 0.3))
            left = .diagUp
            right = .diagUp
            eyes = .happy
        case ..<1.3:
            let k = CGFloat(sin(.pi * (t - 0.95) / 0.35))
            sit(1)
            keyboard = Keyboard(dy: 0.15 * k)
            sy = 1 - 0.08 * k
            sx = 1 + 0.06 * k
            left = .reach(0)
            right = .reach(0)
            dust = CGFloat((t - 0.95) / 0.35)
        case ..<6.0:
            let beat = Int(clock / 0.055)
            sit(1)
            bob += beat % 2 == 0 ? 0.05 : 0
            keyboard = Keyboard(typing: true)
            left = .reach(beat % 2 == 0 ? 0.45 : 0)
            right = .reach(beat % 2 == 0 ? 0 : 0.45)
            look = [0, 0, 0.15, 0, -0.15][Int(clock / 0.4) % 5]
        case ..<6.3:
            let q = CGFloat((t - 6.0) / 0.3)
            sit(1)
            keyboard = Keyboard(dx: 7 * q * q)
            right = .diagDown
            look = 0.4
        default:
            let p = CGFloat((t - 6.3) / 0.3)
            sit(max(0, 1 - p))
            eyes = .happy
        }
    }
}
