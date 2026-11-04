import SwiftUI

enum Poof {
    static let outDuration = 1.8
    static let inDuration = 2.0
}

extension Pose {
    mutating func puff(_ p: CGFloat, clock: TimeInterval, size: CGFloat = 1, x: CGFloat = 0, up: CGFloat = 28) {
        guard p >= 0, p < 1 else { return }
        cloud = Cloud(progress: p, size: size, x: x, up: up)
        guard p > 0.15 else { return }
        for k in 0..<4 {
            let angle = Double(k) * .pi / 2 + .pi / 4
            let reach = (34 + 44 * p) * size
            place(Art.sparkle[(Int(clock / 0.1) + k) % 2], x + reach * CGFloat(cos(angle)), up + 0.8 * reach * CGFloat(sin(angle)), opacity: Double(1 - p))
        }
    }

    mutating func poof(t: TimeInterval, clock: TimeInterval) {
        switch t {
        case ..<0.45:
            eyes = .happy
            right = Int(t / 0.15) % 2 == 0 ? .up : .diagUp
        case ..<0.62:
            let q = CGFloat((t - 0.45) / 0.17)
            sx = 1 + 0.14 * q
            sy = 1 - 0.18 * q
            eyes = .closed
            left = .tucked
            right = .tucked
        case ..<0.72:
            lift = 8 * CGFloat((t - 0.62) / 0.1)
            sx = 0.86
            sy = 1.2
            eyes = .wide
            left = .up
            right = .up
        default:
            hidden = true
        }
        puff(CGFloat((t - 0.64) / 1.1), clock: clock, size: 1.15)
    }

    mutating func poofIn(t: TimeInterval, clock: TimeInterval) {
        puff(CGFloat((t - 0.1) / 1.1), clock: clock, size: 1.15)
        switch t {
        case ..<0.1:
            hidden = true
            place(Art.sparkle[Int(clock / 0.05) % 2], 0, 28, scale: 0.6 + 4 * CGFloat(t))
        case ..<0.55:
            hidden = true
        case ..<1.0:
            eyes = .happy
            left = .up
            right = .up
        case ..<1.3:
            let k = sin(.pi * (t - 1.0) / 0.3)
            sx = 1 + 0.1 * k
            sy = 1 - 0.12 * k
            eyes = .closed
        case ..<1.65:
            let q = (t - 1.3) / 0.35
            lift = 12 * CGFloat(sin(.pi * q))
            legLength = 1.4
            eyes = .happy
            left = .diagUp
            right = .diagUp
        default:
            eyes = .happy
            left = .up
            right = .up
        }
    }
}
